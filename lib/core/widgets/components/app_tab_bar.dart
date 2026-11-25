import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

class AppTabItem {
  const AppTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// 홈 · 검색 · 라운지 · 메신저
  static const defaults = <AppTabItem>[
    AppTabItem(
        label: '홈',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded),
    AppTabItem(
        label: '검색',
        icon: Icons.search_rounded,
        selectedIcon: Icons.manage_search_rounded),
    AppTabItem(
        label: '라운지',
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded),
    AppTabItem(
        label: '메신저',
        icon: Icons.chat_bubble_outline_rounded,
        selectedIcon: Icons.chat_bubble_rounded),
  ];
}

/// 하단 탭: 아이콘과 글자를 함께 보여주고, 현재 탭은 채운 아이콘으로 표시한다.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = AppTabItem.defaults,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppTabItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labelStyle = context.textStyles.labelSmall;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == currentIndex,
                    child: InkResponse(
                      onTap: () => onTap(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            i == currentIndex
                                ? items[i].selectedIcon
                                : items[i].icon,
                            size: 24,
                            color: i == currentIndex
                                ? c.textPrimary
                                : c.textTertiary,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            style: labelStyle?.copyWith(
                              color: i == currentIndex
                                  ? c.textPrimary
                                  : c.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
