# Secure roster parsing backend contract

No Anthropic/provider credential belongs in Flutter. The client sends a
Firebase ID token to a trusted HTTPS service configured with
`ROSTER_EXTRACTION_URL`; the service verifies the token and derives `crewId`
from it.

## Private direct-upload API

Flutter first calls `POST /v1/roster-uploads` with a Firebase bearer token:

```json
{"fileName":"roster.pdf","mediaType":"application/pdf"}
```

The server returns `201` with `uploadId`, a short-lived `uploadUrl`, `method`,
required `headers`, and `expiresAt`. Flutter sends the raw PDF/JPEG/PNG bytes
directly to that URL with the returned method and headers. It does not add the
Firebase bearer token, rewrite the query, encode the bytes as base64, log the
URL, or persist any signed-upload material.

After a successful Storage response, `POST /v1/roster-jobs` accepts only:

```json
{"uploadId":"<server-issued-upload-id>"}
```

The server validates the private object, including non-empty content, a 12 MiB
maximum, MIME type, signature, ownership, and server-derived object path. It
responds `202`:

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

Flutter automatically requests one replacement authorization only when Storage
clearly reports expiry. If Storage succeeded but job creation failed, retry uses
the same `uploadId` and does not upload a second object. Only accepted job IDs
are persisted for polling/resume; signed URLs, query strings, and temporary
headers are never persisted.

A deployed backend remains required before roster upload can operate in
production.

## Flutter local development

The Next.js route handlers are under `/api`, while the paths above are relative
to that API root. Start the web backend from its repository with:

```powershell
npm run dev
```

For Flutter Web, from this repository use:

```powershell
flutter run -d chrome --dart-define=ROSTER_EXTRACTION_URL=http://localhost:3000/api
```

For an Android emulator, the host machine is normally available as `10.0.2.2`:

```powershell
flutter run -d emulator-5554 --dart-define=ROSTER_EXTRACTION_URL=http://10.0.2.2:3000/api
```

Production builds use:

```powershell
flutter build web --dart-define=ROSTER_EXTRACTION_URL=https://aerocrew.app/api
```

The repository appends `/v1/roster-uploads`, `/v1/roster-jobs`, and the job,
confirm, and retry suffixes. Do not include a versioned route in
`ROSTER_EXTRACTION_URL`.

## Flutter Web Storage CORS

The private Storage bucket must allow `PUT` and the returned upload headers
(currently `Content-Type`) from `https://aerocrew.app` and each explicit local
development origin such as `http://localhost:<flutter-port>`. Configure this on
the bucket/deployment, keep reads private, and do not use a permissive `*` as a
client workaround. A browser CORS failure is surfaced as a Storage upload error;
native Android uploads are not subject to browser CORS.
