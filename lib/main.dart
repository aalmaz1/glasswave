import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/app_providers.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Russian locale
  await initializeDateFormatting('ru', null);
  
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
    final themeId = ref.watch(themeIdProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final theme = AppTheme.all.firstWhere((t) => t.id == themeId, orElse: () => AppTheme.sunset);
    
    return MaterialApp(
      title: 'Noova Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        fontFamily: 'Manrope',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontSize)),
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
