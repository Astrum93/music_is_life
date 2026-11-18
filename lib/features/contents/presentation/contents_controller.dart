import 'dart:async';

import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 게시물 피드·내 게시물·작성·좋아요 상태
class ContentsController extends GetxController {
  ContentsController(
    this._repository,
    this._profileRepository, {
    required this.uid,
    required this.userName,
  });

  final ContentsRepository _repository;
  final ProfileRepository _profileRepository;

  /// 로그인한 나
  final String uid;
  final String userName;

  /// 홈 피드·라운지 전체 게시물 (최신순)
  final allContents = <Content>[].obs;

  /// 내가 쓴 게시물 (최신순)
  final myContents = <Content>[].obs;

  final isPosting = false.obs;

  final _subscriptions = <StreamSubscription<dynamic>>[];

  @override
  void onInit() {
    super.onInit();
    _subscriptions
      ..add(_repository.watchAll().listen(allContents.assignAll))
      ..add(_repository.watchByAuthor(uid).listen(myContents.assignAll));
  }

  /// 다른 사용자가 쓴 게시물 (미니 프로필의 게시글 수)
  Stream<List<Content>> watchContentsOf(String authorUid) =>
      _repository.watchByAuthor(authorUid);

  /// 게시물 작성자의 현재 프로필 (이름·사진)
  Stream<UserProfile?> watchAuthor(String authorUid) =>
      _profileRepository.watchProfile(authorUid);

  bool isLikedByMe(Content content) => content.isLikedBy(uid);

  Future<Result<void>> toggleLike(Content content) => _repository.setLiked(
        contentId: content.id,
        uid: uid,
        liked: !content.isLikedBy(uid),
      );

  /// 게시물을 올린다. 올리는 중에 다시 누르면 무시해서 중복 게시를 막는다.
  Future<Result<Content>> post(NewContent content) async {
    if (isPosting.value) {
      return const Failed(UnknownFailure('이미 게시물을 올리는 중입니다.'));
    }
    isPosting.value = true;
    try {
      return await _repository.create(
        authorUid: uid,
        authorName: userName,
        content: content,
      );
    } finally {
      isPosting.value = false;
    }
  }

  @override
  void onClose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.onClose();
  }
}
