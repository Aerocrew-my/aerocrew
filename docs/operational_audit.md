# AeroCrew operational audit

## Production-connected

Authentication, profile recovery, role/approval routing, Crew profile setup/view, and Operator profile/documents/setup/view use `users/{uid}`. AuthGate remains the root and does not push duplicate dashboards.

## Partially connected

- Crew dashboard: canonical repository-backed trips; roster card is not yet repository-backed.
- Operator dashboard: canonical repository-backed assigned trips and guarded next transition; legacy detail screens remain map-based.
- Roster upload: server-mediated extraction is safe at the credential boundary, but its widget still performs direct persistence/matching calls.
- Subscription, billing, change-plan, payment-success: profile-backed UI; payment purchase creation now requires a trusted server endpoint and webhook.

## Mock-data only

Crew roster calendar, trip history/receipt, wallet, notifications, pool members/poolmates, pre-trip checklist, rating, flight brief, saved addresses, referral, stats, and live-tracking detail. Operator active/live job details, route optimiser, trip history, vehicles, availability, earnings/analytics, ratings, stats, and notifications. Shared chat, SOS, and payment history are also local UI demonstrations.

## Duplicate or overlapping

Crew trip-confirmed/live-tracking/map screens overlap. Operator job-details/active-job/live-job overlap. There is a shared SOS screen and another SOS class in Crew live tracking.

## Obsolete

`MatchingService` performs trusted matching/pool creation from the client, uses legacy `crewId`, and converts failures to empty results. It must not be used by a production flow; matching belongs on the server.

## Unclear

Flight brief and several auxiliary support/account screens do not have persistence contracts.

## Direct Firestore calls remaining

User-profile calls remain in auth/product/profile/account screens. Operational direct calls remain in roster upload and legacy `MatchingService`; these are explicitly not classified as production-ready.

## Navigation

AuthGate swaps authenticated destinations declaratively. Dashboards use an `IndexedStack`, preserving bottom navigation state. Detail pages use normal pushes and back navigation. Legacy screens still contain local pop assumptions and no deep-link contract; a whole-app router migration was intentionally not attempted.

## Security blockers

Anthropic credentials are not present in Dart; extraction uses `ROSTER_EXTRACTION_URL` plus a Firebase ID token. CHIP previously accepted a client build-time API key and called CHIP directly; it now uses `PAYMENT_API_URL`. Server endpoints must verify Firebase tokens, enforce ownership, keep provider secrets server-side, and reconcile payments from signed webhooks.
