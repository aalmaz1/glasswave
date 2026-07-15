# Flutter Glassmorphism UI - Figma Replication

This document describes the implementation of a glassmorphic card interface based on the Figma design from `perch-yang-13730084.figma.site`.

## Design Specifications

### Background Gradient (5-stop Linear Gradient at 145deg)
- **Colors:** `rgb(19, 5, 0)` → `rgb(46, 12, 0)` → `rgb(74, 20, 0)` → `rgb(107, 30, 0)` → `rgb(138, 40, 0)`
- **Stops:** `[0.0, 0.28, 0.52, 0.75, 1.0]`
- **Implementation:** See `lib/models/theme_data.dart` - `figmaTheme`

### Glassmorphic Card
| Property | Value | Implementation |
|----------|-------|----------------|
| Blur | `backdrop-filter: blur(24px)` | `ImageFilter.blur(sigmaX: 24, sigmaY: 24)` |
| Fill | `rgba(255, 255, 255, 0.06)` | `Colors.white.withOpacity(0.06)` |
| Border | `0.9px solid rgba(255, 255, 255, 0.2)` | `Border.all(color: Colors.white.withOpacity(0.2), width: 0.9)` |
| Hover Transform | `translateY(-6px) scale(1.02)` | `Matrix4.identity()..translate(0, -6)..scale(1.02)` |
| Timing Function | `cubic-bezier(0.34, 1.56, 0.64, 1)` | `Cubic(0.34, 1.56, 0.64, 1)` |

### Typography
- **Font Family:** Manrope, Inter
- **Implementation:** Added Manrope to `pubspec.yaml` and set as default in `lib/main.dart`

### Icons
- **Set:** Lucide Icons
- **Implementation:** Created `lib/widgets/lucide_icon.dart` wrapper (ready for `lucide_icons` package)

### Layout
- **Grid Gap:** `14px`
- **Scroll Container Padding:** `92px` top, `24px` horizontal, `150px` bottom

## Files Modified

### 1. `pubspec.yaml`
- Added `lucide_icons: ^1.1.0` dependency
- Added Manrope font family configuration

### 2. `lib/main.dart`
- Changed default font from 'Roboto' to 'Manrope'

### 3. `lib/models/theme_data.dart`
- Updated `bgGradient` getter to support 5-color gradients with stops
- Added new `figmaTheme` with the exact gradient colors from Figma
- Added `figmaTheme` to the `Themes.all` list

### 4. `lib/widgets/glass_card.dart`
- Updated border width from `1` to `0.9` pixels
- Added `Cubic(0.34, 1.56, 0.64, 1)` animation curve
- Increased animation duration to `300ms`
- Applied Manrope font to card content via `DefaultTextStyle`

### 5. `lib/widgets/search_bar_widget.dart`
- Updated border width to `0.9` pixels
- Applied Manrope font to text field and hint

### 6. `lib/widgets/lucide_icon.dart` (New)
- Created wrapper widget for Lucide icons
- Provides fallback to Material icons until `lucide_icons` package is installed

## Usage

To use the Figma theme in your application:

```dart
import 'models/theme_data.dart';

// Set the Figma theme
final figmaTheme = Themes.figmaTheme;
```

## Font Installation

Before running the app, download the Manrope font files and place them in `assets/fonts/`:
- `Manrope-Regular.ttf`
- `Manrope-Medium.ttf`
- `Manrope-SemiBold.ttf`
- `Manrope-Bold.ttf`

Download from: https://fonts.google.com/specimen/Manrope

## Running the App

```bash
flutter pub get
flutter run
```

## Notes

- The hover effect (lift and scale) only works on platforms that support mouse input (web, desktop)
- On mobile, the hover state is ignored
- The backdrop filter effect requires hardware acceleration (enabled by default in Flutter)
