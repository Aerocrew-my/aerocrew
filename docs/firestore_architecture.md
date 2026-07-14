# Firestore operational architecture

Collections: `users`, `trips`, `rosters`, `transportRequirements`, `notifications`, `vehicles`, and `payments`.

Required composite indexes:

- `trips`: `crewIds` array-contains + `scheduledPickupAt` ascending.
- `trips`: `operatorId` ascending + `scheduledPickupAt` ascending.
- `rosters`: `crewId` ascending + `createdAt` descending.

Trusted server work is required for roster extraction, transport-requirement generation, matching/assignment, notifications, CHIP purchase creation and webhook reconciliation, and payment-status updates. The Flutter client must not receive Anthropic or CHIP secrets. Empty Firestore queries remain empty; fixture repositories, when added for previews, must be explicitly injected.
