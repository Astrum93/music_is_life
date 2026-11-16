import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/friends/presentation/favorites/widget/profile_list_view.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

/// 팔로잉 / 팔로워 탭
class FavoritesTabBarView extends StatelessWidget {
  const FavoritesTabBarView({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FriendsController>();
    return Expanded(
      child: TabBarView(
        controller: tabController,
        children: [
          Obx(() =>
              ProfileListView(profiles: controller.followingProfiles.toList())),
          Obx(() =>
              ProfileListView(profiles: controller.followerProfiles.toList())),
        ],
      ),
    );
  }
}
