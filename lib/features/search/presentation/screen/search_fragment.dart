import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';
import 'package:music_is_life/features/search/presentation/search_app_bar.dart';

import 'search_tab_bar.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  late final TabController tabController;

  AppSearchController get _search => Get.find<AppSearchController>();

  @override
  void initState() {
    controller.addListener(() => _search.search(controller.text));
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SearchAppBar(controller: controller),
        body: Column(
          children: [
            SearchTabBar(tabController: tabController),
            Expanded(
              child: SearchTabBarView(tabController: tabController),
            ),
          ],
        ),
      ),
    );
  }
}
