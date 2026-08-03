# GlassWave

GlassWave — заметки в стиле glassmorphism.

## Структура репозитория

- `src/` — веб-приложение (React + Vite + Firebase)
- `lib/` — приложение на Flutter (мобильные и десктопные платформы)
- `android/`, `ios/`, `linux/`, `macos/`, `windows/` — платформенные обёртки Flutter

## Веб-версия (React)

```bash
npm install
npm run dev      # режим разработки
npm run build    # сборка в dist/
```

## RSS-лента (гостевой режим)

В гостевом режиме заметки заполняются из RSS-ленты. Загрузка устроена
как цепочка провайдеров с таймаутами (см. `loadRssNotes` в
`src/app/App.tsx`):

1. **`/api/rss`** — Cloudflare Pages Function (`functions/api/rss.ts`).
   Лента запрашивается на сервере с жёстким таймаутом (8 с), поэтому
   CORS и публичные прокси не нужны. Функции публикуются автоматически
   при деплое на Cloudflare Pages из директории `functions/`.
2. **`api.rss2json.com`** — выделенный RSS-to-JSON API (резерв).
3. **`corsproxy.io`** — универсальный прокси (последний резерв).

Если сеть недоступна совсем, показывается кэш последней удачной ленты
из `localStorage`, иначе — локальный демо-набор. Проверить функцию
локально можно так:

```bash
npm run build && npx wrangler pages dev dist
# затем: curl http://localhost:8788/api/rss
```

## Flutter-версия

```bash
flutter pub get
flutter run
```
