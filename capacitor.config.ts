import type { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
  appId: "com.glasswave.app",
  appName: "GlassWave",
  webDir: "dist",
  android: {
    path: "android-capacitor",
  },
  ios: {
    // `ios/` is Flutter's native project, so Capacitor's lives next to it.
    path: "ios-capacitor",
  },
  server: {
    androidScheme: "https",
  },
  plugins: {
    SystemBars: {
      insetsHandling: "css",
      style: "LIGHT",
      hidden: false,
    },
  },
};

export default config;
