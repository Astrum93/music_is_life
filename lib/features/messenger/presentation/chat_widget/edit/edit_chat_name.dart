import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';

class EditChatName extends StatefulWidget {
  const EditChatName({super.key});

  @override
  State<EditChatName> createState() => _EditChatNameState();
}

class _EditChatNameState extends State<EditChatName> {
  CreateChatController get _controller => Get.find<CreateChatController>();

  String? chatName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 250,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Height(20),
          const Text(
            '채팅방 이름 변경',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Height(20),
          SizedBox(
            width: 200,
            child: TextFormField(
              key: const ValueKey(1),
              keyboardType: TextInputType.text,
              style: const TextStyle(
                color: Colors.white,
              ),
              cursorColor: Colors.amberAccent,
              decoration: const InputDecoration(
                hintText: '채팅방 이름을 입력해 주세요.',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                contentPadding: EdgeInsets.all(10),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  chatName = value;
                });
              },
            ),
          ),
          const Height(25),
          CheckButton(
            width: 35,
            height: 35,
            borderColor: AppColors.veryDarkGrey,
            icon: Icons.check,
            iconColor: Colors.greenAccent,
            onTap: () {
              // 예전에는 아무것도 입력하지 않고 확인을 누르면 "알수없는 오류" 메시지가 떴다.
              if (chatName != null && chatName!.trim().isNotEmpty) {
                _controller.name.value = chatName!.trim();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
