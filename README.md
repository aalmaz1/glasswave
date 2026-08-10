# 🌊 GlassWave

**Современное кроссплатформенное приложение для заметок в стиле glassmorphism**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.12+-blue?logo=flutter)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-18.3+-61dafb?logo=react)](https://reactjs.org)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)](https://firebase.google.com)

GlassWave — это элегантное приложение для управления заметками с современным дизайном в стиле glassmorphism, поддержкой синхронизации через Firebase и мультиязычным интерфейсом.

## ✨ Особенности

### 🎨 Дизайн
- **Glassmorphism UI** — полупрозрачные элементы с размытием фона
- **Адаптивный интерфейс** — оптимизирован для мобильных и десктопных устройств
- **Плавные анимации** — приятные переходы между экранами

### 📝 Функциональность
- **Создание и редактирование заметок** — поддержка заголовков и форматированного текста
- **Организация** — закрепление, архивирование, корзина
- **Поиск и сортировка** — быстрый поиск по заметкам, сортировка по дате создания/обновления
- **Напоминания** — установка напоминаний для важных заметок
- **RSS-интеграция** — загрузка контента из RSS-лент
- **Гостевой режим** — использование без регистрации

### 🔐 Синхронизация
- **Firebase Firestore** — облачная синхронизация между устройствами
- **Локальное кэширование** — работа офлайн с IndexedDB
- **Аутентификация** — безопасный вход через Firebase Auth

### 🌍 Мультиязычность
Поддержка трёх языков интерфейса:
- 🇷🇺 Русский
- 🇬🇧 English
- 🇰🇷 한국어

## 🏗️ Архитектура проекта

```
glasswave/
├── src/                    # Веб-приложение (React + Vite)
│   ├── app/                # Компоненты приложения
│   ├── hooks/              # Custom React хуки
│   ├── i18n/               # Система локализации
│   ├── styles/             # Глобальные стили
│   └── firebase.ts         # Конфигурация Firebase
├── lib/                    # Мобильное приложение (Flutter)
│   ├── models/             # Модели данных
│   ├── providers/          # State management (Riverpod)
│   ├── screens/            # Экраны приложения
│   ├── services/           # Бизнес-логика
│   ├── theme/              # Темы оформления
│   └── widgets/            # Переиспользуемые виджеты
├── assets/translations/    # JSON файлы переводов
├── android/                # Android платформа
├── ios/                    # iOS платформа
├── linux/                  # Linux платформа
├── macos/                  # macOS платформа
└── windows/                # Windows платформа
```

## 🚀 Быстрый старт

### Предварительные требования

- **Node.js** 18+ и npm/pnpm
- **Flutter** 3.12+
- **Firebase проект** (для синхронизации)

### Установка

#### 1. Клонирование репозитория

```bash
git clone https://github.com/yourusername/glasswave.git
cd glasswave
```

#### 2. Настройка Firebase

Создайте файл `.env` в корне проекта:

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

> ⚠️ **Важно**: Не коммитьте файл `.env` в репозиторий! Он уже добавлен в `.gitignore`.

---

## 💻 Веб-версия (React + Vite)

### Установка зависимостей

```bash
npm install
# или
pnpm install
```

### Запуск в режиме разработки

```bash
npm run dev
# или
pnpm dev
```

Приложение будет доступно по адресу `http://localhost:5173`

### Сборка для продакшена

```bash
npm run build
# или
pnpm build
```

Собранные файлы появятся в директории `dist/`

### Технологический стек веба

- **React 18.3** — UI библиотека
- **Vite 6.4** — Сборщик
- **Tailwind CSS 4.1** — Стилизация
- **TipTap** — WYSIWYG редактор
- **Lucide React** — Иконки
- **Firebase** — Бэкенд

---

## 📱 Мобильная версия (Flutter)

### Установка зависимостей

```bash
flutter pub get
```

### Запуск приложения

```bash
flutter run
```

Или выберите конкретное устройство:

```bash
flutter devices
flutter run -d <device_id>
```

### Сборка для различных платформ

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

### Технологический стек Flutter

- **Flutter Riverpod** — Управление состоянием
- **Google Fonts** — Типографика
- **Easy Localization** — Локализация
- **Lucide Icons Flutter** — Иконки
- **Shared Preferences** — Локальное хранение
- **Flutter Markdown** — Рендеринг Markdown

---

## 📖 Использование

### Основные экраны

| Экран | Описание |
|-------|----------|
| **Dashboard** | Главная страница со списком всех заметок |
| **Редактор** | Создание и редактирование заметок |
| **Закреплённые** | Быстрый доступ к важным заметкам |
| **Архив** | Заархивированные заметки |
| **Корзина** | Удалённые заметки (перед окончательным удалением) |
| **Настройки** | Управление аккаунтом, темой, языком |

### Горячие клавиши (веб-версия)

- `Ctrl/Cmd + N` — Создать новую заметку
- `Ctrl/Cmd + F` — Поиск
- `Ctrl/Cmd + S` — Сохранить заметку
- `Esc` — Закрыть редактор/модалку

---

## 🌐 Локализация

Добавление нового языка:

1. Создайте файл перевода в `assets/translations/<lang>.json`
2. Добавьте переводы в `src/i18n/index.tsx`
3. Обновите список языков в компоненте настроек

Пример структуры перевода:

```json
{
  "settings": "Настройки",
  "dashboard": "Заметки",
  "createNote": "Создать заметку"
}
```

---

## 🔧 Конфигурация

### Firebase Rules

Файл `firestore.rules` содержит правила безопасности для базы данных:

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

### Развёртывание на Firebase Hosting

```bash
npm run build
firebase deploy
```

---

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие GlassWave!

1. Forkните репозиторий
2. Создайте ветку для вашей фичи (`git checkout -b feature/amazing-feature`)
3. Закоммитьте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

### Руководство по стилю кода

- **React**: ESLint + Prettier
- **Flutter**: `flutter analyze` + `dart format`

---

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. Подробнее см. в файле [LICENSE](LICENSE).

---

## 🙏 Благодарности

- [Lucide Icons](https://lucide.dev) — красивые открытые иконки
- [TipTap](https://tiptap.dev) — мощный WYSIWYG редактор
- [Firebase](https://firebase.google.com) — бэкенд как сервис
- [Flutter](https://flutter.dev) — кроссплатформенная разработка

---

## 📞 Контакты

- **Проект**: GlassWave
- **Версия**: 1.0.0

Если у вас возникли вопросы или предложения, пожалуйста, создайте issue в репозитории.

---

<div align="center">

**Made with ❤️ using React, Flutter & Firebase**

</div>
