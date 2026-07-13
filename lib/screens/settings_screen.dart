import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../themes/app_theme.dart';

/// Экран настроек
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Seed данные для начальных заметок
  void _loadSeedData() {
    final now = DateTime.now();
    final seedNotes = [
      Note(
        id: now.subtract(const Duration(days: 10)).millisecondsSinceEpoch,
        title: 'Product Roadmap Q3',
        body: 'Основные цели на квартал:\n• Запуск мобильного приложения\n• Улучшение производительности на 40%\n• Интеграция с новыми API',
        updatedAt: now.subtract(const Duration(days: 2)),
        accentIdx: 0,
        pinned: true,
      ),
      Note(
        id: now.subtract(const Duration(days: 8)).millisecondsSinceEpoch,
        title: 'Design Sprint Notes',
        body: 'День 1: Определение проблемы\nДень 2: Поиск решений\nДень 3: Принятие решений\nДень 4: Прототипирование\nДень 5: Тестирование',
        updatedAt: now.subtract(const Duration(days: 5)),
        accentIdx: 1,
        pinned: true,
      ),
      Note(
        id: now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
        title: 'Reading List',
        body: '1. Clean Code - Robert Martin\n2. The Pragmatic Programmer\n3. Design Patterns\n4. Refactoring UI',
        updatedAt: now.subtract(const Duration(days: 7)),
        accentIdx: 2,
      ),
      Note(
        id: now.subtract(const Duration(days: 6)).millisecondsSinceEpoch,
        title: 'API Integration',
        body: 'Необходимо реализовать:\n- Authentication flow\n- Rate limiting\n- Error handling\n- Caching strategy',
        updatedAt: now.subtract(const Duration(days: 4)),
        accentIdx: 3,
      ),
      Note(
        id: now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        title: 'Weekly Reflection',
        body: 'Что прошло хорошо:\n• Завершил основной функционал\n• Получил фидбек от команды\n\nЧто можно улучшить:\n• Тайм-менеджмент\n• Коммуникация',
        updatedAt: now.subtract(const Duration(days: 1)),
        accentIdx: 0,
      ),
      Note(
        id: now.subtract(const Duration(days: 4)).millisecondsSinceEpoch,
        title: 'Miso Ramen Recipe',
        body: 'Ингредиенты:\n- Лапша рамен\n- Мисо паста\n- Бульон тонкоцу\n- Яйцо маринованное\n- Нарезанная свинина\n- Зелёный лук',
        updatedAt: now.subtract(const Duration(days: 3)),
        accentIdx: 1,
      ),
      Note(
        id: now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
        title: 'CSS Deep Dive',
        body: 'Темы для изучения:\n1. CSS Grid и Flexbox\n2. Анимации и transitions\n3. CSS Custom Properties\n4. Container Queries',
        updatedAt: now.subtract(const Duration(hours: 12)),
        accentIdx: 2,
        archived: true,
      ),
      Note(
        id: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        title: 'Kyoto Itinerary',
        body: 'День 1: Фусими Инари, Киёмидзу-дэра\nДень 2: Арасияма, Золотой павильон\nДень 3: Гион, храм Ясака',
        updatedAt: now.subtract(const Duration(hours: 6)),
        accentIdx: 3,
      ),
    ];

    ref.read(notesProvider.notifier).setNotes(seedNotes);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesProvider);
    final currentTheme = state.currentTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Фоновый градиент
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: currentTheme.bgGradient),
            ),
          ),
          // Орбы
          ...currentTheme.orbs.asMap().entries.map((entry) {
            final orb = entry.value;
            final index = entry.key;
            return Positioned(
              left: index == 0 ? -100 : null,
              right: index == 0 ? null : -80,
              top: 100 + (index == 0 ? 50 : -50),
              child: Container(
                width: orb.radius * 2,
                height: orb.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      orb.color.withOpacity(0.3),
                      orb.color.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          // Контент
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Настройки',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Выбор темы
                  const Text(
                    'ТЕМА',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 0.09.em,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: AppTheme.themes.length,
                    itemBuilder: (context, index) {
                      final theme = AppTheme.themes[index];
                      final isSelected = state.themeId == theme.id;
                      return GestureDetector(
                        onTap: () => ref.read(notesProvider.notifier).setThemeId(theme.id),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: theme.bgGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  theme.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 6,
                                  bottom: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFF1A1A1E),
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Размер шрифта
                  const Text(
                    'РАЗМЕР ШРИФТА',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 0.09.em,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FontSizeButton(
                          label: 'Маленький',
                          scale: 0.9,
                          isSelected: state.fontSizeScale == 0.9,
                          onTap: () => ref.read(notesProvider.notifier).setFontSizeScale(0.9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FontSizeButton(
                          label: 'Средний',
                          scale: 1.0,
                          isSelected: state.fontSizeScale == 1.0,
                          onTap: () => ref.read(notesProvider.notifier).setFontSizeScale(1.0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FontSizeButton(
                          label: 'Большой',
                          scale: 1.1,
                          isSelected: state.fontSizeScale == 1.1,
                          onTap: () => ref.read(notesProvider.notifier).setFontSizeScale(1.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Seed данные
                  GestureDetector(
                    onTap: _loadSeedData,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.data_usage_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Загрузить демо-заметки',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '8 примеров заметок для демонстрации',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.download_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Информация о приложении
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Notes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Версия 1.0.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Приложение создано в стиле премиального глассморфизма с 12 уникальными темами.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  final String label;
  final double scale;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeButton({
    required this.label,
    required this.scale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Colors.white.withOpacity(0.2) 
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.3) 
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
