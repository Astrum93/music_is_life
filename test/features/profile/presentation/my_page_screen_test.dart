import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/profile/presentation/my_page_screen.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

class _FakeContentsRepository implements ContentsRepository {
  _FakeContentsRepository(this.mine);

  final List<Content> mine;

  @override
  Stream<List<Content>> watchAll() => Stream.value(mine);

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
  _FakeProfileRepository(this.profile);

  final UserProfile profile;

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(profile);

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
  Stream<FriendRelations> watchRelations(String uid) => Stream.value(
        const FriendRelations(
            friends: [], followers: ['a', 'b', 'c'], following: ['d']),
      );

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

Content _story(int i, DateTime at) => Content(
      id: 's$i',
      authorUid: 'me',
      authorName: '정민',
      title: '이야기 $i',
      body: '',
      imageUrl: '',
      createdAt: at,
      track: ContentTrack(
          name: '곡 $i',
          artistsName: '가수',
          imageUrl: 'https://example.com/$i.jpg'),
    );

Future<void> _pump(WidgetTester tester,
    {required List<Content> mine, ProfileTrack? track}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final profile = UserProfile(
    uid: 'me',
    userName: '정민',
    profileImageUrl: '',
    backgroundImageUrl: '',
    introduction: '새벽엔 조용한 노래',
    track: track,
  );
  Get.put(ProfileController(_FakeProfileRepository(profile), 'me'));
  Get.put(ContentsController(
      _FakeContentsRepository(mine), _FakeProfileRepository(profile),
      uid: 'me', userName: '정민'));
  Get.put(FriendsController(
      _FakeFriendsRepository(), _FakeProfileRepository(profile),
      uid: 'me'));

  await tester.pumpWidget(const MaterialApp(home: MyScreen()));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('기록이 쌓인 내 일기장: 스펙트럼·칭호·D+·팔로워·진행도', (tester) async {
    // 2025-11-25부터 하루 한 곡씩 120곡 → 기록가, 다음 칭호(아카이비스트)까지 245곡
    final start = DateTime(2025, 11, 25);
    final mine =
        List.generate(120, (i) => _story(i + 1, start.add(Duration(days: i))));
    await _pump(
      tester,
      mine: mine,
      track: const ProfileTrack(
          id: 't', name: '빈 방', artistsName: '늦은 봄', imageUrl: ''),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('LIFE SPECTRUM'), findsOneWidget);
    expect(find.text('2025.11.25 첫 페이지'), findsOneWidget);
    expect(find.text('기록가'), findsWidgets);
    expect(find.textContaining('기록한 날 120일'), findsOneWidget);
    expect(find.text('팔로워 3 · 팔로잉 1'), findsOneWidget);
    expect(find.text('245곡'), findsOneWidget);
    expect(find.text('나의 인생곡 · 빈 방 — 늦은 봄'), findsOneWidget);
  });

  testWidgets('아래로 내리면 디스코그래피와 타임라인, 맨 끝에 DAY 1 카드가 있다', (tester) async {
    final mine = [
      _story(1, DateTime(2025, 10, 8)),
      _story(2, DateTime(2026, 11, 20)),
      _story(3, DateTime(2026, 11, 24)),
    ];
    await _pump(tester, mine: mine);

    await tester.scrollUntilVisible(find.text('Vol.1'), 300,
        scrollable: _vertical);
    expect(find.text('Vol.1'), findsOneWidget);
    expect(find.text('Vol.2'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('DAY 1 · 첫 페이지'), 300,
        scrollable: _vertical);
    expect(find.text('2026년 11월 · 2곡'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
    expect(find.text('2025년 10월 8일'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('기록이 없으면 첫 페이지 안내와 인생곡 정하기를 보여준다', (tester) async {
    await _pump(tester, mine: const []);
    expect(find.text('첫 이야기를 남기면 스펙트럼이 시작돼요'), findsOneWidget);
    expect(find.text('나의 인생곡 정하기'), findsOneWidget);
    expect(find.text('디스코그래피'), findsNothing);

    await tester.scrollUntilVisible(find.text('아직 남긴 이야기가 없어요.'), 300,
        scrollable: _vertical);
    expect(tester.takeException(), isNull);
  });
}

/// 마이페이지의 세로 스크롤 (디스코그래피의 가로 목록과 구분)
final _vertical = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);
