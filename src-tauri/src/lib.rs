/// GlassWave desktop shell.
///
/// The real app is the React build in `dist/`; this shell only loads it in the
/// system webview (WebKitGTK on Linux), exactly like Capacitor does on Android.
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("error while running GlassWave");
}
