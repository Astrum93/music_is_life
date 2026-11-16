import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/widget/tabbar/add_friends_tab_bar.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/widget/tabbar/add_friends_tab_bar_view.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

/// 친구 찾기 (추천 / 검색)
class AddFriendsFragment extends StatefulWidget {
  const AddFriendsFragment({super.key});

  @override
  State<AddFriendsFragment> createState() => _AddFriendsFragmentState();
}

class _AddFriendsFragmentState extends State<AddFriendsFragment>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    // 추천 친구
    Get.find<FriendsController>().loadRecommendations();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: [
            height30,
            const Center(
              child: Text(
                '새로운 \n친　구',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ),
            const Height(60),
            AddFriendsTabBar(tabController: tabController),
            Expanded(
              child: AddFriendsTabBarView(tabController: tabController),
            ),
          ],
        ),
      ),
    );
  }
}
