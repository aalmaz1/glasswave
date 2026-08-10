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
- **RSS integration** — load content from RSS feeds
- **Guest mode** — use without registration

### 🔐 Synchronization
- **Firebase Firestore** — cloud synchronization across devices
- **Local caching** — offline work with IndexedDB
- **Authentication** — secure login via Firebase Auth

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

Create a `.env` file in the project root:

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

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

### Web Tech Stack

- **React 18.3** — UI library
- **Vite 6.4** — Build tool
- **Tailwind CSS 4.1** — Styling
- **TipTap** — WYSIWYG editor
- **Lucide React** — Icons
- **Firebase** — Backend

---

## 📱 Mobile Version (Flutter)

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

Adding a new language:

1. Create a translation file in `assets/translations/<lang>.json`
2. Add translations in `src/i18n/index.tsx`
3. Update the language list in the settings component

Translation structure example:

```json
{
  "settings": "Settings",
  "dashboard": "Notes",
  "createNote": "Create note"
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

## 🤝 Contributing

We welcome contributions to GlassWave development!

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style Guide

- **React**: ESLint + Prettier
- **Flutter**: `flutter analyze` + `dart format`

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
