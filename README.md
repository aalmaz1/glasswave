# 🌊 GlassWave

**Modern cross-platform note-taking application with glassmorphism design**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.12+-blue?logo=flutter)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-18.3+-61dafb?logo=react)](https://reactjs.org)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)](https://firebase.google.com)

GlassWave is an elegant note management application featuring modern glassmorphism design, Firebase synchronization support, and a multilingual interface.

## ✨ Features

### 🎨 Design
- **Glassmorphism UI** — semi-transparent elements with background blur
- **Responsive interface** — optimized for mobile and desktop devices
- **Smooth animations** — pleasant transitions between screens

### 📝 Functionality
- **Create and edit notes** — support for titles and formatted text
- **Organization** — pin, archive, trash
- **Search and sorting** — quick search through notes, sort by creation/update date
- **Reminders** — set reminders for important notes
- **Guest mode** — use without registration

### 🔐 Synchronization (web app)
- **Firebase Firestore** — cloud synchronization across devices
- **Local caching** — offline work with IndexedDB
- **Authentication** — secure login via Firebase Auth (with password reset & email verification)

> The Flutter version is a **local-only** prototype (see [Mobile Version](#-mobile-version-flutter)); cloud sync currently lives in the React web app.

### 🌍 Multilingual Support
Support for three interface languages:
- 🇷🇺 Русский
- 🇬🇧 English
- 🇰🇷 한국어

## 🏗️ Project Architecture

```
glasswave/
├── src/                    # Web application (React + Vite)
│   ├── app/                # Application components
│   ├── hooks/              # Custom React hooks
│   ├── i18n/               # Localization system
│   ├── styles/             # Global styles
│   └── firebase.ts         # Firebase configuration
├── lib/                    # Mobile application (Flutter)
│   ├── models/             # Data models
│   ├── providers/          # State management (Riverpod)
│   ├── screens/            # App screens
│   ├── services/           # Business logic
│   ├── theme/              # Theme configuration
│   └── widgets/            # Reusable widgets
├── assets/translations/    # JSON translation files
├── android/                # Android platform
├── ios/                    # iOS platform
├── linux/                  # Linux platform
├── macos/                  # macOS platform
└── windows/                # Windows platform
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ and npm/pnpm
- **Flutter** 3.12+
- **Firebase project** (for synchronization)

### Installation

#### 1. Clone the repository

```bash
git clone https://github.com/yourusername/glasswave.git
cd glasswave
```

#### 2. Firebase Setup

Create a `.env` file in the project root. A ready-made template is available as
[`.env.example`](.env.example):

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

All six variables are **required**. If any are missing, the web app shows a
configuration error instead of connecting to an unrelated project.

> ⚠️ **Important**: Do not commit the `.env` file to the repository! It's already added to `.gitignore`.

---

## 💻 Web Version (React + Vite)

### Install Dependencies

```bash
npm install
# or
pnpm install
```

### Run in Development Mode

```bash
npm run dev
# or
pnpm dev
```

The app will be available at `http://localhost:5173`

### Build for Production

```bash
npm run build
# or
pnpm build
```

Built files will appear in the `dist/` directory.

### Quality Checks & Tests

```bash
npm run typecheck      # TypeScript type checking
npm run lint           # ESLint
npm run format:check   # Prettier
npm run test           # Vitest unit tests
npm run i18n:export    # Regenerate assets/translations/*.json from src/i18n
```

---

## 🤖 Android APK (Capacitor + React)

The Android APK is the **same React + Vite app**, wrapped with [Capacitor](https://capacitorjs.com). Flutter remains in `android/` / `lib/` for the native rewrite; Capacitor lives in `android-capacitor/`.

### Build the APK

```bash
npm install
npm run android:apk
```

The installable file is written to:

```
android-capacitor/app/build/outputs/apk/release/app-release.apk
```

Requirements: Node.js 22+, JDK 21, Android SDK (compileSdk 36).

You can also sync the web build into the native project without compiling Gradle:

```bash
npm run cap:sync
npx cap open android
```

---

### Web Tech Stack

- **React 18.3** — UI library
- **Vite 6.4** — Build tool
- **Tailwind CSS 4.1** — Styling
- **TipTap** — WYSIWYG editor
- **Lucide React** — Icons
- **Firebase** — Backend

---

## 📱 Mobile Version (Flutter)

> ⚠️ The Flutter app is a **local-only prototype**: notes and accounts are stored
> on-device (`shared_preferences`) and do **not** sync to Firebase yet. Use the
> React web app (or its Capacitor Android wrapper) for cross-device sync.

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

Or select a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

### Build for Various Platforms

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Desktop (Linux/macOS/Windows)
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

### Flutter Tech Stack

- **Flutter Riverpod** — State management
- **Google Fonts** — Typography
- **Easy Localization** — Localization
- **Lucide Icons Flutter** — Icons
- **Shared Preferences** — Local storage
- **Flutter Markdown** — Markdown rendering

---

## 📖 Usage

### Main Screens

| Screen | Description |
|--------|-------------|
| **Dashboard** | Main page with list of all notes |
| **Editor** | Create and edit notes |
| **Pinned** | Quick access to important notes |
| **Archive** | Archived notes |
| **Trash** | Deleted notes (before permanent deletion) |
| **Settings** | Account, theme, language management |

### Keyboard Shortcuts (Web Version)

- `Ctrl/Cmd + N` — Create new note
- `Ctrl/Cmd + F` — Search
- `Ctrl/Cmd + S` — Save note
- `Esc` — Close editor/modal

---

## 🌐 Localization

`src/i18n/translations.ts` is the **single source of truth** for all UI strings.
Both the React app and the Flutter app derive their strings from it.

Adding a new language or string:

1. Add the string to the `Translation` interface and all three language objects
   in `src/i18n/translations.ts`.
2. Run `npm run i18n:export` to regenerate `assets/translations/*.json` for the
   Flutter app (never edit those JSON files by hand).

Translation structure example:

```ts
{
  settings: "Settings",
  dashboard: "Notes",
  createNote: "Create note",
}
```

---

## 🔧 Configuration

### Firebase Rules

The `firestore.rules` file contains security rules for the database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Deploy to Firebase Hosting

```bash
npm run build
firebase deploy
```

---

## ♿ Accessibility

The web app targets keyboard and screen-reader accessibility:

- Note cards are focusable and open with `Enter`/`Space`.
- Modals trap focus, restore it on close, and close with `Esc`.
- `prefers-reduced-motion` disables animations.
- Interactive elements carry `aria-label`/`role` where needed.

---

## 🤝 Contributing

We welcome contributions to GlassWave development!

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style Guide

- **React**: ESLint + Prettier (`npm run lint`, `npm run format`)
- **Flutter**: `flutter analyze` + `dart format`

CI builds and publishes the Android APK from `main`
(`.github/workflows/apk_build.yml`).

---

## 📄 License

This project is distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Lucide Icons](https://lucide.dev) — Beautiful open-source icons
- [TipTap](https://tiptap.dev) — Powerful WYSIWYG editor
- [Firebase](https://firebase.google.com) — Backend as a service
- [Flutter](https://flutter.dev) — Cross-platform development

---

## 📞 Contact

- **Project**: GlassWave
- **Version**: 1.0.0

If you have any questions or suggestions, please create an issue in the repository.

---

<div align="center">

**Made with ❤️ using React, Flutter & Firebase**

</div>
