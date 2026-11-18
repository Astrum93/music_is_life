import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeContentsRepository implements ContentsRepository {
  final all = StreamController<List<Content>>.broadcast();
  final mine = StreamController<List<Content>>.broadcast();
  String? watchedAuthor;
  final likes = <({String id, String uid, bool liked})>[];
  final created = <({String uid, String name, NewContent content})>[];
  Completer<Result<Content>>? pendingCreate;

  @override
  Stream<List<Content>> watchAll() => all.stream;

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) {
    watchedAuthor = authorUid;
    return mine.stream;
  }

  @override
  Future<Result<void>> setLiked({required String contentId, required String uid, required bool liked}) async {
    likes.add((id: contentId, uid: uid, liked: liked));
    return const Success(null);
  }

  @override
  Future<Result<Content>> create({required String authorUid, required String authorName, required NewContent content}) {
    created.add((uid: authorUid, name: authorName, content: content));
    pendingCreate = Completer();
    return pendingCreate!.future;
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(
        UserProfile(uid: uid, userName: 'author-$uid', profileImageUrl: '', backgroundImageUrl: ''),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Content _content(String id, {List<String> likedBy = const []}) => Content(
      id: id,
      authorUid: 'author',
      authorName: 'author',
      title: id,
      body: '',
      imageUrl: '',
      createdAt: DateTime(2024),
      likedBy: likedBy,
    );

void main() {
  late _FakeContentsRepository repository;
  late ContentsController controller;

  setUp(() {
    repository = _FakeContentsRepository();
    controller = ContentsController(
      repository,
      _FakeProfileRepository(),
      uid: 'me',
      userName: '나',
    )..onInit();
  });

  tearDown(() => controller.onClose());

  test('전체 게시물과 내 게시물을 각각 구독한다', () async {
    repository.all.add([_content('a'), _content('b')]);
    repository.mine.add([_content('a')]);
    await Future<void>.delayed(Duration.zero);

    expect(repository.watchedAuthor, 'me');
    expect(controller.allContents.map((c) => c.id), ['a', 'b']);
    expect(controller.myContents.map((c) => c.id), ['a']);
  });

  test('좋아요를 누르지 않았으면 누르고, 눌렀으면 취소한다', () async {
    await controller.toggleLike(_content('a'));
    await controller.toggleLike(_content('b', likedBy: ['me']));

    expect(repository.likes, [
      (id: 'a', uid: 'me', liked: true),
      (id: 'b', uid: 'me', liked: false),
    ]);
  });

  test('post는 내 uid·이름으로 올리고, 올리는 중에는 중복 요청을 막는다', () async {
    final input = NewContent(
      title: '제목',
      body: '',
      image: File('x.png'),
      track: const ContentTrack(name: '곡', artistsName: '', imageUrl: ''),
    );

    final first = controller.post(input);
    expect(controller.isPosting.value, isTrue);
    final second = await controller.post(input);
    expect(second.isFailed, isTrue);

    repository.pendingCreate!.complete(Success(_content('new')));
    await first;

    expect(controller.isPosting.value, isFalse);
    expect(repository.created, hasLength(1));
    expect(repository.created.single.uid, 'me');
    expect(repository.created.single.name, '나');
  });

  test('watchAuthor는 작성자의 현재 프로필을 내보낸다', () async {
    final author = await controller.watchAuthor('u9').first;

    expect(author?.userName, 'author-u9');
  });
}
