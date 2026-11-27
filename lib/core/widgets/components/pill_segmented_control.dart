import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 알약 모양 토글: 라운지 [전체 | 내 게시물], 검색 [사용자 | 이야기]
class PillSegmentedControl extends StatelessWidget {
  const PillSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.textStyles.labelLarge?.copyWith(fontSize: 13);
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: c.surfaceMuted, borderRadius: AppRadius.borderFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            Semantics(
              button: true,
              selected: i == selectedIndex,
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? c.surface : Colors.transparent,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    labels[i],
                    style: style?.copyWith(
                      color:
                          i == selectedIndex ? c.textPrimary : c.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
