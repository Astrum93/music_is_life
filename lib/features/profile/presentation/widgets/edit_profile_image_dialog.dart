import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

/// 프로필 사진 / 배경 사진 변경 다이얼로그
///
/// 예전에는 사진·배경 다이얼로그가 거의 같은 코드로 따로 있었고,
/// 저장을 기다리지 않은 채 마이페이지를 새로 push해서 화면이 계속 쌓였다.
class EditProfileImageDialog extends StatefulWidget {
  const EditProfileImageDialog({super.key, required this.kind});

  final ProfileImageKind kind;

  static Future<void> show(BuildContext context, ProfileImageKind kind) =>
      showDialog(
        context: context,
        builder: (_) => Dialog(child: EditProfileImageDialog(kind: kind)),
      );

  @override
  State<EditProfileImageDialog> createState() => _EditProfileImageDialogState();
}

class _EditProfileImageDialogState extends State<EditProfileImageDialog> {
  File? _pickedImage;

  ProfileController get _controller => Get.find<ProfileController>();

  String get _title => switch (widget.kind) {
        ProfileImageKind.profile => '프로필 이미지 변경',
        ProfileImageKind.background => '프로필 배경 이미지 변경',
      };

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 300,
    );
    if (file != null) setState(() => _pickedImage = File(file.path));
  }

  Future<void> _saveOrClose() async {
    final image = _pickedImage;
    if (image == null) {
      Navigator.of(context).pop();
      return;
    }
    final result = await _controller.updateImage(widget.kind, image);
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
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 160,
      height: 310,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Obx(() {
        final saving = _controller.isSaving.value;
        return Column(
          children: [
            Text(
              _title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // 선택한 이미지 미리보기
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage:
                  _pickedImage != null ? FileImage(_pickedImage!) : null,
            ),
            const SizedBox(height: 2),

            // 업로드 버튼
            TextButton(
              onPressed: saving ? null : _pickImage,
              child: const Text(
                'Upload',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // 저장 / 닫기 버튼 (이미지를 골랐으면 저장)
            saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    onPressed: _saveOrClose,
                    icon: Icon(
                      _pickedImage != null ? Icons.save_alt_rounded : Icons.close,
                    ),
                    label: Text(
                      _pickedImage != null ? 'Save' : 'Close',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
          ],
        );
      }),
    );
  }
}
