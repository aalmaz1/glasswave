import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/data_initializer.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Russian locale
  await initializeDateFormatting('ru', null);
  
  // Initialize Hive and seed data
  await DataInitializer.initialize();

  runApp(
    const ProviderScope(
      child: NoovaApp(),
    ),
  );
}

class NoovaApp extends ConsumerWidget {
  const NoovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);

    return MaterialApp(
      title: 'Noova Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        textTheme: GoogleFonts.manropeTextTheme(
          const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(fontSize)),
          child: child!,
        );
      },
      home: const DashboardScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
