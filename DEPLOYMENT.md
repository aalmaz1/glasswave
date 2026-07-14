# Как задеплоить приложение на Cloudflare Pages

Это Flutter-приложение можно задеплоить на Cloudflare Pages двумя способами:

## Способ 1: Через GitHub Actions (рекомендуется)

### Шаг 1: Создайте проект в Cloudflare Pages
1. Зайдите в [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Перейдите в **Workers & Pages** → **Create application** → **Pages**
3. Нажмите **Connect to Git**
4. Выберите ваш репозиторий
5. Или создайте проект вручную, запомните **Account ID**

### Шаг 2: Получите API токен Cloudflare
1. Зайдите в [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Перейдите в **My Profile** → **API Tokens**
3. Нажмите **Create Token**
4. Выберите шаблон **Edit Cloudflare Workers** или создайте кастомный токен с правами:
   - `Account.Cloudflare Pages` → `Edit`
   - `Account.Account Settings` → `Read`
5. Скопируйте токен

### Шаг 3: Добавьте секреты в GitHub
1. Зайдите в ваш репозиторий на GitHub
2. Перейдите в **Settings** → **Secrets and variables** → **Actions**
3. Добавьте два секрета:
   - `CLOUDFLARE_API_TOKEN` — ваш API токен из шага 2
   - `CLOUDFLARE_ACCOUNT_ID` — ваш Account ID (можно найти в Cloudflare Dashboard справа внизу)

### Шаг 4: Запушьте изменения
Файл `.github/workflows/cloudflare_pages.yml` уже создан. Просто запушьте его в репозиторий:

```bash
git add .github/workflows/cloudflare_pages.yml
git commit -m "Add Cloudflare Pages deployment"
git push origin main
```

GitHub Actions автоматически запустит деплой при пуше в ветку `main` или `master`.

---

## Способ 2: Ручной деплой через Wrangler CLI (для glasswave Worker)

Если вы развёртываете glasswave Worker с статическими ассетами, используйте этот способ.

### Шаг 1: Установите Wrangler CLI
```bash
npm install -g wrangler
```

### Шаг 2: Авторизуйтесь в Cloudflare
```bash
wrangler login
```

### Шаг 3: Создайте файл wrangler.toml
Файл `wrangler.toml` уже создан в корне проекта со следующей конфигурацией:

```toml
name = "glasswave"
compatibility_date = "2026-07-14"
compatibility_flags = ["nodejs_compat"]

[assets]
directory = "./build/web"
not_found_handling = "single-page-application"
```

### Шаг 4: Соберите и задеплойте приложение
```bash
flutter build web --release --base-href "/"
npx wrangler deploy
```

Wrangler автоматически загрузит все файлы из `./build/web`, создаст привязку ASSETS и задеплоит Worker со статическими ассетами.

---

## Способ 3: Ручной деплой на Cloudflare Pages

Если вы используете Cloudflare Pages вместо Worker:

### Шаг 1: Установите Wrangler CLI
```bash
npm install -g wrangler
```

### Шаг 2: Авторизуйтесь в Cloudflare
```bash
wrangler login
```

### Шаг 3: Соберите и задеплойте приложение
```bash
flutter build web --release --base-href "/"
npx wrangler pages deploy build/web --project-name=premium-notes
```

---

## Проверка деплоя

После успешного деплоя ваше приложение будет доступно по адресу:
```
https://premium-notes.<your-subdomain>.pages.dev
```

Вы можете настроить кастомный домен в Cloudflare Dashboard в разделе **Workers & Pages** → Ваш проект → **Custom domains**.

---

## Примечания

- Убедитесь, что Firebase настроен для веб-платформы (файл `firebase_options.dart` должен содержать веб-конфигурацию)
- При первом деплое может потребоваться подтвердить проект в Cloudflare Dashboard
- Логи деплоя доступны в GitHub Actions или в Cloudflare Dashboard
