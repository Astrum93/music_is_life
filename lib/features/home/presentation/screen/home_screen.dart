import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/home/presentation/drawer/home_drawer.dart';
import 'package:music_is_life/features/contents/presentation/widgets/hot_contents.dart';
import 'package:music_is_life/features/music/presentation/widgets/youtube_search_widget.dart';

import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/features/search/presentation/screen/search_fragment.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController get _home => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/logo/music_is_life.png',
          scale: 8,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchFragment(),
                ),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),

          /// 개인 프로필
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.myPage);
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 17,
              child: Obx(() {
                final me = _home.me.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: me == null
                      ? const Center(
                          child: SizedBox(),
                        )
                      : Image.network(me.profileImageUrl),
                );
              }),
            ),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 13),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                'Top 10 🔥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              /// 인기 게시물
              HotContents(),

              SizedBox(height: 40),

              /// 메인 컬럼 세 번째 열
              Center(
                child: Text(
                  'Youtube 영상 검색',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// 메인 컬럼 SizedBox
              SizedBox(height: 20),

              SearchYoutubeMusic(),

              /// 메인 컬럼 SizedBox
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
