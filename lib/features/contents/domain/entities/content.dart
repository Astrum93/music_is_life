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

    /// 예전 게시물의 사진 주소. 사진 업로드를 없앤 뒤 새 게시물은 빈 문자열이다.
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
///
/// 개인 사진은 올리지 않는다. 게시물의 이미지는 붙인 곡의 앨범 아트([track])뿐이다.
@freezed
abstract class NewContent with _$NewContent {
  const factory NewContent({
    required String title,
    required String body,
    required ContentTrack track,
    @Default(<String>[]) List<String> hashTags,
  }) = _NewContent;
}
