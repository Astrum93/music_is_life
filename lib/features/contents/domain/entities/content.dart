import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'content.freezed.dart';

/// 게시물 (UserContents/{id})
@freezed
abstract class Content with _$Content {
  const Content._();

  const factory Content({
    required String id,
    required String authorUid,

    /// 작성 당시 작성자 이름 (화면 표시용으로 함께 저장된 값)
    required String authorName,
    required String title,
    required String body,
    required String imageUrl,
    required DateTime createdAt,
    @Default(<String>[]) List<String> hashTags,

    /// 좋아요를 누른 사용자 uid
    @Default(<String>[]) List<String> likedBy,
    ContentTrack? track,
  }) = _Content;

  int get likeCount => likedBy.length;

  bool isLikedBy(String uid) => likedBy.contains(uid);
}

/// 게시물에 붙인 곡
@freezed
abstract class ContentTrack with _$ContentTrack {
  const factory ContentTrack({
    required String name,
    required String artistsName,
    required String imageUrl,
  }) = _ContentTrack;
}

/// 새 게시물 입력값
@freezed
abstract class NewContent with _$NewContent {
  const factory NewContent({
    required String title,
    required String body,
    required File image,
    required ContentTrack track,
    @Default(<String>[]) List<String> hashTags,
  }) = _NewContent;
}
