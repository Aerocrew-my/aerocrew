# AeroCrew MVP testing

Use a disposable Firebase project or staging environment. Phase 6 seed records do not create Firebase Auth credentials.

## Start the backend

```powershell
cd C:\Users\fable\aerocrew-admin
npm run seed:mvp
npm run dev
```

Set the backend Firebase variables described in the admin repository. For sandbox payment testing set `PAYMENT_MODE=test`; never use that value with `NODE_ENV=production`.

Create two Firebase Authentication email/password users manually, with UIDs exactly `TEST_CREW_001` and `TEST_OPERATOR_001`. The seed already creates the matching Firestore profiles and canonical trip/payment records. No bypass login exists.

## Flutter Web

```powershell
cd C:\Users\fable\aerocrew
flutter run -d chrome --web-port=8080 --dart-define=ROSTER_EXTRACTION_URL=http://localhost:3000/api
```

`ROSTER_EXTRACTION_URL` is the only additional Phase 6 client define: payment, receipt, offers, execution, and earnings all use the authenticated `/api/v1` backend under that base URL. `PAYMENT_MODE` remains server-only.

## Android emulator

The Android emulator reaches the host through `10.0.2.2`:

```powershell
cd C:\Users\fable\aerocrew
flutter run -d emulator-5554 --dart-define=ROSTER_EXTRACTION_URL=http://10.0.2.2:3000/api
```

## A. Crew flow

1. Sign in as the Firebase user whose UID is `TEST_CREW_001`. The dashboard should show the seeded canonical requested/assigned trip, never a sample trip.
2. Open the trip. Driver, vehicle, and current execution status should match the backend record.
3. Select **Manage payment**, then **Create / check payment**. The status starts pending. In server test mode a small **TEST MODE** chip and **Complete test payment** action appear. Only the backend response changes the UI to confirmed.
4. Let the operator advance and complete the trip. The crew trip updates without an app restart.
5. Open History. The completed trip should appear immediately; select it to see the real AeroCrew receipt, route, amount, payment state, operator safe name, and completion state.
6. Open Notifications. Assignment, driver/vehicle, execution, completion, and payment records should appear. Select an unread item, then use **Mark all read** and verify the unread state changes.

## B. Operator flow

1. Sign in as the Firebase user whose UID is `TEST_OPERATOR_001`. The dashboard should show only canonical offers/assignments.
2. Open the offer, choose the seeded eligible vehicle, and accept. A stale or already accepted offer should show a refresh-safe message rather than fabricated success.
3. Open the active assignment and advance pickup, arrival, boarding/stops, airport leg, and completion in order.
4. Open Earnings. The completed trip, gross booking value, operator payable, and pending/ready/settled state should match `GET /api/v1/operator/earnings`.
5. Open Trip History and Notifications. Both should contain only canonical completed assignments/server notifications; empty data should show truthful empty states.

## C. Admin flow

1. Open the admin trip dashboard and verify the same trip status and assignment.
2. Verify payment in the payments/revenue view and the completed trip in reconciliation.
3. Verify `financialRecords/TEST_TRIP_001` was created once, payable is not exposed on the crew receipt, and settlement remains pending until an authorized admin transition.
4. Verify deterministic crew/operator notifications exist once even after retrying completion.

## Reset and scope

Use `npm run clear:mvp` in the admin repository to remove known seeded records in a non-production environment, then seed again.

**LIVE ROSTER PARSING TEST DEFERRED**

Continuous GPS, map navigation, real payout rails, FCM push, referral, leaderboard, advanced statistics, wallet enhancements, and AI route optimization are outside this MVP pass.
