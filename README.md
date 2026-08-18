# AeroCrew

AeroCrew is an aviation crew ground-mobility platform for pilots and cabin
crew. It digitalises airport transportation coordination — crew pickups,
drop-offs, live trip progression, and operator dispatch — that previously
ran through WhatsApp.

This repository is the **Flutter mobile app** (crew + operator apps) for
Android, iOS, and Flutter Web. The companion operations portal
(admin/dispatch, Next.js) lives in a separate repository:
[aerocrew-admin](https://github.com/Aerocrew-my/aerocrew-admin).

## Firebase project

- Project: `aerocrew-96754`
- Android application id: `my.aerocrew.app`

## Running locally

```powershell
flutter pub get
flutter run
```

Some features require trusted server endpoints to be supplied at build
time via `--dart-define`, since provider credentials must never ship
inside the client:

| Define | Used by | Purpose |
| --- | --- | --- |
| `ROSTER_EXTRACTION_URL` | `ApiRosterRepository` | API root for private roster upload authorization, jobs, confirmation, and retry |
| `PAYMENT_API_URL` | `ChipService` | Server endpoint that creates and reconciles CHIP payment purchases |

Example:

```powershell
flutter run --dart-define=ROSTER_EXTRACTION_URL=https://example.com/api --dart-define=PAYMENT_API_URL=https://example.com/payments
```

Without these defines, the corresponding features fail safely with a clear
"not configured" error rather than falling back to insecure client-side logic.

Roster files use a private direct-upload flow: the app requests authorization
with file name and MIME type, sends raw bytes to the returned short-lived signed
Storage `PUT` URL, then creates a small roster job containing only the
server-issued `uploadId`. Signed URLs and temporary Storage headers are never
persisted. Flutter Web requires bucket CORS for `https://aerocrew.app` and the
specific `http://localhost:<flutter-port>` development origin; configure CORS
on the bucket rather than in the app.

## Validation

```powershell
flutter clean
flutter pub get
dart format . --set-exit-if-changed
flutter analyze
flutter test
```
