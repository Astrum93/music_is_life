import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';
import 'package:music_is_life/features/search/presentation/screen/search_result_contents_screen.dart';
import 'package:music_is_life/features/search/presentation/screen/search_result_user_info_screen.dart';

class SearchTabBarView extends StatelessWidget {
  const SearchTabBarView({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final searchData = Get.find<AppSearchController>();
    return Obx(
      () => TabBarView(
        controller: tabController,
        children: [
          searchData.userResults.isEmpty
              ? Center(
                  child: Image.asset(
                    'assets/icon/just_be_happy.png',
                    color: Colors.white,
                    scale: 3,
                  ),
                )
              : const SearchResultUserInfo(),
          searchData.contentResults.isEmpty
              ? Center(
                  child: Image.asset(
                    'assets/icon/just_be_happy.png',
                    color: Colors.white,
                    scale: 3,
                  ),
                )
              : const SearchResultContents(),
        ],
      ),
    );
  }
}

class SearchTabBar extends StatelessWidget {
  const SearchTabBar({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: Colors.white,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      overlayColor: WidgetStatePropertyAll(
        Colors.lightBlue.withValues(alpha: 0.2),
      ),
      indicatorWeight: 0.1,
      indicatorColor: Colors.amber,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(
          icon: Icon(
            Icons.person_outline_rounded,
          ),
          text: '사용자 검색 결과',
        ),
        Tab(
          icon: Icon(
            Icons.library_music_outlined,
          ),
          text: '게시물 검색 결과',
        ),
      ],
    );
  }
}
