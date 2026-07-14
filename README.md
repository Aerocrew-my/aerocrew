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
| `ROSTER_EXTRACTION_URL` | `AnthropicService` | Server endpoint that extracts duties from an uploaded roster file |
| `ROSTER_MATCHING_URL` | `RosterMatchingService` | Server endpoint that generates transport requirements / pool matches from a confirmed duty |
| `PAYMENT_API_URL` | `ChipService` | Server endpoint that creates and reconciles CHIP payment purchases |

Example:

```powershell
flutter run --dart-define=ROSTER_EXTRACTION_URL=https://example.com/roster/extract --dart-define=ROSTER_MATCHING_URL=https://example.com/roster/match --dart-define=PAYMENT_API_URL=https://example.com/payments
```

Without these defines, the corresponding features fail safely with a
clear "not configured" error rather than falling back to insecure
client-side logic.

## Validation

```powershell
flutter clean
flutter pub get
dart format . --set-exit-if-changed
flutter analyze
flutter test
```
