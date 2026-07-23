import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme_data.dart';
import '../widgets/glass_container.dart';
import '../widgets/background_orbs.dart';
import '../models/note.dart';
import 'auth_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          BackgroundOrbs(theme: theme),
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, color: Colors.white60),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      tr('settings_title'),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    _sectionLabel(LucideIcons.user, tr('settings_account')),
                    if (user == null)
                      _buildAuthPrompt(context)
                    else
                      _buildUserCard(ref, user),
                    const SizedBox(height: 36),
                    _sectionLabel(LucideIcons.palette, tr('settings_theme')),
                    const SizedBox(height: 12),
                    _buildThemeGrid(ref, prefs.themeId),
                    const SizedBox(height: 36),
                    _sectionLabel(LucideIcons.languages, tr('settings_lang')),
                    const SizedBox(height: 12),
                    _buildLanguageSelector(context, ref),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white30),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildAuthPrompt(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(tr('settings_sync'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            tr('settings_sync_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(tr('settings_auth_btn')),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(WidgetRef ref, dynamic user) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
            child: const Icon(LucideIcons.user, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.check, size: 10, color: Colors.greenAccent),
                      const SizedBox(width: 4),
                      Text(tr('settings_synced'), style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (ctx) {
              return IconButton(
                icon: const Icon(LucideIcons.logOut, color: Colors.white38, size: 18),
                onPressed: () => _logout(ctx, ref),
              );
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext ctx, WidgetRef ref) {
    ref.read(notesProvider.notifier).clearNotes();
    ref.read(authProvider.notifier).logout();
    ref.read(themeProvider.notifier).setTheme(ThemeId.sunset);
    ref.read(themeProvider.notifier).setLanguage('ru');
    EasyLocalization.of(ctx)!.setLocale(const Locale('ru'));
    _seedNotes(ref);
  }

  void _seedNotes(WidgetRef ref) {
    final now = DateTime.now();
    final seedNotes = [
      Note(id: now.millisecondsSinceEpoch - 3000, title: tr('editor_no_title'), body: "Это ваша первая заметка.\n\n- Поддержка Markdown\n- Напоминания\n- Архивация", updatedAt: now.subtract(const Duration(minutes: 5)), accentIdx: 0, pinned: true),
      Note(id: now.millisecondsSinceEpoch - 2000, title: tr('editor_edit'), body: "## Что можно делать?\n\n1. Создавать заметки\n2. Архивировать старые\n3. Устанавливать напоминания\n4. Сортировать по дате", updatedAt: now.subtract(const Duration(minutes: 2)), accentIdx: 1),
      Note(id: now.millisecondsSinceEpoch - 1000, title: tr('editor_new'), body: "Используйте закрепление для важных заметок.", updatedAt: now, accentIdx: 2),
    ];
    for (final n in seedNotes) {
      ref.read(notesProvider.notifier).addNote(n);
    }
  }

  Widget _buildThemeGrid(WidgetRef ref, ThemeId current) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: allThemes.length,
      itemBuilder: (context, index) {
        final t = allThemes[index];
        final active = t.id == current;
        return GestureDetector(
          onTap: () => ref.read(themeProvider.notifier).setTheme(t.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: active ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1), width: active ? 2 : 1),
              boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))] : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: t.bg,
                    ),
                    child: Stack(
                      children: t.orbs.take(2).map((orb) {
                        return Positioned(
                          top: 20 + (orb.top * 40),
                          left: 20 + (orb.left * 40),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [orb.color, Colors.transparent],
                                stops: const [0.0, 0.7],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (active)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Icon(LucideIcons.check, size: 12, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('language'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _langButton(context, ref, 'ru', '🇷🇺 Русский'),
              const SizedBox(width: 12),
              _langButton(context, ref, 'ko', '🇰🇷 한국어'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _langButton(BuildContext context, WidgetRef ref, String langCode, String label) {
    final isActive = EasyLocalization.of(context)!.locale.languageCode == langCode;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final locale = Locale(langCode);
          await EasyLocalization.of(context)!.setLocale(locale);
          ref.read(themeProvider.notifier).setLanguage(langCode);
          final email = ref.read(authProvider)?.email;
          if (email != null) {
            await ref.read(persistenceServiceProvider).saveLanguage(email, langCode);
          } else {
            await ref.read(persistenceServiceProvider).saveLanguage('guest', langCode);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.amber.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.amber : Colors.white.withValues(alpha: 0.2),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.amber : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: Colors.amber, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
