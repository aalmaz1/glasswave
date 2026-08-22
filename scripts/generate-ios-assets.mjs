#!/usr/bin/env node
/**
 * Generate the iOS app icon and launch screen from the app artwork
 * (`assets/icon.png`) so the native shell shows GlassWave's own branding
 * instead of the Capacitor placeholders.
 *
 * Writes:
 *   ios-capacitor/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png
 *     1024x1024, no alpha (App Store rejects icons with transparency).
 *   ios-capacitor/App/App/Assets.xcassets/Splash.imageset/splash-2732x2732*.png
 *     the icon centred on the artwork's dark navy, one file per @1x/@2x/@3x slot.
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
const SPLASH_FILES = [
  "splash-2732x2732.png", // @3x
  "splash-2732x2732-1.png", // @2x
  "splash-2732x2732-2.png", // @1x
];

const ICON_SIZE = 1024;
const SPLASH_SIZE = 2732;
const SPLASH_ICON_SIZE = 820;
/** Darkest navy of the artwork — keeps the launch screen seamless with it. */
const SPLASH_BG = { r: 12, g: 23, b: 42 };

const png = { compressionLevel: 9, effort: 10, adaptiveFiltering: true };

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

for (const file of SPLASH_FILES) fs.writeFileSync(SPLASH_DIR + file, splash);
console.log(
  `wrote ${SPLASH_FILES.length} x ${SPLASH_DIR}splash-2732x2732*.png ` +
    `(${(splash.length / 1024).toFixed(0)} KB each)`
);
