import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_providers.dart';
import '../utils/glass_style.dart';

/// Нижняя навигационная панель (стеклянная таблетка)
class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navTabProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1280;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Width calculation
    double navWidth;
    if (isDesktop) {
      navWidth = (width * 0.56).clamp(260.0, 420.0);
    } else {
      navWidth = width - 32;
    }
    
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: navWidth,
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: GlassContainer(
            borderRadius: 30,
            blurSigma: 28,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: LucideIcons.fileText,
                    activeIcon: LucideIcons.fileText,
                    label: 'Заметки',
                    isActive: currentTab == NavTab.notes,
                    onTap: () => ref.read(navTabProvider.notifier).state = NavTab.notes,
                    showLabel: !isDesktop,
                  ),
                  _NavItem(
                    icon: LucideIcons.archive,
                    activeIcon: LucideIcons.archive,
                    label: 'Архив',
                    isActive: currentTab == NavTab.archive,
                    onTap: () => ref.read(navTabProvider.notifier).state = NavTab.archive,
                    showLabel: !isDesktop,
                  ),
                  _NavItem(
                    icon: LucideIcons.trash2,
                    activeIcon: LucideIcons.trash2,
                    label: 'Корзина',
                    isActive: currentTab == NavTab.trash,
                    onTap: () => ref.read(navTabProvider.notifier).state = NavTab.trash,
                    showLabel: !isDesktop,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showLabel;
  
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showLabel = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Colors.white : Colors.white38,
            size: 24,
          ),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white : Colors.white38,
              ),
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 18,
              height: 2,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
