# GlassWave

Notes app with a glassmorphism UI. The real product is the **React + Vite** web app — it syncs through Firebase, works offline, and can be installed as a PWA or wrapped with Capacitor for Android/iOS.

**Live:** [glasswave.pages.dev](https://glasswave.pages.dev/)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

There is also a **Flutter prototype** under `lib/`. It looks similar but stores everything on-device and does **not** talk to Firebase.

## What it does

- Create and edit notes in a TipTap rich-text editor (autosave)
- Pin, archive, trash, search, sort, and set reminders
- Sign in with email/password (reset + email verification) or stay a guest
- Signed-in notes sync via Firestore; guests stay in the browser (`localStorage`)
- Offline: Firestore IndexedDB cache on web, service-worker shell for the PWA
- 12 color themes, UI in Russian / English / Korean
- Reminders: in-app poller on web (only while the tab is open); native local notifications in the Capacitor apps

## Layout

```
src/                    React + Vite app (this is the product)
  app/                  screens, editor, settings, note services
  i18n/                 translations — single source of truth
  hooks/                Firestore query hook
  styles/
  firebase.ts           Auth + Firestore client
  notifications.ts      reminder sound / native notifications
  pwa.ts
lib/                    Flutter prototype (local-only)
android-capacitor/      Capacitor Android project
ios-capacitor/          Capacitor iOS project
android/ ios/ …         Flutter platform shells (not the shipping apps)
assets/translations/    generated JSON for Flutter — do not edit by hand
docs/                   APK, iOS, PWA, notification sound
firestore.rules         owner-only notes + field/type/size checks
```

## Web

Needs Node.js 18+ (22+ if you also build the APK).

```bash
git clone https://github.com/aalmaz1/glasswave.git
cd glasswave
npm install
npm run dev          # http://localhost:5173
```

```bash
npm run typecheck
npm run lint
npm run format:check
npm run test
npm run build
npm run preview      # production build + PWA service worker, :4173
```

### Firebase

The web app already points at the official **`glasswave-4f5da`** project (Email/Password). You do not need a `.env` to log in.

To aim a fork or staging build at another project, copy [`.env.example`](.env.example) to `.env` and set all six `VITE_FIREBASE_*` values from **that** project. Mixing keys from two projects is the usual cause of `auth/operation-not-allowed`.

If you override the config:

- Enable **Email/Password** (the password provider, not Email link)
- Add every host you serve from to Authentication → Settings → Authorized domains
- Do not set `VITE_FIREBASE_AUTH_EMULATOR` unless the emulator is actually running

Do not commit `.env`. Security rules live in [`firestore.rules`](firestore.rules) — the snippet that used to sit in this README was incomplete.

## Native (same React app)

Capacitor wraps the web build. Flutter’s native trees stay in `android/` and `ios/`.

**Android APK** — Node 22+, JDK 21, Android SDK (compileSdk 36):

```bash
npm run android:apk
# android-capacitor/app/build/outputs/apk/release/app-release.apk
```

Pushes to `main` also typecheck, lint, test, and publish a GitHub Release APK (`.github/workflows/apk_build.yml`). Details: [docs/android-apk.md](docs/android-apk.md).

**iOS** — no CI (needs a Mac + Apple signing). Details: [docs/ios-app.md](docs/ios-app.md).

```bash
npm run cap:sync:ios
open ios-capacitor/App/App.xcworkspace
```

PWA notes (install, offline shell, what reminders can and cannot do in the browser): [docs/pwa.md](docs/pwa.md). Notification sound across web / Android / iOS: [docs/notification-sound.md](docs/notification-sound.md).

## Flutter prototype

Local-only. Accounts are a SHA-256 hash in `shared_preferences`. No cloud sync.

```bash
flutter pub get
flutter run
```

Dart SDK `^3.12.2` (see `pubspec.yaml`).

## Using the app

The dashboard is one screen with **Notes / Archive / Trash** tabs. Pinned notes sit at the top of Notes. Settings is a separate screen (account, theme, language, delete account).

| Shortcut | Action |
| --- | --- |
| `Ctrl/Cmd + N` | New note (dashboard) |
| `Ctrl/Cmd + F` | Focus search |
| `Ctrl/Cmd + S` | Save (editor) |
| `Esc` | Close editor / modal |

## i18n

[`src/i18n/translations.ts`](src/i18n/translations.ts) is the only place to add strings. After editing it:

```bash
npm run i18n:export    # regenerates assets/translations/{ru,en,ko}.json
```

## License

[MIT](LICENSE)
