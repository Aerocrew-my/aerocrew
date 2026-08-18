# Secure roster parsing backend contract

No Anthropic/provider credential belongs in Flutter. The client sends a
Firebase ID token to a trusted HTTPS service configured with
`ROSTER_EXTRACTION_URL`; the service verifies the token and derives `crewId`
from it.

## Preferred asynchronous API

`POST /v1/roster-jobs` accepts `application/json`:

```json
{"mediaType":"application/pdf","file":"<base64>"}
```

Validate JPEG, PNG, or PDF, a maximum decoded size of 12 MiB, and reject files
whose content does not match the declared media type. Respond `202`:

```json
{"jobId":"job_123","status":"queued"}
```

`GET /v1/roster-jobs/{jobId}` returns only an owner-visible job:

```json
{
  "jobId":"job_123",
  "status":"needs_review",
  "duties":[{
    "id":"duty_1",
    "flightNumber":"MH123",
    "airport":"KUL",
    "reportAt":"2026-08-20T08:00:00+08:00",
    "departureAt":"2026-08-20T09:30:00+08:00",
    "confidence":0.94
  }]
}
```

Lifecycle: `uploaded -> queued -> processing -> needs_review -> confirmed`,
with `failed` from processing states. Store timestamps in UTC and retain
`Asia/Kuala_Lumpur` as the source timezone. Return stable error codes; never
return fabricated duties after a parsing failure.

`POST /v1/roster-jobs/{jobId}/confirm` accepts reviewed duties and creates
deterministic transport requirements server-side. A recommended idempotency key
is a hash of `crewId`, duty date, flight number, direction, report/release time,
and airport. The server owns matching, assignment, and notification writes.

Confirmation returns `200` with the canonical roster resource. It is
idempotent: repeating the same confirmed duty set returns the same requirement
and trip identifiers. `POST /v1/roster-jobs/{jobId}/retry` returns `202` and may
only restart an owner-visible failed job.

For duties touching the crew's configured base airport, confirmation creates a
deterministically identified `transportRequirements` document and an initial
`requested` trip without operator, driver, vehicle, fare override, match score,
or paid state. Reporting from base creates home-to-airport transport; release
after arriving at base creates airport-to-home transport. Other sectors create
no airport transport requirement.

Flutter now uses these asynchronous job endpoints exclusively. A deployed
backend remains required before roster upload can operate in production.
