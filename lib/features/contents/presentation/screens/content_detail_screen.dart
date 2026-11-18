import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:music_is_life/core/widgets/box/expanded_box.dart';
import 'package:music_is_life/core/widgets/box/hash_tag_box.dart';
import 'package:music_is_life/core/widgets/subject_container.dart';

import 'package:music_is_life/core/widgets/short_line.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

class ContentDetailScreen extends StatefulWidget {
  const ContentDetailScreen({super.key, required this.content});

  final Content content;

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  ContentsController get _controller => Get.find<ContentsController>();

  Content get _content => widget.content;

  // 해시태그가 3개보다 적은 게시물도 있으므로 빈 문자열로 채운다.
  late final List<String> _hashTags =
      [..._content.hashTags, '', '', ''].take(3).toList();

  // 좋아요 상태
  var isLiked = false;

  // 좋아요 카운트 변수
  var likecount = 0;

  // 댓글 더보기
  var showMore = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 작성자 정보 (예전에는 게시물 작성자가 아니라 로그인한 사용자를 보여줬다)
              StreamBuilder<UserProfile?>(
                stream: _controller.watchAuthor(_content.authorUid),
                builder: (context, snapshot) {
                  return snapshot.data != null
                      ?
                      // 유저 프로필 사진 및 아이디
                      Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // 유저 프로필 사진
                                  CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 15,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        snapshot.data!.profileImageUrl,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // 유저 아이디
                                  Text(
                                    snapshot.data!.userName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),

                              // 날짜
                              Row(
                                children: [
                                  Text(
                                    _content.createdAt
                                        .toString()
                                        .substring(0, 10),
                                    style: const TextStyle(color: Colors.grey),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      : const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 20),

              SubjectContainer(text: _content.title),

              const SizedBox(height: 10),

              // 게시물 이미지
              Hero(
                tag: _content.imageUrl,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: Image.network(
                    _content.imageUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// 음악 정보
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                    child: Image.network(
                      (_content.track?.imageUrl ?? ''),
                      scale: 6,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          (_content.track?.name ?? '').length > 20
                              ? SizedBox(
                                  width: (_content.track?.name ?? '').length *
                                      11.toDouble(),
                                  height: 50,
                                  child: Marquee(
                                    text: (_content.track?.name ?? ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                    scrollAxis: Axis.horizontal,
                                    velocity: 30,
                                    blankSpace: 40,
                                  ),
                                )
                              : Text(
                                  (_content.track?.name ?? ''),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          (_content.track?.artistsName ?? '').length > 15
                              ? SizedBox(
                                  width: (_content.track?.artistsName ?? '')
                                          .length *
                                      11.toDouble(),
                                  height: 50,
                                  child: Marquee(
                                    text: (_content.track?.artistsName ?? ''),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                    ),
                                    scrollAxis: Axis.horizontal,
                                    velocity: 30,
                                    blankSpace: 40,
                                  ),
                                )
                              : Text(
                                  (_content.track?.artistsName ?? ''),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 콘텐츠 글
              Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                _content.body,
                                overflow: showMore
                                    ? TextOverflow.fade
                                    : TextOverflow.visible,
                                maxLines: showMore ? 1 : 100,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 댓글 더 보기 버튼
                    Row(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "더보기",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showMore = showMore == true ? false : true;
                                });
                              },
                              icon: showMore
                                  ? const Icon(Icons.arrow_drop_down)
                                  : const Icon(Icons.arrow_drop_up),
                              color: Colors.grey,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    HashTagBox(text: _hashTags[0], width: 10, fontSize: 15),
                    const ExpandedBox(),
                    HashTagBox(text: _hashTags[1], width: 10, fontSize: 15),
                    const ExpandedBox(),
                    HashTagBox(text: _hashTags[2], width: 10, fontSize: 15),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const ShortLine(color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
