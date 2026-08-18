# Firestore schema and access contract

All timestamps are Firestore timestamps representing UTC instants. Operational
display defaults to `Asia/Kuala_Lumpur`.

| Collection / ID | Owner and core fields | Access and protected fields |
| --- | --- | --- |
| `users/{uid}` | user; name, email, phone, role, status, product, profile fields | owner read/update; role, status, approval/verification/admin fields protected; privileged changes server/admin only |
| `trips/{tripId}` | crew set; canonical status, serviceType, crewIds, stops, airport, times, assignment/payment fields | participating crew and assigned approved operator read; crew creates unassigned request; operator only sequential execution fields; assignment, fare, payment server-owned |
| `rosters/{rosterId}` | crewId; canonical status, normalized duties, source metadata, timestamps | owner read; all writes through authenticated roster backend so parser metadata and idempotent confirmation remain protected |
| `transportRequirements/tr_{stableHash}` | crewId, rosterId, dutyId, direction, window, product, airport, status | owner read; server write; deterministic identity prevents confirmation/retry duplicates; matching and assignment fields protected |
| `vehicles/{vehicleId}` | operatorId; registration, make/model, capacity, active, verification and expiry fields | approved owner read; operator-editable descriptive fields; verification server/admin-owned |
| `notifications/{notificationId}` | recipientId/legacy userId; role, type, title, body, tripId, read, createdAt | recipient read and read-state update only; creation server-owned |
| `payments/{paymentId}` | userId; provider reference, amount/currency, status, timestamps | owner read; all writes trusted payment backend/webhook only |

Required composite indexes: `trips(crewIds ARRAY, scheduledPickupAt ASC)`,
`trips(operatorId ASC, scheduledPickupAt ASC)`, and
`rosters(crewId ASC, createdAt DESC)`.

Client roles are routing hints, never admin authorization. Trusted services must
verify Firebase ID tokens and enforce ownership independently of request bodies.
The roster backend also owns initial `requested` trip creation and must omit
operator, vehicle, driver, fare override, match score, and paid state.
