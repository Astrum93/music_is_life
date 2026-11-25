import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/lounge/lounge_fragment.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeContentsRepository implements ContentsRepository {
  _FakeContentsRepository({required this.all, required this.mine});

  final List<Content> all;
  final List<Content> mine;

  @override
  Stream<List<Content>> watchAll() => Stream.value(all);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) => Stream.value(mine);

  @override
  Future<Result<void>> setLiked(
          {required String contentId,
          required String uid,
          required bool liked}) async =>
      const Success(null);

  @override
  Future<Result<Content>> create(
          {required String authorUid,
          required String authorName,
          required NewContent content}) =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(
        UserProfile(
            uid: uid,
            userName: uid,
            profileImageUrl: '',
            backgroundImageUrl: ''),
      );

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      const Success([]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      const Success([]);

  @override
  Future<Result<void>> updateProfileImage(String uid, File image) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateBackgroundImage(String uid, File image) =>
      throw UnimplementedError();

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
  Future<Result<void>> follow(
          {required String me, required String target}) async =>
      const Success(null);

  @override
  Future<Result<void>> unfollow(
          {required String me, required String target}) async =>
      const Success(null);

  @override
  Future<Result<void>> addFriend(
          {required String me, required String friend}) async =>
      const Success(null);
}

Content _story(String id, String author, {bool withTrack = true}) => Content(
      id: id,
      authorUid: author,
      authorName: author,
      title: '이야기 $id',
      body: '본문 $id',
      imageUrl: '',
      createdAt: DateTime(2026, 11, int.parse(id.substring(1))),
      track: withTrack
          ? ContentTrack(
              name: '곡 $id',
              artistsName: '가수 $id',
              imageUrl: 'https://example.com/$id.jpg')
          : null,
    );

Future<void> _pumpLounge(WidgetTester tester, Size size,
    {required List<Content> all, required List<Content> mine}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  Get.put(ContentsController(
    _FakeContentsRepository(all: all, mine: mine),
    _FakeProfileRepository(),
    uid: 'me',
    userName: '나',
  ));
  Get.put(FriendsController(_FakeFriendsRepository(), _FakeProfileRepository(),
      uid: 'me'));

  await tester.pumpWidget(const MaterialApp(home: LoungeFragment()));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  final all = [
    _story('d3', 'night_neon'),
    _story('d2', 'morae_al'),
    _story('d1', 'night_neon')
  ];

  testWidgets('전체: 곡이 있는 이야기를 한 장씩 보여주고, 위로 넘기면 다음 이야기로 간다', (tester) async {
    await _pumpLounge(tester, const Size(390, 760),
        all: [...all, _story('d4', 'x', withTrack: false)], mine: const []);

    expect(tester.takeException(), isNull);
    expect(find.text('이야기 d3'), findsOneWidget);
    expect(find.text('B면 듣기 · 곡 d3 — 가수 d3'), findsOneWidget);
    // 곡이 없는 이야기는 라운지에 나오지 않는다.
    expect(find.text('이야기 d4'), findsNothing);

    await tester.fling(find.text('이야기 d3'), const Offset(0, -500), 1500);
    await tester.pumpAndSettle();
    expect(find.text('B면 듣기 · 곡 d2 — 가수 d2'), findsOneWidget);
  });

  testWidgets('세로가 짧은 화면에서도 카드가 넘치지 않는다', (tester) async {
    await _pumpLounge(tester, const Size(375, 560), all: all, mine: const []);
    expect(tester.takeException(), isNull);
  });

  testWidgets('내 게시물: 순번과 날짜가 있는 2열 목록으로 바뀐다', (tester) async {
    final mine = [_story('d9', 'me'), _story('d5', 'me')];
    await _pumpLounge(tester, const Size(390, 760), all: all, mine: mine);

    await tester.tap(find.text('내 게시물'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('내가 남긴 이야기 2개 · 최신순'), findsOneWidget);
    expect(find.text('#2 · 11.09'), findsOneWidget);
    expect(find.text('#1 · 11.05'), findsOneWidget);
  });

  testWidgets('이야기가 없으면 안내 문구를 보여준다', (tester) async {
    await _pumpLounge(tester, const Size(390, 760),
        all: const [], mine: const []);
    expect(find.text('아직 라운지에 이야기가 없어요.'), findsOneWidget);

    await tester.tap(find.text('내 게시물'));
    await tester.pump();
    expect(find.text('아직 남긴 이야기가 없어요.'), findsOneWidget);
  });
}
