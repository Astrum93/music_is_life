import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/data/memory/firebase/firebase_auth/firebase_auth_user.dart';
import 'package:music_is_life/data/memory/firebase/firestore/firebase_collection_reference.dart';

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

class _UserInfoMiniState extends State<UserInfoMini>
    with FirebaseCollectionReference, FirebaseAuthUser {
  Future<void> follow() async {
    if (widget.uid == currentUid) {
      return;
    }
    await FirebaseFirestore.instance
        .collection('UserFriends')
        .doc(widget.uid)
        .update({
      'follower': FieldValue.arrayUnion([currentUid])
    });
    await FirebaseFirestore.instance
        .collection('UserFriends')
        .doc(currentUid)
        .update({
      'following': FieldValue.arrayUnion([widget.uid])
    });
  }

  Future<void> unFollow() async {
    await FirebaseFirestore.instance
        .collection('UserFriends')
        .doc(widget.uid)
        .update({
      'follower': FieldValue.arrayRemove([currentUid])
    });
    await FirebaseFirestore.instance
        .collection('UserFriends')
        .doc(currentUid)
        .update({
      'following': FieldValue.arrayRemove([widget.uid])
    });
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
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('UserFriends')
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final userFriendsDoc = snapshot.data!;

                          var userFriendsDocData = userFriendsDoc.data();

                          var following = userFriendsDocData != null &&
                                  userFriendsDocData.containsKey('following')
                              ? userFriendsDocData['following']
                              : [];

                          var follower = userFriendsDocData != null &&
                                  userFriendsDocData.containsKey('follower')
                              ? userFriendsDocData['follower']
                              : [];

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
                                  StreamBuilder(
                                    stream: userContentsCollection
                                        .where("authorUid", isEqualTo: widget.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }

                                      /// 로그인한 유저의 게시물 문서
                                      final collectionDocs =
                                          snapshot.data!.docs;
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
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('UserFriends')
                                    .doc(currentUid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final userFriendsDoc = snapshot.data!;
                                  var userFriendsDocData =
                                      userFriendsDoc.data();

                                  var following = userFriendsDocData != null &&
                                          userFriendsDocData
                                              .containsKey('following')
                                      ? userFriendsDocData['following']
                                      : [];

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
                                      shadowColor:
                                          WidgetStatePropertyAll<Color>(
                                              Colors.transparent),
                                    ),
                                    menuChildren: [
                                      CircleAvatar(
                                        backgroundColor: Colors.black,
                                        child: IconButton(
                                          onPressed: () async {
                                            if (following
                                                .contains(widget.uid)) {
                                              return await unFollow();
                                            } else {
                                              await follow();
                                            }
                                          },
                                          icon: Icon(
                                            Icons.local_fire_department,
                                            color:
                                                following.contains(widget.uid)
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      height10,
                                      Text(
                                        following.contains(widget.uid)
                                            ? '팔로잉'
                                            : '팔로우',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  );
                                },
                              ),
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
