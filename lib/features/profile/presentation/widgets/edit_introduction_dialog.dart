import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

/// 프로필 소개 변경 다이얼로그
///
/// 예전에는 입력창이 비어 있는 채로 열려서, 그냥 Save를 누르면 소개가 지워졌다.
/// 지금은 현재 소개를 채운 채로 연다.
class EditIntroductionDialog extends StatefulWidget {
  const EditIntroductionDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog(
        context: context,
        builder: (_) => const Dialog(child: EditIntroductionDialog()),
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
    final result = await _controller.updateIntroduction(_textController.text);
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
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const Text(
              '프로필 소개 변경',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // 프로필 소개 입력
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '내용을 입력해 주세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: border,
                  focusedBorder: border,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 저장 버튼
            Obx(
              () => _controller.isSaving.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text(
                        'Save',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
