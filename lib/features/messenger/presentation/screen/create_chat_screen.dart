import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/scaffold/custom_snackbar.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/messenger/presentation/chat_widget/chat_widget.dart';
import 'package:music_is_life/features/messenger/presentation/chat_widget/friends_list_widget.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  CreateChatController get _controller => Get.find<CreateChatController>();

  Future<void> _create() async {
    final result = await _controller.create();
    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.of(context).pop();
      case Failed(failure: InvalidRequestFailure(:final message)):
        CustomSnackBar.buildTopRoundedSnackBar(
            context, message, Colors.redAccent, Colors.white, 3);
      case Failed(:final failure):
        CustomSnackBar.buildTopRoundedSnackBar(
            context, failure.message, Colors.grey, Colors.white, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              height30,
              const Center(
                child: Text(
                  '새로운 \n채　팅',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
              ),
              const Height(50),
              const Text(
                '* 채팅방 사진과 채팅방 이름을 터치 하여 변경할 수 있습니다.',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              const Height(20),

              /// 채팅방 Widget
              const ChatWidget(),

              const Height(60),

              const Center(
                child: Text(
                  '친구 목록',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),

              height20,
              const Text(
                '* 채팅방에 추가하고 싶은 친구의 프로필을 선택하여 추가할 수 있습니다.',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              height20,

              /// 친구 목록
              const FriendsListWidget(),

              /// 생성 버튼
              Center(
                child: CheckButton(
                  width: 50,
                  height: 50,
                  icon: Icons.check,
                  iconColor: Colors.greenAccent,
                  borderColor: AppColors.veryDarkGrey,
                  onTap: _create,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
