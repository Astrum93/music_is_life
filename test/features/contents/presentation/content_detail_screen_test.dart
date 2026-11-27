import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 공감을 누르면 저장소가 목록을 다시 내보내서, 상세 화면의 숫자가 바뀌는지 볼 수 있게 한다.
class _FakeContentsRepository implements ContentsRepository {
  _FakeContentsRepository(this._stories);

  List<Content> _stories;
  final _all = StreamController<List<Content>>.broadcast();

  @override
  Stream<List<Content>> watchAll() async* {
    yield _stories;
    yield* _all.stream;
  }

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) => const Stream.empty();

  @override
  Future<Result<void>> setLiked(
      {required String contentId,
      required String uid,
      required bool liked}) async {
    _stories = [
      for (final c in _stories)
        c.id == contentId
            ? c.copyWith(
                likedBy: liked
                    ? [...c.likedBy, uid]
                    : c.likedBy.where((u) => u != uid).toList())
            : c,
    ];
    _all.add(_stories);
    return const Success(null);
  }

  @override
  Future<Result<Content>> create(
          {required String authorUid,
          required String authorName,
          required NewContent content}) =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => const Stream.empty();

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      const Success([]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      const Success([]);

  @override
  Future<Result<void>> updateIntroduction(String uid, String introduction) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) =>
      throw UnimplementedError();
}

class _FakeFriendsRepository implements FriendsRepository {
  @override
  Stream<FriendRelations> watchRelations(String uid) =>
      Stream.value(FriendRelations.empty);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Content _story(String id, DateTime at,
        {ContentTrack? track, List<String> tags = const [], int likes = 0}) =>
    Content(
      id: id,
      authorUid: 'night_neon',
      authorName: 'night_neon',
      title: '잠이 오지 않던 새벽, 무작정 강변을 달렸다',
      body: '창문을 조금 내리고 이 노래를 틀었을 때 그제야 숨이 쉬어졌다.\n요즘 잠 못 드는 사람들한테 꼭 들려주고 싶은 곡.',
      imageUrl: '',
      createdAt: at,
      hashTags: tags,
      likedBy: List.generate(likes, (i) => 'u$i'),
      track: track,
    );

const _track = ContentTrack(
    name: '도시의 불빛',
    artistsName: '네온 라디오',
    imageUrl: 'https://example.com/a.jpg');

Future<void> _pump(
    WidgetTester tester, List<Content> stories, Content open) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  Get.put(ContentsController(
      _FakeContentsRepository(stories), _FakeProfileRepository(),
      uid: 'me', userName: '나'));
  Get.put(FriendsController(_FakeFriendsRepository(), _FakeProfileRepository(),
      uid: 'me'));
  await tester
      .pumpWidget(MaterialApp(home: ContentDetailScreen(content: open)));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('작성자·순번, SIDE B 곡 정보, SIDE A 본문 전체와 해시태그를 보여준다', (tester) async {
    final first = _story('s1', DateTime(2026, 11, 1));
    final second = _story('s2', DateTime(2026, 11, 20),
        track: _track, tags: const ['새벽', '', '위로'], likes: 3);
    await _pump(tester, [second, first], second);

    expect(tester.takeException(), isNull);
    expect(find.text('night_neon'), findsOneWidget);
    expect(find.textContaining('2번째 이야기'), findsOneWidget);
    expect(find.text('SIDE B · 노래'), findsOneWidget);
    expect(find.text('도시의 불빛'), findsOneWidget);
    expect(find.text('들어보기'), findsOneWidget);
    expect(find.text('SIDE A · 이야기'), findsOneWidget);
    // 본문은 줄이지 않고 전부 보여준다. (줄바꿈 포함)
    expect(find.textContaining('꼭 들려주고 싶은 곡'), findsOneWidget);
    // 빈 해시태그는 보여주지 않는다.
    expect(find.text('#새벽'), findsOneWidget);
    expect(find.text('#위로'), findsOneWidget);
    expect(find.text('#'), findsNothing);
    expect(find.text('2026년 11월 20일'), findsOneWidget);
  });

  testWidgets('공감을 누르면 최신 목록을 따라 숫자가 바로 바뀐다', (tester) async {
    final story = _story('s1', DateTime(2026, 11, 20), track: _track, likes: 3);
    await _pump(tester, [story], story);

    // 본문(SelectableText)에도 스크롤이 있어서 화면 전체 목록의 스크롤을 지정한다.
    await tester.scrollUntilVisible(
      find.text('나도 이 노래로 버텼어 3'),
      200,
      scrollable: find
          .descendant(
              of: find.byType(ListView), matching: find.byType(Scrollable))
          .first,
    );
    await tester.tap(find.text('나도 이 노래로 버텼어 3'));
    await tester.pump();
    await tester.pump();

    expect(find.text('나도 이 노래로 버텼어 4'), findsOneWidget);
  });

  testWidgets('곡이 없는 예전 게시물은 들어보기 없이 보여준다', (tester) async {
    final legacy = _story('old', DateTime(2024, 6, 1));
    await _pump(tester, [legacy], legacy);

    expect(tester.takeException(), isNull);
    expect(find.text('SIDE B · 노래'), findsOneWidget);
    expect(find.text('들어보기'), findsNothing);
  });
}
