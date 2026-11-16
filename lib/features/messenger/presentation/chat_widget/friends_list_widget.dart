import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/friend_profile_widget.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

/// 새 채팅방에 초대할 친구 선택 (누르면 추가/제외)
class FriendsListWidget extends StatelessWidget {
  const FriendsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<CreateChatController>();
    final friends = Get.find<FriendsController>();
    return Obx(() {
      final profiles = friends.friendProfiles.toList();
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: ListView.builder(
          itemCount: profiles.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final friend = profiles[index];
            final selected = chat.isMember(friend.uid);
            return GestureDetector(
              onTap: () => chat.toggleMember(friend.uid, friend.userName),
              child: Column(
                children: [
                  FriendProfileWidget(
                      imageUrl: friend.profileImageUrl,
                      boxColor: Colors.transparent,
                      borderColor: selected
                          ? Colors.amberAccent
                          : AppColors.veryDarkGrey),
                  height10,
                  Text(
                    friend.userName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
