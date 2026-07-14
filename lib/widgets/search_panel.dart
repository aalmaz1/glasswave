import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../utils/glass_style.dart';

/// Поисковая панель (стеклянная таблетка)
class SearchPanel extends ConsumerWidget {
  final double scrollOffset;
  
  const SearchPanel({super.key, this.scrollOffset = 0});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final isSortActive = sortOption != SortOption.defaultOrder;
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        // Gradient fade to hide cards underneath
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.38),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: GlassContainer(
                  borderRadius: 50,
                  child: TextField(
                    onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск по заметкам…',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                              onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Sort button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GlassContainer(
                    borderRadius: 50,
                    child: IconButton(
                      icon: const Icon(Icons.sliders, color: Colors.amber),
                      onPressed: () => _showSortSheet(context, ref),
                    ),
                  ),
                  if (isSortActive)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Settings button
              GlassContainer(
                borderRadius: 50,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSortSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortSheet(currentOption: ref.read(sortOptionProvider)),
    ).then((_) {
      // Handle sort option change
    });
  }
}

/// Bottom sheet для сортировки
class SortSheet extends ConsumerWidget {
  final SortOption currentOption;
  
  const SortSheet({super.key, required this.currentOption});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(18, 18, 24, 0.96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Сортировка',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Options
          _SortOptionTile(
            icon: Icons.shuffle_outlined,
            title: 'По умолчанию',
            isSelected: currentOption == SortOption.defaultOrder,
            onTap: () {
              ref.read(sortOptionProvider.notifier).state = SortOption.defaultOrder;
              Navigator.pop(context);
            },
          ),
          _SortOptionTile(
            icon: Icons.calendar_today_outlined,
            title: 'Дата создания',
            isSelected: currentOption == SortOption.dateCreated,
            onTap: () {
              ref.read(sortOptionProvider.notifier).state = SortOption.dateCreated;
              Navigator.pop(context);
            },
          ),
          _SortOptionTile(
            icon: Icons.refresh_outlined,
            title: 'Дата изменения',
            isSelected: currentOption == SortOption.dateModified,
            onTap: () {
              ref.read(sortOptionProvider.notifier).state = SortOption.dateModified;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _SortOptionTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: isSelected
          ? Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.black87, size: 16),
            )
          : null,
      onTap: onTap,
    );
  }
}
