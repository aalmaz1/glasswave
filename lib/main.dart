import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('ru'), Locale('ko')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ru'),
        child: const GlassWaveApp(),
      ),
    ),
  );
}

class GlassWaveApp extends ConsumerWidget {
  const GlassWaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'GlassWave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: user == null ? const AuthScreen() : const DashboardScreen(),
    );
  }
}
