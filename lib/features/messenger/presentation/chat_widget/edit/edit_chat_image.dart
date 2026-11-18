import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';

class EditChatImage extends StatefulWidget {
  const EditChatImage({super.key});

  @override
  State<EditChatImage> createState() => _EditChatImageState();
}

class _EditChatImageState extends State<EditChatImage> {
  CreateChatController get _controller => Get.find<CreateChatController>();

  // Image 저장 변수
  File? pickedImage;

  // Image Picker
  // 예전에는 사진 선택을 취소하면 pickedImage!에서 앱이 멈추고, 업로드 표시도 풀리지 않았다.
  Future<void> _pickerImage() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImageFile == null) return;
    setState(() => pickedImage = File(pickedImageFile.path));

    final result = await _controller.uploadImage(pickedImage!);
    if (result case Failed(:final failure) when mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.only(top: 10),
          width: 160,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const Height(10),
              const Text(
                '채팅방 이미지 변경',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // 프로필 이미지
              GestureDetector(
                onTap: () {
                  _pickerImage();
                },
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.veryDarkGrey,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: _controller.imageUrl.value.isEmpty
                          ? const Icon(
                              Icons.add,
                              color: Colors.grey,
                              size: 40,
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  _controller.imageUrl.value,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                    ),
                    if (_controller.isUploading.value)
                      const Positioned(
                        bottom: -50,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              height10,
              if (!_controller.isUploading.value)
                // 닫기 버튼
                TextButton.icon(
                  onPressed: () {
                    try {
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '이미지가 선택되지 않았습니다.',
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ));
  }
}
