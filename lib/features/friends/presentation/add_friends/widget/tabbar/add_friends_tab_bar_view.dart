import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/widget/tabbar/recommend_friends_tab_bar_view.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/widget/tabbar/search_friends_tab_bar_view.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

class AddFriendsTabBarView extends StatelessWidget {
  const AddFriendsTabBarView({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FriendsController>();
    return TabBarView(
      controller: tabController,
      children: [
        Obx(
          () => controller.recommendations.isEmpty
              ? Center(
                  child: Image.asset(
                    'assets/icon/just_be_happy.png',
                    color: Colors.white,
                    scale: 3,
                  ),
                )
              : const RecommendsFriendsTabBarView(),
        ),
        const SearchFriendsTabBarView(),
      ],
    );
  }
}
