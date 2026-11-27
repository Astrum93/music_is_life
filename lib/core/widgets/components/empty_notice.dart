import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 목록이 비었을 때의 안내: 아이콘 · 제목 · 설명 · (선택) 버튼
class EmptyNotice extends StatelessWidget {
  const EmptyNotice({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l, vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: context.colors.textTertiary),
          const SizedBox(height: AppSpacing.s),
          Text(title, textAlign: TextAlign.center, style: t.titleMedium),
          const SizedBox(height: 2),
          Text(body, textAlign: TextAlign.center, style: t.bodySmall),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.l),
            action!,
          ],
        ],
      ),
    );
  }
}
