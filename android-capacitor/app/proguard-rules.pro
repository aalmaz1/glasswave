# GlassWave release build rules (R8 full mode).
#
# Capacitor wires Java <-> JS by reflection: @CapacitorPlugin/@PluginMethod
# annotated classes are looked up by name at bridge startup and their methods
# are invoked reflectively. @capacitor/android already ships these keeps as
# consumer rules, but we repeat them here in app scope so the build stays
# correct even if the library rules change upstream.
#
# Runtime annotations MUST survive: requestPermissions() looks up
# @PermissionCallback methods by name, and LocalNotifications 8.3 schedules
# alarms via BroadcastReceivers registered only in the plugin manifest.

-keepattributes *Annotation*,InnerClasses,Signature,EnclosingMethod,SourceFile,LineNumberTable
-renamesourcefileattribute GlassWave

-keep class com.getcapacitor.** { *; }
-keep class com.capacitorjs.** { *; }

-keep @com.getcapacitor.annotation.CapacitorPlugin public class * {
    @com.getcapacitor.annotation.PermissionCallback <methods>;
    @com.getcapacitor.annotation.ActivityCallback <methods>;
    @com.getcapacitor.annotation.Permission <methods>;
    @com.getcapacitor.PluginMethod public <methods>;
}
-keep public class * extends com.getcapacitor.Plugin { *; }

# Receivers / providers declared in plugin manifests (alarm fire, boot restore).
-keep public class * extends android.content.BroadcastReceiver { *; }
-keep public class * extends android.content.ContentProvider { *; }

# Cordova compatibility plugins.
-keep public class * extends org.apache.cordova.* {
    public <methods>;
    public <fields>;
}

# Anything exposed to JavaScript inside the WebView must survive obfuscation.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclasseswithmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Optional dependencies of bundled libraries that we intentionally do not ship.
-dontwarn org.apache.cordova.**
-dontwarn kotlinx.coroutines.**
