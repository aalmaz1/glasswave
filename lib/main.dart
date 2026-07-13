import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/notes_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/note_editor_screen.dart';
import 'screens/settings_screen.dart';
import 'themes/app_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация локали для русского формата дат
  // await initializeDateFormatting('ru', null);
  
  runApp(
    const ProviderScope(
      child: PremiumNotesApp(),
    ),
  );
}

class PremiumNotesApp extends ConsumerWidget {
  const PremiumNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);

    return MaterialApp(
      title: 'Premium Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: AppFonts.textTheme,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB74D),
          surface: Color(0xFF121218),
        ),
      ),
      home: DashboardScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/editor':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => NoteEditorScreen(
                note: args?['note'] as Note?,
              ),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            );
          default:
            return null;
        }
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(state.fontSizeScale),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
