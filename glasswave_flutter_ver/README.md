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

### Android size and release builds

The source code is not what makes a Flutter APK large: a Flutter release also
contains the native Flutter engine and, unless split, native binaries for every
CPU architecture. A debug/universal APK can therefore be around 100–115 MB even
when the Dart code is small. It should not be used as the download artifact.

Use an Android App Bundle for Play Store distribution (Google delivers only the
right ABI to each device), or build ABI-specific APKs for direct downloads:

```bash
# Recommended for Google Play
flutter build appbundle --release

# Direct APK downloads: produces arm64, arm32 and x86_64 APKs separately
flutter build apk --release --split-per-abi
```

The Android Gradle configuration disables the universal APK as an additional
safeguard. This changes packaging only, not runtime behavior or UI. Unused
`flutter_markdown` and `flutter_staggered_grid_view` dependencies were also
removed; the editor uses its own Markdown field and the dashboard uses native
rows.

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
