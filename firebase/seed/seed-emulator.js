const emulatorHost = process.env.FIRESTORE_EMULATOR_HOST;

if (!emulatorHost) {
  throw new Error('FIRESTORE_EMULATOR_HOST must be set; refusing to seed a non-emulator Firestore instance.');
}

const projectId = process.env.GCLOUD_PROJECT ?? 'demo-aerocrew';
const baseUrl = `http://${emulatorHost}/v1/projects/${projectId}/databases/(default)/documents`;
const stringValue = (value) => ({ stringValue: value });
const stringArray = (values) => ({ arrayValue: { values: values.map(stringValue) } });

async function createDocument(path, fields) {
  const slash = path.lastIndexOf('/');
  const collectionPath = path.slice(0, slash);
  const documentId = path.slice(slash + 1);
  const response = await fetch(`${baseUrl}/${collectionPath}?documentId=${encodeURIComponent(documentId)}`, {
    method: 'POST',
    headers: {
      Authorization: 'Bearer owner',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });

  if (!response.ok) {
    throw new Error(`Failed to create ${path}: ${response.status} ${await response.text()}`);
  }
}

await createDocument('users/seed-crew', {
  name: stringValue('Seed Crew'), email: stringValue('crew@seed.test'),
  phone: stringValue('+60000000001'), role: stringValue('crew'), status: stringValue('verified'),
});
await createDocument('users/seed-operator', {
  name: stringValue('Seed Operator'), email: stringValue('operator@seed.test'),
  phone: stringValue('+60000000002'), role: stringValue('operator'), status: stringValue('approved'),
});
await createDocument('vehicles/seed-vehicle', {
  operatorId: stringValue('seed-operator'), registrationNumber: stringValue('SEED-001'), status: stringValue('active'),
});
await createDocument('transportRequirements/seed-requirement', {
  crewId: stringValue('seed-crew'), assignmentStatus: stringValue('unassigned'), tripId: stringValue('seed-trip'),
});
await createDocument('trips/seed-trip', {
  createdBy: stringValue('seed-crew'), crewIds: stringArray(['seed-crew']),
  status: stringValue('requested'), assignmentStatus: stringValue('unassigned'), paymentStatus: stringValue('pending'),
  operatorId: { nullValue: null }, driverId: { nullValue: null }, vehicleId: { nullValue: null },
});

console.log(`Seeded 5 controlled documents in Firestore emulator project ${projectId}.`);
