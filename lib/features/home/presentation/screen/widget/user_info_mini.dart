import 'package:flutter/material.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';

class UserInfoMini extends StatefulWidget {
  /// 프로필 주인의 uid (UserInfo·UserFriends 문서 ID)
  final String uid;
  final String profileImage;
  final String name;
  final String userProfileInfo;

  const UserInfoMini({
    super.key,
    required this.uid,
    required this.profileImage,
    required this.name,
    required this.userProfileInfo,
  });

  @override
  State<UserInfoMini> createState() => _UserInfoMiniState();
}

class _UserInfoMiniState extends State<UserInfoMini> {
  FriendsController get _friends => Get.find<FriendsController>();

  // 스트림을 build마다 새로 만들지 않도록 한 번만 만든다.
  late final Stream<FriendRelations> _relations =
      _friends.watchRelationsOf(widget.uid);
  late final Stream<List<Content>> _contents =
      Get.find<ContentsController>().watchContentsOf(widget.uid);

  Future<void> _toggleFollow() async {
    final result = await _friends.toggleFollow(widget.uid);
    if (result case Failed(:final failure) when mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 200,
          decoration: const BoxDecoration(
            color: AppColors.veryDarkGrey,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        widget.profileImage,
                      ),
                    ),
                  ),
                  height20,
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Width(20),
              Expanded(
                child: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<FriendRelations>(
                        stream: _relations,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final following = snapshot.data!.following;
                          final follower = snapshot.data!.followers;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 게시글 수
                              Column(
                                children: [
                                  const Text(
                                    '게시글',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  height10,
                                  StreamBuilder<List<Content>>(
                                    stream: _contents,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      /// 프로필 주인의 게시물
                                      final collectionDocs = snapshot.data!;
                                      return Text(
                                        collectionDocs.length.toString(),
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              width30,

                              /// 팔로잉
                              Column(
                                children: [
                                  const Text(
                                    '팔로잉',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  height10,
                                  Text(
                                    '${following.length}',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              width30,

                              /// 팔로워
                              Column(
                                children: [
                                  const Text(
                                    '팔로워',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  height10,
                                  Text(
                                    '${follower.length}',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const Width(30),

                              /// 팔로우 버튼
                              Obx(() {
                                final isFollowing = _friends.relations.value
                                    .isFollowing(widget.uid);

                                return MenuAnchor(
                                  builder: (BuildContext context,
                                          MenuController controller,
                                          Widget? child) =>
                                      IconButton(
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    icon: const Icon(Icons.more_horiz),
                                  ),
                                  style: const MenuStyle(
                                    padding: WidgetStatePropertyAll<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.all(4),
                                    ),
                                    backgroundColor:
                                        WidgetStatePropertyAll<Color>(
                                            Colors.transparent),
                                    shadowColor: WidgetStatePropertyAll<Color>(
                                        Colors.transparent),
                                  ),
                                  menuChildren: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,
                                      child: IconButton(
                                        onPressed: _toggleFollow,
                                        icon: Icon(
                                          Icons.local_fire_department,
                                          color: isFollowing
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    height10,
                                    Text(
                                      isFollowing ? '팔로잉' : '팔로우',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          );
                        },
                      ),
                      height20,

                      /// 유저 프로필 소개
                      Expanded(
                        child: Container(
                          width: 220,
                          height: 90,
                          decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Center(
                            child: Text(
                              widget.userProfileInfo,
                              textAlign: TextAlign.center,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
