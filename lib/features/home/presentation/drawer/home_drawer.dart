import 'package:flutter/material.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final contents = Get.find<ContentsController>();
    return Obx(() {
      final me = home.me.value;
      if (me == null) {
        return const Drawer(child: Center(child: CircularProgressIndicator()));
      }
      final name = me.userName;
      final profileImage = me.profileImageUrl;
      return Drawer(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        surfaceTintColor: Colors.black.withValues(alpha: 0.9),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Height(30),
              Row(
                children: [
                  Text(
                    'Welcome\n$name',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Height(50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 250,
                        height: 350,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),

                      /// Profile Image
                      Positioned(
                        top: -20,
                        left: -20,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(profileImage),
                          ),
                        ),
                      ),

                      /// Profile Name
                      Positioned(
                        top: 20,
                        left: 90,
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                blurRadius: 7,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.green,
                                  size: 25,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// 게시글, Liked, Like
                      Obx(() {
                        // 내가 쓴 게시물
                        final collectionDocs = contents.myContents.toList();

                        return Positioned(
                          top: 90,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            width: 240,
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 7,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 게시글
                                  Column(
                                    children: [
                                      const Text(
                                        '게시글',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        collectionDocs.length.toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 30),

                                  /// 좋아하는 사람
                                  Column(
                                    children: [
                                      const Text(
                                        'Liked',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${collectionDocs.fold<int>(0, (sum, c) => sum + c.likeCount)}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 30),

                                  /// 팔로워
                                  Obx(() {
                                    final followerCount =
                                        Get.find<FriendsController>()
                                            .relations
                                            .value
                                            .followers
                                            .length;

                                    return Column(
                                      children: [
                                        const Text(
                                          '팔로워',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        height10,
                                        Text(
                                          "$followerCount",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // 로그아웃 버튼
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              // TODO(ca-home): 홈을 옮길 때 Binding으로 받도록 변경
                              await Get.find<SessionController>().logout();
                              Get.offAllNamed(Routes.welcome);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor:
                                    Colors.grey.withValues(alpha: 0.8)),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Logout'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
