import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
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

  test('a user can update an allowed profile field but cannot add arbitrary data', async () => {
    await assertSucceeds(updateDoc(doc(dbFor(crewId), `users/${crewId}`), { homeZone: 'KUL' }));
    await assertFails(updateDoc(doc(dbFor(crewId), `users/${crewId}`), { accountCredit: 100000 }));
  });
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

  test('the assigned operator and driver can read a trip', async () => {
    await assertSucceeds(getDoc(doc(dbFor(operatorId), 'trips/trip-1')));
    await seed('trips/driver-trip', {
      crewIds: [crewId],
      operatorId: otherOperatorId,
      driverId: operatorId,
      status: 'accepted',
    });
    await assertSucceeds(getDoc(doc(dbFor(operatorId), 'trips/driver-trip')));
  });

  test('trip creation and all execution or assignment writes are server-only', async () => {
    await assertFails(setDoc(doc(dbFor(crewId), 'trips/new'), {
      crewIds: [crewId],
      status: 'requested',
      assignmentStatus: 'unassigned',
    }));
    await assertFails(
      updateDoc(doc(dbFor(operatorId), 'trips/trip-1'), { status: 'accepted' }),
    );
    await assertFails(deleteDoc(doc(dbFor(operatorId), 'trips/trip-1')));
  });

  test.each(['status', 'paymentStatus', 'operatorId'])(
    'crew cannot update operator-only trip field %s',
    async (field) => {
      await assertFails(updateDoc(doc(dbFor(crewId), 'trips/trip-1'), { [field]: 'changed' }));
    },
  );
});

describe('rosters', () => {
  test('crew can read only their own server-created roster documents', async () => {
    await seed('rosters/own', { crewId, duties: [], status: 'needs_review' });
    await seed('rosters/other', { crewId: otherCrewId, duties: [], status: 'needs_review' });
    const own = doc(dbFor(crewId), 'rosters/own');
    await assertSucceeds(getDoc(own));
    await assertFails(getDoc(doc(dbFor(crewId), 'rosters/other')));
    await assertFails(
      setDoc(doc(dbFor(crewId), 'rosters/new'), {
        crewId,
        duties: [],
        status: 'uploaded',
      }),
    );
  });

  test('crew cannot overwrite parser metadata or confirm directly', async () => {
    await seed('rosters/own', {
      crewId,
      status: 'needs_review',
      duties: [{ id: 'duty-1', confidence: 0.95 }],
    });
    const own = doc(dbFor(crewId), 'rosters/own');
    await assertFails(updateDoc(own, { duties: [{ id: 'duty-1', confidence: 1 }] }));
    await assertFails(updateDoc(own, { status: 'confirmed' }));
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
  test('operators can read only their vehicles and cannot write them', async () => {
    const own = doc(dbFor(operatorId), 'vehicles/own');
    await seed('vehicles/own', { operatorId, registrationNumber: 'TEST-1' });
    await seed('vehicles/other', { operatorId: otherOperatorId, registrationNumber: 'OTHER-1' });
    await assertSucceeds(getDoc(own));
    await assertFails(getDoc(doc(dbFor(operatorId), 'vehicles/other')));
    await assertFails(setDoc(doc(dbFor(operatorId), 'vehicles/new'), { operatorId }));
    await assertFails(updateDoc(own, { registrationNumber: 'TEST-2' }));
    await assertFails(deleteDoc(own));
  });
});

describe('notifications', () => {
  test('recipient query and read-state-only updates are allowed', async () => {
    await seed('notifications/notification-1', { recipientId: crewId, title: 'Assigned', read: false });
    const notification = doc(dbFor(crewId), 'notifications/notification-1');
    await assertSucceeds(getDoc(notification));
    await assertSucceeds(getDocs(query(
      collection(dbFor(crewId), 'notifications'),
      where('recipientId', '==', crewId),
    )));
    await assertSucceeds(updateDoc(notification, { read: true, readAt: serverTimestamp() }));
  });

  test('notification content, ownership, creation, and deletion are server-only', async () => {
    await seed('notifications/notification-1', { recipientId: crewId, title: 'Assigned', read: false });
    const notification = doc(dbFor(crewId), 'notifications/notification-1');
    await assertFails(updateDoc(notification, { title: 'Forged' }));
    await assertFails(updateDoc(notification, { recipientId: otherCrewId }));
    await assertFails(setDoc(doc(dbFor(crewId), 'notifications/new'), { recipientId: crewId }));
    await assertFails(deleteDoc(notification));
    await assertFails(getDoc(doc(dbFor(otherCrewId), 'notifications/notification-1')));
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

  test('another user cannot read the payment', async () => {
    await seed('payments/payment-1', { userId: crewId, status: 'pending' });
    await assertFails(getDoc(doc(dbFor(otherCrewId), 'payments/payment-1')));
  });
});

describe('server-owned collections', () => {
  test('trip events and financial records cannot be read or written directly', async () => {
    await seed('trips/trip-1', { crewIds: [crewId], operatorId, status: 'completed' });
    await seed('trips/trip-1/events/event-1', { actorId: operatorId, eventType: 'completed' });
    await seed('financialRecords/trip-1', { tripId: 'trip-1', crewIds: [crewId] });
    await assertFails(getDoc(doc(dbFor(crewId), 'trips/trip-1/events/event-1')));
    await assertFails(getDoc(doc(dbFor(crewId), 'financialRecords/trip-1')));
    await assertFails(setDoc(doc(dbFor(operatorId), 'trips/trip-1/events/new'), { eventType: 'forged' }));
  });
});
