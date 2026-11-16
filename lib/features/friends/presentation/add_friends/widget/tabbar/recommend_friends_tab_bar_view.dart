import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/friend_profile_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/request_friends_dialog.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

/// 추천 친구 (나와 이미 친구인 사용자 제외). 길게 누르면 친구 추가.
class RecommendsFriendsTabBarView extends StatelessWidget {
  const RecommendsFriendsTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FriendsController>();
    return Scaffold(
      body: Obx(() {
        final profiles = controller.recommendations.toList();
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 150,
          ),
          itemCount: profiles.length,
          itemBuilder: (context, index) => GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) =>
                    RequestFriendDialog(profile: profiles[index]),
              );
            },
            child: Column(
              children: [
                FriendProfileWidget(
                  imageUrl: profiles[index].profileImageUrl,
                  borderColor: Colors.transparent,
                  boxColor: switch (index) {
                    0 => Colors.redAccent,
                    1 => Colors.blue,
                    2 => Colors.greenAccent,
                    _ => AppColors.veryDarkGrey,
                  },
                ),
                height10,
                Text(
                  profiles[index].userName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
