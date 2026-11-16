import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';

/// 게시물 Repository
abstract interface class ContentsRepository {
  /// 모든 게시물 (최신순)
  Stream<List<Content>> watchAll();

  /// 특정 사용자가 쓴 게시물 (최신순)
  Stream<List<Content>> watchByAuthor(String authorUid);

  /// 이미지를 올리고 게시물을 저장한다.
  Future<Result<Content>> create({
    required String authorUid,
    required String authorName,
    required NewContent content,
  });

  /// 좋아요를 누르거나 취소한다.
  Future<Result<void>> setLiked({
    required String contentId,
    required String uid,
    required bool liked,
  });
}
