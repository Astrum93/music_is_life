import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/widget/search/search_friends_result_screen.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/widget/search/search_input_widget.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

/// 이름으로 친구 검색
class SearchFriendsTabBarView extends StatefulWidget {
  const SearchFriendsTabBarView({super.key});

  @override
  State<SearchFriendsTabBarView> createState() =>
      _SearchFriendsTabBarViewState();
}

class _SearchFriendsTabBarViewState extends State<SearchFriendsTabBarView> {
  final TextEditingController controller = TextEditingController();

  FriendsController get _friends => Get.find<FriendsController>();

  @override
  void initState() {
    super.initState();
    controller.addListener(() => _friends.search(controller.text));
  }

  @override
  void dispose() {
    controller.dispose();
    _friends.searchResults.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchInputWidget(controller: controller),
          const SearchFriendsResultScreen(),
        ],
      ),
    );
  }
}
