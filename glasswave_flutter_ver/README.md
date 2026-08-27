# GlassWave — Flutter port

The Flutter version of GlassWave. **The React + Vite app in [`../src`](../src) is the
design reference** — every colour, radius, blur, font size and layout rule here is
ported from it. Nothing in the web app should ever be changed to match this port;
it is the other way around.

Local-only: notes, accounts (SHA-256 hash) and preferences live in
`shared_preferences`. No Firebase, no cloud sync.

```bash
cd glasswave_flutter_ver
flutter pub get
flutter run
```

Dart SDK `^3.12.2` (see [`pubspec.yaml`](pubspec.yaml)).

## Layout

```
lib/
  main.dart               MaterialApp, Manrope text theme, dashboard entry point
  models/                 Note, AppUser
  providers/              Riverpod state (auth, notes, theme/language, tab, sort)
  services/
    persistence_service.dart   shared_preferences storage
    welcome_notes.dart         ephemeral intro cards (React `buildWelcomeNotes`)
  screens/                dashboard, editor modal, settings
  theme/
    design_tokens.dart    the React `G` tokens (glass fill, borders, shadows…)
    app_theme_data.dart   the 12 themes: CSS gradient angle, stops, orbs, accents
  widgets/                glass container, note card, orbs, confirm & reminder modals
assets/translations/      generated from src/i18n/translations.ts — never edit by hand
android/ ios/ linux/ macos/ windows/   Flutter platform shells
```

## Design parity notes

- **Tokens** — `lib/theme/design_tokens.dart` mirrors `src/app/theme.ts` (`G`,
  `glassBase()`), and `GlassContainer` reproduces the `.card-glass` +
  `.glass-ring` + `.glass-sheen` + inset-edge stack, including the hover state.
- **Backgrounds** — themes store the CSS gradient angle (`145deg`, `158deg`, …)
  and `bgGradient(size)` converts it to Flutter alignments so the gradient runs
  in exactly the same direction as in the browser. Orbs use the same radial
  stops (`0 → 68%`), `blur(2px)` and `scrollTop * (0.07 + i * 0.05)` parallax.
- **Flow** — like the web app, the dashboard is the entry point. Guests get the
  four ephemeral welcome cards (read-only, reserved negative ids); sign-in and
  registration live inside Settings, not behind a login wall.
- **Breakpoints** — 768 / 1280 for mobile / tablet / desktop, 920 / 1220 max
  content width, 1 / 2 / 3 grid columns, identical paddings and font sizes.

Known, deliberate differences (platform limits, not styling drift):

- the editor is a Markdown text field with the same toolbar, not a TipTap
  WYSIWYG surface;
- no cloud sync, so there is no Firestore error/retry UI, no "load more" button
  and no password-reset link;
- reminders are stored but not delivered as OS notifications.

## Translations

Strings come from the single source of truth in
[`../src/i18n/translations.ts`](../src/i18n/translations.ts). Regenerate the JSON
from the repository root:

```bash
npm run i18n:export     # writes glasswave_flutter_ver/assets/translations/{ru,en,ko}.json
```
