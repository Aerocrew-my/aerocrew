# AeroCrew build audit

Baseline date: 2026-08-18. Branch: `master`. The worktree already contained
uncommitted formatting changes in roster, dashboard, and CHIP files; they were
preserved.

## Architecture

`AuthGate` owns application boot and combines Firebase Auth with a `users/{uid}`
profile lookup. `AuthenticatedDestination` deterministically routes crew and
operators through setup and approval. Canonical trip and roster models live
under `lib/features`; Firebase repositories exist for both, but many legacy
screens still query Firestore directly or render local fixtures. Shared UI and
the appearance preference are appropriately client-local.

## Collections and screen mapping

| Collection | Current consumers | Authority |
| --- | --- | --- |
| `users` | auth routing, profiles, product, billing, dashboards | Firestore |
| `trips` | crew/operator dashboards | Firestore via `FirebaseTripRepository` |
| `rosters` | asynchronous roster job repository/upload/review | trusted API writes; owner Firestore reads |
| `transportRequirements` | trusted matching boundary | server-only writes |
| `vehicles` | vehicle management | Firestore contract; screen remains partial |
| `notifications` | notification screens | server-only writes; screens remain partial |
| `payments` | billing/payment views | trusted backend/webhook only |

## Authoritative versus prototype data

Authentication, profile routing, dashboard trip lists, trip transitions,
asynchronous roster upload/review/confirmation, and payment API boundary are connected. Trip history,
receipt, live tracking, pool members, wallet, crew statistics, several roster
calendar cards, operator active/live details, route optimisation, earnings,
ratings, notifications, and chat still contain presentation fixtures. Static
airport/product/zone configuration is legitimate configuration. Operational
screens must show empty/error states until their repositories are connected.

## Duplication and status drift

- Crew trip-confirmed, map, and live-tracking screens overlap lifecycle stages.
- Operator job-details, active-job, live-job, and map screens overlap.
- `MatchingService` is a legacy client-side trusted operation and must remain
  unused; `RosterMatchingService` is the server boundary.
- Trip states are canonical in `TripStatus`/`TripTransitions`, although legacy
  screens still use display maps. Roster `review` is read as the backward-
  compatible alias of canonical `needs_review`.
- Profile `status` currently combines account, crew verification, and operator
  approval concepts. Splitting it requires a server migration, not client-only
  aliases.

## Incomplete actions and navigation

Receipt download, local notification actions, decorative routing, live GPS,
several support/chat actions, and fixture-backed detail pages are incomplete.
Navigation is primarily imperative `Navigator.push`; root auth routing is
declarative and correct. A router migration is not required for the MVP.

## Security review

Firestore rules prevent role/status self-promotion, client assignment, client
payment writes, and non-sequential operator trip transitions. Provider secrets
are not embedded. Remaining risks are broad owner updates to mutable profile
fields, approved operators being allowed to create/delete their own vehicles
without protected verification fields, legacy roster upload schema drift, and
trusted backend endpoints that still need deployment and token validation.

The payment return page previously treated a redirect as proof and attempted to
write `paid` plus an active subscription from Flutter. It now performs a server
status check only; webhook reconciliation remains authoritative.

## Baseline results

- `flutter pub get`: passed; 21 constrained packages have newer releases.
- `flutter analyze`: passed, no issues.
- `flutter test`: passed, 29 tests. Initial sandboxed runs stalled because Dart
  could not update its user-level telemetry session file; the unrestricted
  verification run completed in 4.4 seconds.

## Production blockers and execution order

1. Deploy the authenticated roster-job endpoints, including deterministic requirement and initial trip creation.
2. Deploy payment purchase/status endpoints and signed CHIP webhook handling.
3. Migrate legacy roster documents (`review` remains readable as `needs_review`).
4. Connect fixture-backed trip detail/history screens to `TripRepository`.
5. Finish operator vehicle/driver assignment with server overlap checks.
6. Connect notifications and earnings repositories.
7. Harden profile and vehicle protected-field rules and run emulator tests.
8. Verify web and Android release configuration against pilot environments.
