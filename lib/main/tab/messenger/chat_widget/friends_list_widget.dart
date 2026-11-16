import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/friend_profile_widget.dart';
import 'package:music_is_life/main/tab/messenger/data/chat_data.dart';

class FriendsListWidget extends StatefulWidget {
  const FriendsListWidget({super.key});

  @override
  State<FriendsListWidget> createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget>
    with ChatDataProvider {
  @override
  void initState() {
    Get.put(ChatData());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ChatData>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: ListView.builder(
          itemCount: chatData.friendsUserInfoDocs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            String userName =
                chatData.friendsUserInfoDocs[index].get('userName');
            String friendUid = chatData.friendsUserInfoDocs[index].id;
            return GestureDetector(
              onTap: () {
                setState(() => chatData.toggleMember(friendUid, userName));
              },
              child: Column(
                children: [
                  FriendProfileWidget(
                      imageUrl: chatData.friendsUserInfoDocs[index]
                          .get('userProfileImage')
                          .toString(),
                      boxColor: Colors.transparent,
                      borderColor: chatData.member.contains(friendUid)
                          ? Colors.amberAccent
                          : AppColors.veryDarkGrey),
                  height10,
                  Text(
                    userName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
