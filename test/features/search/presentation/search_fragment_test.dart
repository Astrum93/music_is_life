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
import 'package:music_is_life/features/search/presentation/screen/search_fragment.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';

class _FakeContentsRepository implements ContentsRepository {
  _FakeContentsRepository(this.all);

  final List<Content> all;

  @override
  Stream<List<Content>> watchAll() => Stream.value(all);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) =>
      Stream.value(all.where((c) => c.authorUid == authorUid).toList());

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
  _FakeProfileRepository(this.users);

  final List<UserProfile> users;

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      Stream.value(users.firstWhere((u) => u.uid == uid));

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      const Success([]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async => Success(users);

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

UserProfile _user(String uid, String name) => UserProfile(
    uid: uid, userName: name, profileImageUrl: '', backgroundImageUrl: '');

Content _story(String id, String author, String title, DateTime at) => Content(
      id: id,
      authorUid: author,
      authorName: author,
      title: title,
      body: '',
      imageUrl: '',
      createdAt: at,
      track: ContentTrack(
          name: '곡 $id',
          artistsName: '가수',
          imageUrl: 'https://example.com/$id.jpg'),
    );

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final users = [
    _user('me', '여름의나'),
    _user('sea', '여름바다'),
    _user('jam', '여름잠'),
    _user('etc', '겨울')
  ];
  final start = DateTime(2026, 1, 1);
  final contents = [
    // 여름바다: 이야기 100개 → 기록가
    for (var i = 0; i < 100; i++)
      _story('sea$i', 'sea', i == 99 ? '스무 살 여름 바다' : '바다 $i',
          start.add(Duration(days: i))),
    _story('jam0', 'jam', '여름밤 옥상', DateTime(2026, 6, 1)),
  ];
  final profiles = _FakeProfileRepository(users);
  final contentsRepository = _FakeContentsRepository(contents);

  Get.put(ContentsController(contentsRepository, profiles,
      uid: 'me', userName: '여름의나'));
  Get.put(FriendsController(_FakeFriendsRepository(), profiles, uid: 'me'));
  Get.put(AppSearchController(profiles, contentsRepository));

  await tester.pumpWidget(const MaterialApp(home: SearchFragment()));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('검색어가 없으면 안내 문구를 보여준다', (tester) async {
    await _pump(tester);
    expect(find.text('누구의 인생곡이 궁금한가요?'), findsOneWidget);
  });

  testWidgets('사용자 결과: 칭호·D+·이야기 수, 나에게는 팔로우 버튼이 없다', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), '여름');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('사용자 3명'), findsOneWidget);
    expect(find.text('여름바다'), findsOneWidget);
    expect(find.text('기록가'), findsOneWidget);
    expect(find.textContaining('이야기 100개'), findsOneWidget);
    expect(find.text('아직 기록 없음'), findsOneWidget); // 여름의나(나)
    expect(find.text('팔로우'), findsNWidgets(2)); // 여름바다, 여름잠 (나는 제외)
  });

  testWidgets('이야기 결과: 제목으로 찾고 "작성자 · N번째"를 보여준다', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), '여름');
    await tester.tap(find.text('이야기'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('이야기 2개'), findsOneWidget);
    expect(find.text('스무 살 여름 바다'), findsOneWidget);
    expect(find.text('sea · 100번째'), findsOneWidget);
  });

  testWidgets('결과가 없을 때 검색어가 바뀌면 안내 문구도 바뀐다', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'zz');
    await tester.pump();
    expect(find.text('‘zz’에 맞는 결과가 없어요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('‘zzz’에 맞는 결과가 없어요.'), findsOneWidget);
  });
}
