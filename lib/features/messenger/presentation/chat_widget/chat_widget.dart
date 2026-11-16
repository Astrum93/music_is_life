import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/messenger/presentation/chat_widget/edit/edit_chat_image.dart';
import 'package:music_is_life/features/messenger/presentation/chat_widget/edit/edit_chat_name.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  CreateChatController get _controller => Get.find<CreateChatController>();

  // 이미지 수정 팝업창
  void showAlertChatImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: EditChatImage(),
        );
      },
    );
  }

  // 채팅방 이름 수정 팝업창
  void showAlertChatName(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: EditChatName(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          /// 흰 배경
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 140,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
            ),
          ),

          /// 채팅방 정보
          Positioned(
            top: 20,
            left: 40,
            child: Row(
              children: [
                /// 채팅방 대표 사진
                Center(
                  child: GestureDetector(
                    onTap: () {
                      showAlertChatImage(context);
                    },
                    child: Container(
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
                  ),
                ),

                width20,

                /// 채팅방 이름
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showAlertChatName(context);
                          },
                          child: SizedBox(
                            width: 120,
                            child: Text(
                              _controller.name.value.isEmpty
                                  ? '채팅방 이름'
                                  : _controller.name.value,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        /// 알람 아이콘
                        // Container(
                        //   width: 10,
                        //   height: 10,
                        //   decoration: const BoxDecoration(
                        //     color: Colors.grey,
                        //     borderRadius: BorderRadius.all(Radius.circular(30)),
                        //   ),
                        // )
                      ],
                    ),

                    /// 채팅 멤버
                    SizedBox(
                      width: 120,
                      child: Text(
                        _controller.members.isEmpty
                            ? '채팅 멤버'
                            : _controller.members.values.join(','),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// 즐겨찾기 버튼
          Positioned(
            top: 10,
            right: 35,
            child: IconButton(
              onPressed: () {},
              // 만드는 중인 방이라 즐겨찾기는 아직 꺼진 상태로 보여준다.
              icon: const Icon(
                Icons.stars_rounded,
                color: Colors.grey,
                size: 30,
              ),
            ),
          ),

          /// 채팅방 인원 수
          Positioned(
            right: 40,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  width10,
                  Text('${_controller.members.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
