# AeroCrew MVP testing

Use only a disposable or staging Firebase project. Follow the admin guide at `C:\Users\fable\aerocrew-admin\docs\MVP_TESTING.md` to set the PowerShell environment, create the exact Firebase Auth users, seed the canonical records, and start the backend.

The seeded trip starts as `requested` with `assignmentStatus = unassigned`. Matching and operator acceptance are intentionally part of the test.

## Run Flutter

Web:

```powershell
cd C:\Users\fable\aerocrew
flutter run -d chrome --web-port=8080 --dart-define=ROSTER_EXTRACTION_URL=http://localhost:3000/api
```

Android emulator:

```powershell
cd C:\Users\fable\aerocrew
flutter run -d emulator-5554 --dart-define=ROSTER_EXTRACTION_URL=http://10.0.2.2:3000/api
```

`ROSTER_EXTRACTION_URL` is the only additional Phase 6 client define. Trip payment, receipt, offers, execution, and earnings use the authenticated `/api/v1` backend. `PAYMENT_MODE` is server-only. `ChipService` and `PAYMENT_API_URL` remain only for the legacy subscription/billing checkout, outside this MVP trip-payment flow.

## Canonical manual sequence

1. Sign in as the Firebase user with UID `TEST_CREW_001`; the dashboard shows **Requested / Operator Pending** for `TEST_TRIP_001`.
2. In Admin, open Matching, initiate or select matching as required, and offer the trip to `TEST_OPERATOR_001`.
3. Sign in as `TEST_OPERATOR_001`; open the offer, select `TEST_VEHICLE_001`, and accept.
4. Return to Crew and verify the assigned operator and vehicle appear without restarting the app.
5. Open **Manage payment**, create or check the canonical payment, and use **Complete test payment** only when the backend reports test mode.
6. As Operator, open the active assignment and advance pickup, arrival, boarding, airport leg, and completion in order.
7. As Crew, verify live trip updates, History, the receipt, and assignment/execution/completion/payment notifications. Mark one and then all notifications read.
8. As Operator, verify Trip History, Earnings, and notifications. In Admin, verify trip state, finance/reconciliation, receipt inputs, and deterministic notifications.

Reset from the admin repository with `npm run clear:mvp`, then reseed. Cleanup removes the exact test Auth users and known seeded Firestore records; clean workflow-generated records from the disposable project if a completely pristine rerun is needed.

**LIVE ROSTER PARSING TEST DEFERRED**

Continuous GPS, map navigation, real payout rails, FCM push, referral, leaderboard, advanced statistics, wallet enhancements, and AI route optimization are outside this MVP pass.
