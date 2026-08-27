#!/usr/bin/env node
/**
 * Generate the iOS app icon and launch screen from the app artwork
 * (`assets/icon.png`) so the native shell shows GlassWave's own branding
 * instead of the Capacitor placeholders.
 *
 * Writes:
 *   ios-capacitor/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png
 *     1024x1024, no alpha (App Store rejects icons with transparency).
 *   ios-capacitor/App/App/Assets.xcassets/Splash.imageset/splash-2732x2732.png
 *     the icon centred on the artwork's dark navy. A single file serves all
 *     three (@1x/@2x/@3x) Contents.json slots — they were byte-identical
 *     copies anyway — so the asset catalog only ships it once.
 *
 * Output PNGs are palette-quantized (libimagequant): visually identical for
 * this flat-color artwork, but several times smaller in the app bundle.
 *
 * `sharp` is not a permanent dependency of the project — these assets change
 * about never, so install it only when regenerating:
 *
 *   npm i -D sharp && node scripts/generate-ios-assets.mjs
 */

import fs from "node:fs";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);

let sharp;
try {
  sharp = require("sharp");
} catch {
  console.error(
    "This script needs sharp. Install it first:\n  npm i -D sharp && node scripts/generate-ios-assets.mjs"
  );
  process.exit(1);
}

const SOURCE = "assets/icon.png";
const ICON_OUT = "ios-capacitor/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png";
const SPLASH_DIR = "ios-capacitor/App/App/Assets.xcassets/Splash.imageset/";
/** One file, referenced by all three scale slots in Contents.json. */
const SPLASH_FILE = "splash-2732x2732.png";

const ICON_SIZE = 1024;
const SPLASH_SIZE = 2732;
const SPLASH_ICON_SIZE = 820;
/** Darkest navy of the artwork — keeps the launch screen seamless with it. */
const SPLASH_BG = { r: 12, g: 23, b: 42 };

const png = {
  palette: true,
  colors: 256,
  quality: 92,
  dither: 1.0,
  compressionLevel: 9,
  effort: 10,
};

// App icon: square crop, flattened (iOS icons must be fully opaque).
await sharp(SOURCE)
  .resize(ICON_SIZE, ICON_SIZE, { fit: "cover", position: "centre" })
  .flatten({ background: SPLASH_BG })
  .png(png)
  .toFile(ICON_OUT);
console.log(`wrote ${ICON_OUT} (${(fs.statSync(ICON_OUT).size / 1024).toFixed(0)} KB)`);

// Launch screen: the icon centred on the dark navy background.
const icon = await sharp(SOURCE)
  .resize(SPLASH_ICON_SIZE, SPLASH_ICON_SIZE, { fit: "cover", position: "centre" })
  .png()
  .toBuffer();

const splash = await sharp({
  create: { width: SPLASH_SIZE, height: SPLASH_SIZE, channels: 3, background: SPLASH_BG },
})
  .composite([{ input: icon, gravity: "centre" }])
  .png(png)
  .toBuffer();

fs.writeFileSync(SPLASH_DIR + SPLASH_FILE, splash);
console.log(
  `wrote ${SPLASH_DIR}${SPLASH_FILE} (${(splash.length / 1024).toFixed(0)} KB) — ` +
    `shared by the @1x/@2x/@3x Contents.json slots`
);
