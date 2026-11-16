import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_is_life/core/widgets/button/mini_button.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/data/memory/firebase/firebase_auth/firebase_auth_user.dart';
import 'package:music_is_life/data/memory/firebase/firestore/firebase_collection_reference.dart';
import 'package:music_is_life/main/mypage/add_friends/add_friends_fragment.dart';
import 'package:music_is_life/main/mypage/favorites/favorites_fragment.dart';
import 'package:music_is_life/main/mypage/music/music_collection/music_collection_screen.dart';
import 'package:music_is_life/main/mypage/profile/edit/edit_profile_background.dart';
import 'package:music_is_life/main/mypage/profile/edit/edit_profile_image.dart';
import 'package:music_is_life/main/mypage/profile/edit/edit_profile_introduce.dart';
import 'package:music_is_life/main/tab/home/home_fragment.dart';
import 'package:music_is_life/main/tab/messenger/messenger_fragment.dart';
import 'package:music_is_life/spotify/service/spotify_web_api_service.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'contents/create/create_screen.dart';
import 'contents/user_cotents_screen.dart';
import 'music/music_search_screen.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with
        TickerProviderStateMixin,
        FirebaseAuthUser,
        FirebaseCollectionReference,
        SpotifyWebApiService {
  // 이미지 수정 팝업창
  void showAlertProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: EditProfileImage(),
        );
      },
    );
  }

  // 프로필 배경 화면 수정
  void showAlertProfileBackground(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: EditProfileBgImage(),
        );
      },
    );
  }

  // 프로필 소개 수정
  void showAlertProfileIntroduce(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: EditProfileIntroduce(),
        );
      },
    );
  }

  // User 정보 불러오기
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
          stream: userInfoCollection.doc(currentUid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text(
                'No data available',
                style: TextStyle(color: Colors.red),
              );
            }
            final collectionDoc = snapshot.data!;
            var username = collectionDoc['userName'];
            var userProfileBgImage = collectionDoc['userProfileBgImage'];
            var userProfileImage = collectionDoc['userProfileImage'];
            var userProfileInfo = collectionDoc['userProfileInfo'];
            var userProfileTrackImage = collectionDoc['userProfileTrackImage'];
            var userProfileTrackName = collectionDoc['userProfileTrackName'];
            var userProfileTrackArtistsName =
                collectionDoc['userProfileTrackArtistsName'];

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SafeArea(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 프로필 배경
                          GestureDetector(
                            onTap: () {
                              showAlertProfileBackground(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(userProfileBgImage),
                                ),
                              ),
                            ),
                          ),

                          // 프로필 사진
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -50,
                            child: GestureDetector(
                              onTap: () {
                                showAlertProfile(context);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    userProfileImage,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Home 버튼
                          Positioned(
                            top: 0,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeFragment()));
                              },
                              icon: const Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),

                    // UserName
                    Text(
                      username,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

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

                          var userFriendsDocData = userFriendsDoc.data();

                          var follower = userFriendsDocData != null &&
                                  userFriendsDocData.containsKey('follower')
                              ? userFriendsDocData['follower']
                              : [];

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.red,
                              ),
                              width10,
                              Text('${follower.length}'),
                            ],
                          );
                        }),
                    const SizedBox(height: 10),

                    // 프로필 상호작용 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// 친구 추가 버튼
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddFriendsFragment(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person_add_alt_1_outlined,
                            color: Colors.green,
                          ),
                        ),

                        /// 메세지 전송 버튼
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MessengerFragment(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.messenger_outline_outlined,
                            color: Colors.blue,
                          ),
                        ),

                        /// 개인 음악 모음
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const MusicCollectionScreen()));
                          },
                          icon: const Icon(
                            Icons.library_music_outlined,
                            color: Colors.red,
                          ),
                        ),

                        /// 즐겨찾기
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const FavoritesFragment()));
                          },
                          icon: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 프로필 소개
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '📢 프로필 소개',
                            style: TextStyle(color: Colors.grey),
                          ),
                          height20,
                          GestureDetector(
                            onTap: () {
                              showAlertProfileIntroduce(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 10,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.shade100
                                        .withValues(alpha: 0.2),
                                    blurRadius: 7,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  userProfileInfo,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 음악 플레이어
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Column(
                        children: [
                          const Text(
                            '🎵 프로필 뮤직',
                            style: TextStyle(color: Colors.grey),
                          ),
                          height20,

                          /// 음악 플레이어
                          StreamBuilder<ConnectionStatus>(
                              stream: SpotifySdk.subscribeConnectionStatus(),
                              builder: (context, snapshot) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        blurRadius: 7,
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// 앨범 사진
                                        CircleAvatar(
                                          radius: 40,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                                userProfileTrackImage),
                                          ),
                                        ),

                                        /// 음악 제목, 가수 이름
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userProfileTrackName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              userProfileTrackArtistsName,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            getAccessToken();

                                            //await SpotifyWebApiService
                                            //    .remoteService(context);
                                            //await getAccessToken();
                                            // connectToSpotifyRemote();
                                          },
                                          icon: const Icon(
                                            Icons.play_circle_outline_rounded,
                                            color: Colors.grey,
                                            size: 45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 게시물 생성 버튼 2개
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 게시물 생성 버튼 ( Music Search )
                          MiniButton(
                            builder: (context) => const MusicSearchScreen(),
                            text: 'Music Search',
                            icon: Icons.music_note_rounded,
                          ),

                          const SizedBox(width: 25),

                          // Create Contents
                          MiniButton(
                              builder: (context) => const CreateScreen(),
                              text: 'Create Contents',
                              icon: Icons.mode_edit_outline_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: UserContentsScreen(),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
