import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

class ChatBubbleWidget extends StatefulWidget {
  final String message;

  /// 보낸 사람 uid (UserInfo 문서 ID, 프로필 사진 조회용)
  final String senderUid;

  /// 화면에 보여줄 보낸 사람 이름
  final String senderName;
  final String time;
  final bool isMe;

  const ChatBubbleWidget(
      this.message, this.isMe, this.senderUid, this.senderName, this.time,
      {super.key});

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  // 보낸 사람 프로필 스트림을 build마다 새로 만들지 않도록 한 번만 만든다.
  late final Stream<UserProfile?> _sender =
      Get.find<MessengerController>().watchSender(widget.senderUid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _sender,
      builder: (context, snapshot) {
        // 탈퇴 등으로 프로필이 없어도 메시지는 보여준다. (예전에는 로딩만 계속 돌았다)
        final userProfileImage =
            snapshot.data?.profileImageUrl ?? baseProfileImage;
        return Row(
          mainAxisAlignment:
              widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            /// 보내는 사람이 본인인 경우
            if (widget.isMe)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ChatBubble(
                          clipper:
                              ChatBubbleClipper6(type: BubbleType.sendBubble),
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.only(top: 20),
                          backGroundColor: Colors.blue,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Text(
                              widget.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -18,
                          right: 0,
                          child: Text(
                            widget.time,
                            style: TextStyle(
                              color:
                                  AppColors.veryDarkGrey.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              userProfileImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

            /// 보내는 사람이 본인이 아닌 경우
            if (!widget.isMe)
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              userProfileImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ChatBubble(
                          clipper: ChatBubbleClipper6(
                              type: BubbleType.receiverBubble),
                          backGroundColor: const Color(0xffE7E7ED),
                          margin: const EdgeInsets.only(top: 20),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Text(
                              widget.message,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -18,
                          left: 0,
                          child: Text(
                            widget.time,
                            style: TextStyle(
                              color:
                                  AppColors.veryDarkGrey.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
          ],
        );
      },
    );
  }
}
