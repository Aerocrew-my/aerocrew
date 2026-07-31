import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, test } from 'vitest';

const projectId = 'demo-aerocrew';
const crewId = 'crew-1';
const otherCrewId = 'crew-2';
const operatorId = 'operator-1';
const otherOperatorId = 'operator-2';

let env: RulesTestEnvironment;

const dbFor = (uid: string, email = `${uid}@example.test`) =>
  env.authenticatedContext(uid, { email }).firestore();

async function seed(path: string, data: Record<string, unknown>) {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

beforeAll(async () => {
  const rulesPath = fileURLToPath(new URL('../../firestore.rules', import.meta.url));
  env = await initializeTestEnvironment({
    projectId,
    firestore: { rules: await readFile(rulesPath, 'utf8') },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed(`users/${crewId}`, { role: 'crew', status: 'verified' });
  await seed(`users/${otherCrewId}`, { role: 'crew', status: 'verified' });
  await seed(`users/${operatorId}`, { role: 'operator', status: 'approved' });
  await seed(`users/${otherOperatorId}`, { role: 'operator', status: 'approved' });
});

afterAll(async () => {
  await env.cleanup();
});

describe('users', () => {
  test('a user can read only their own profile', async () => {
    const db = dbFor(crewId);
    await assertSucceeds(getDoc(doc(db, `users/${crewId}`)));
    await assertFails(getDoc(doc(db, `users/${otherCrewId}`)));
  });

  test.each(['role', 'admin', 'isAdmin', 'status', 'approvalStatus', 'verificationStatus', 'verified'])(
    'a user cannot update protected profile field %s',
    async (field) => {
      await assertFails(updateDoc(doc(dbFor(crewId), `users/${crewId}`), { [field]: true }));
    },
  );
});

describe('trips', () => {
  beforeEach(async () => {
    await seed('trips/trip-1', {
      crewIds: [crewId],
      operatorId,
      driverId: 'driver-1',
      vehicleId: 'vehicle-1',
      status: 'assigned',
      assignmentStatus: 'assigned',
      paymentStatus: 'pending',
    });
  });

  test('listed crew can read a trip and unlisted crew cannot', async () => {
    await assertSucceeds(getDoc(doc(dbFor(crewId), 'trips/trip-1')));
    await assertFails(getDoc(doc(dbFor(otherCrewId), 'trips/trip-1')));
  });

  test('the assigned operator can make an allowed transition', async () => {
    await assertSucceeds(
      updateDoc(doc(dbFor(operatorId), 'trips/trip-1'), {
        status: 'accepted',
        assignmentStatus: 'accepted',
      }),
    );
  });

  test('the assigned operator cannot jump directly to completed', async () => {
    await assertFails(
      updateDoc(doc(dbFor(operatorId), 'trips/trip-1'), { status: 'completed' }),
    );
  });

  test.each(['status', 'paymentStatus', 'operatorId'])(
    'crew cannot update operator-only trip field %s',
    async (field) => {
      await assertFails(updateDoc(doc(dbFor(crewId), 'trips/trip-1'), { [field]: 'changed' }));
    },
  );
});

describe('rosters', () => {
  test('crew can create and read only their own roster documents', async () => {
    const own = doc(dbFor(crewId), 'rosters/own');
    await assertSucceeds(setDoc(own, { crewId, duties: [], status: 'draft' }));
    await assertSucceeds(getDoc(own));
    await assertFails(
      setDoc(doc(dbFor(crewId), 'rosters/other'), {
        crewId: otherCrewId,
        duties: [],
        status: 'draft',
      }),
    );
  });
});

describe('transport requirements', () => {
  test('crew can read their own requirement but cannot write it', async () => {
    await seed('transportRequirements/requirement-1', { crewId, assignmentStatus: 'unassigned' });
    const requirement = doc(dbFor(crewId), 'transportRequirements/requirement-1');
    await assertSucceeds(getDoc(requirement));
    await assertFails(updateDoc(requirement, { assignmentStatus: 'assigned' }));
  });
});

describe('vehicles', () => {
  test('operators can manage only vehicles under their own account', async () => {
    const own = doc(dbFor(operatorId), 'vehicles/own');
    await assertSucceeds(setDoc(own, { operatorId, registrationNumber: 'TEST-1' }));
    await assertSucceeds(updateDoc(own, { registrationNumber: 'TEST-2' }));
    await assertSucceeds(deleteDoc(own));
    await assertFails(
      setDoc(doc(dbFor(operatorId), 'vehicles/other'), {
        operatorId: otherOperatorId,
        registrationNumber: 'OTHER-1',
      }),
    );
  });
});

describe('notifications', () => {
  test('users can read their own notifications but cannot create system notifications', async () => {
    await seed('notifications/notification-1', { userId: crewId, title: 'Assigned' });
    const notification = doc(dbFor(crewId), 'notifications/notification-1');
    await assertSucceeds(getDoc(notification));
    await assertFails(setDoc(doc(dbFor(crewId), 'notifications/new'), { userId: crewId }));
  });
});

describe('payments', () => {
  test('users can read their own payment but cannot write provider reconciliation fields', async () => {
    await seed('payments/payment-1', {
      userId: crewId,
      providerStatus: 'pending',
      reconciliationStatus: 'unreconciled',
    });
    const payment = doc(dbFor(crewId), 'payments/payment-1');
    await assertSucceeds(getDoc(payment));
    await assertFails(
      updateDoc(payment, { providerStatus: 'paid', reconciliationStatus: 'reconciled' }),
    );
  });
});
