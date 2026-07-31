# Firebase emulator tooling

The Node test toolchain is isolated under `firebase/`. Firestore rules tests use the real Firebase Emulator Suite, and the seed script refuses to run unless `FIRESTORE_EMULATOR_HOST` is set.

## Run the emulator and rules tests

From the repository root:

```powershell
firebase emulators:start
```

In another terminal:

```powershell
cd firebase/rules-tests
npm install
npm test
node ../seed/seed-emulator.js
```

`firebase emulators:start` sets `FIRESTORE_EMULATOR_HOST` for processes it launches, but not for an unrelated terminal. Before running the seed command manually, set it to the Firestore emulator shown in the emulator output (the configured default is `127.0.0.1:8080`):

```powershell
$env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
$env:GCLOUD_PROJECT = 'demo-aerocrew'
node ../seed/seed-emulator.js
```

The seed creates exactly five documents: one crew user, one approved operator user, one operator vehicle, one unassigned transport requirement, and one requested trip referencing the crew user. Run it against a clean emulator; fixed document IDs intentionally make duplicate runs fail instead of silently adding more data.
