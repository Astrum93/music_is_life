import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/auth/presentation/widgets/logout_dialog.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/home/presentation/drawer/home_drawer.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/profile/presentation/widgets/mini_profile_sheet.dart';

Content _story(String id, String author, DateTime at, {int likes = 0}) =>
    Content(
      id: id,
      authorUid: author,
      authorName: author,
      title: '제목 $id',
      body: '',
      imageUrl: '',
      createdAt: at,
      likedBy: List.generate(likes, (i) => 'u$i'),
    );

class _FakeContentsRepository implements ContentsRepository {
  _FakeContentsRepository(this.stories);

  final List<Content> stories;

  @override
  Stream<List<Content>> watchAll() => Stream.value(stories);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) =>
      Stream.value(stories.where((s) => s.authorUid == authorUid).toList());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(UserProfile(
        uid: uid,
        userName: '정민',
        profileImageUrl: '',
        backgroundImageUrl: '',
        track: const ProfileTrack(
            id: 't', name: '빈 방', artistsName: '늦은 봄', imageUrl: ''),
      ));

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 팔로우하면 내 관계 스트림이 다시 내보내서 버튼 글자가 바뀌는지 볼 수 있게 한다.
class _FakeFriendsRepository implements FriendsRepository {
  final _mine = StreamController<FriendRelations>.broadcast();
  var _relations = const FriendRelations(followers: ['a', 'b', 'c']);

  @override
  Stream<FriendRelations> watchRelations(String uid) async* {
    if (uid == 'me') {
      yield _relations;
      yield* _mine.stream;
    } else {
      yield const FriendRelations(followers: ['x', 'y'], following: ['z']);
    }
  }

  @override
  Future<Result<void>> follow(
      {required String me, required String target}) async {
    _relations =
        _relations.copyWith(following: [..._relations.following, target]);
    _mine.add(_relations);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  var signedOut = false;

  @override
  AuthUser? get currentUser => const AuthUser(uid: 'me');

  @override
  Stream<AuthUser?> authStateChanges() => const Stream.empty();

  @override
  Future<Result<void>> signOut() async {
    signedOut = true;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _now = DateTime.now();

void _putControllers() {
  final stories = [
    _story('m1', 'me', _now.subtract(const Duration(days: 9)), likes: 2),
    _story('m2', 'me', _now.subtract(const Duration(days: 1)), likes: 3),
    _story('o1', 'other', _now.subtract(const Duration(days: 4))),
  ];
  final profiles = _FakeProfileRepository();
  Get.put(ContentsController(_FakeContentsRepository(stories), profiles,
      uid: 'me', userName: '정민'));
  Get.put(FriendsController(_FakeFriendsRepository(), profiles, uid: 'me'));
  Get.put(HomeController(profiles, uid: 'me'));
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(Get.reset);

  group('미니 프로필', () {
    const other = UserProfile(
      uid: 'other',
      userName: '여름바다',
      profileImageUrl: '',
      backgroundImageUrl: '',
      introduction: '여름 바다에서 들은 노래를 모아요.',
      track: ProfileTrack(
          id: 't', name: '파도 소리', artistsName: '해변의 오후', imageUrl: ''),
    );

    Future<void> open(WidgetTester tester, UserProfile profile) async {
      _phone(tester);
      _putControllers();
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showMiniProfile(context, profile),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
    }

    testWidgets('이름·소개·숫자·인생곡을 보여주고 팔로우하면 팔로잉으로 바뀐다', (tester) async {
      await open(tester, other);

      expect(tester.takeException(), isNull);
      expect(find.text('여름바다'), findsOneWidget);
      expect(find.text('여름 바다에서 들은 노래를 모아요.'), findsOneWidget);
      expect(find.text('D+5 · 이야기 1개'), findsOneWidget);
      expect(find.text('LIFE SONG'), findsOneWidget);
      expect(find.text('파도 소리 · 해변의 오후'), findsOneWidget);
      // 이야기 1 · 팔로잉 1 · 팔로워 2
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('팔로우'));
      await tester.pumpAndSettle();

      expect(find.text('팔로잉'), findsNWidgets(2));
    });

    testWidgets('내 프로필에는 팔로우 버튼이 없다', (tester) async {
      await open(
          tester,
          const UserProfile(
              uid: 'me',
              userName: '정민',
              profileImageUrl: '',
              backgroundImageUrl: ''));

      expect(find.text('팔로우'), findsNothing);
      expect(find.text('LIFE SONG'), findsNothing);
    });
  });

  group('메뉴', () {
    testWidgets('내 앨범·이름·숫자와 바로가기, 로그아웃을 보여준다', (tester) async {
      _phone(tester);
      _putControllers();
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(drawer: HomeDrawer(), body: SizedBox()),
      ));
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('정민'), findsOneWidget);
      expect(find.text('D+10 · ♪ 빈 방'), findsOneWidget);
      // 이야기 2 · 받은 공감 5 · 팔로워 3
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      for (final label in [
        '내 일기장',
        '친구 찾기',
        '친구 목록',
        '음악 컬렉션',
        'YouTube에서 찾기',
        '로그아웃'
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });
  });

  group('로그아웃 확인', () {
    Future<_FakeAuthRepository> open(WidgetTester tester) async {
      _phone(tester);
      final auth = _FakeAuthRepository();
      Get.put(SessionController(auth));
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/start',
        getPages: [
          GetPage(
            name: '/start',
            page: () => Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => confirmLogout(context),
                  child: const Text('OPEN'),
                ),
              ),
            ),
          ),
          GetPage(
              name: Routes.welcome,
              page: () => const Scaffold(body: Text('WELCOME'))),
        ],
      ));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      return auth;
    }

    testWidgets('취소하면 로그아웃하지 않는다', (tester) async {
      final auth = await open(tester);

      expect(find.text('로그아웃할까요?'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(auth.signedOut, isFalse);
      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('로그아웃을 누르면 로그아웃하고 웰컴으로 간다', (tester) async {
      final auth = await open(tester);

      await tester.tap(find.widgetWithText(FilledButton, '로그아웃'));
      await tester.pumpAndSettle();

      expect(auth.signedOut, isTrue);
      expect(find.text('WELCOME'), findsOneWidget);
    });
  });
}
