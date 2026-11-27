import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

/// 소개 수정 창
///
/// 예전에는 입력창이 비어 있는 채로 열려서, 그냥 Save를 누르면 소개가 지워졌다.
/// 지금은 현재 소개를 채운 채로 연다.
class EditIntroductionDialog extends StatefulWidget {
  const EditIntroductionDialog({super.key});

  /// 소개 최대 글자 수 (미니 프로필에서 네 줄 안에 보이는 정도)
  static const maxLength = 100;

  static Future<void> show(BuildContext context) => showDialog(
        context: context,
        builder: (_) => Theme(
          data: AppTheme.light,
          child: const EditIntroductionDialog(),
        ),
      );

  @override
  State<EditIntroductionDialog> createState() => _EditIntroductionDialogState();
}

class _EditIntroductionDialogState extends State<EditIntroductionDialog> {
  ProfileController get _controller => Get.find<ProfileController>();

  late final _textController = TextEditingController(
    text: _controller.profile.value?.introduction ?? '',
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final result =
        await _controller.updateIntroduction(_textController.text.trim());
    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.of(context).pop();
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('소개 수정', style: t.headlineSmall?.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text('미니 프로필과 내 일기장에 보여요.',
                style: t.bodySmall?.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpacing.l),
            TextField(
              controller: _textController,
              autofocus: true,
              minLines: 3,
              maxLines: 5,
              maxLength: EditIntroductionDialog.maxLength,
              keyboardType: TextInputType.multiline,
              style: t.bodyMedium,
              decoration: InputDecoration(
                hintText: '어떤 노래로 위로받는 사람인지 적어 보세요.',
                fillColor: c.background,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Obx(() {
              final saving = _controller.isSaving.value;
              return Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          saving ? null : () => Navigator.of(context).pop(),
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
                      onPressed: saving ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        disabledBackgroundColor: c.textPrimary,
                        disabledForegroundColor: c.surface,
                      ),
                      child: saving
                          ? SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: c.surface),
                            )
                          : const Text('저장'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
