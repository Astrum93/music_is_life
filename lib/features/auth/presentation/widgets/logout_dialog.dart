import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';

/// 로그아웃할지 묻고, [로그아웃]을 누르면 로그아웃한 뒤 웰컴으로 보낸다.
///
/// 홈에서 뒤로 가기를 눌렀을 때와 메뉴의 [로그아웃]에서 쓴다.
Future<void> confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => Theme(data: AppTheme.light, child: const LogoutDialog()),
  );
  if (ok != true) return;
  await Get.find<SessionController>().logout();
  Get.offAllNamed(Routes.welcome);
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Dialog(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXxl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: c.danger),
            ),
            const SizedBox(height: 14),
            Text('로그아웃할까요?', style: t.headlineSmall?.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.s),
            Text(
              '다시 로그인하면 기록한 이야기와\n스펙트럼은 그대로 있어요.',
              textAlign: TextAlign.center,
              style:
                  t.bodyMedium?.copyWith(fontSize: 14, color: c.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: c.background,
                      foregroundColor: c.textPrimary,
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: c.danger,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
