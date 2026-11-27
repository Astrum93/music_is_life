import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/add_friends_fragment.dart';
import 'package:music_is_life/features/friends/presentation/favorites/favorites_fragment.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

UserProfile _person(String uid, String name, {String? song}) => UserProfile(
      uid: uid,
      userName: name,
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: song == null
          ? null
          : ProfileTrack(id: uid, name: song, artistsName: '가수', imageUrl: ''),
    );

final _people = [
  _person('me', '정민'),
  _person('a', '노을빛', song: '해 질 녘'),
  _person('b', '여름바다', song: '파도 소리'),
  _person('c', '반짝'),
];

class _FakeProfiles implements ProfileRepository {
  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      Success(_people);

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      Success([
        for (final p in _people)
          if (uids.contains(p.uid)) p
      ]);

  @override
  Stream<UserProfile?> watchProfile(String uid) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFriends implements FriendsRepository {
  _FakeFriends(this._relations);

  FriendRelations _relations;
  final _changes = StreamController<FriendRelations>.broadcast();
  final added = <String>[];

  @override
  Stream<FriendRelations> watchRelations(String uid) async* {
    yield _relations;
    yield* _changes.stream;
  }

  @override
  Future<Result<void>> addFriend(
      {required String me, required String friend}) async {
    added.add(friend);
    _relations = _relations.copyWith(friends: [..._relations.friends, friend]);
    _changes.add(_relations);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeContents implements ContentsRepository {
  @override
  Stream<List<Content>> watchAll() => Stream.value([
        for (var i = 0; i < 3; i++)
          Content(
            id: 'b$i',
            authorUid: 'b',
            authorName: '여름바다',
            title: '',
            body: '',
            imageUrl: '',
            createdAt: DateTime.now().subtract(Duration(days: 10 - i)),
          ),
      ]);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeFriends> _pump(WidgetTester tester, Widget screen,
    {FriendRelations relations = FriendRelations.empty}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final friends = _FakeFriends(relations);
  final profiles = _FakeProfiles();
  Get.put(
      ContentsController(_FakeContents(), profiles, uid: 'me', userName: '정민'));
  Get.put(FriendsController(friends, profiles, uid: 'me'));
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pumpAndSettle();
  return friends;
}

void main() {
  tearDown(Get.reset);

  group('친구 찾기', () {
    testWidgets('추천에는 나를 빼고 보여주고, 기록이 있으면 D+와 이야기 수를 붙인다', (tester) async {
      await _pump(tester, const AddFriendsFragment());

      expect(tester.takeException(), isNull);
      expect(find.text('정민'), findsNothing);
      expect(find.text('노을빛'), findsOneWidget);
      expect(find.text('D+11 · 이야기 3개'), findsOneWidget);
      // 기록이 없으면 인생곡을 보여준다.
      expect(find.text('♪ 해 질 녘 · 가수'), findsOneWidget);
      expect(find.text('아직 남긴 이야기가 없어요'), findsOneWidget);
      expect(find.text('친구 추가'), findsNWidgets(3));
    });

    testWidgets('친구 추가를 누르면 저장하고 버튼이 [친구]로 바뀐다', (tester) async {
      final friends = await _pump(tester, const AddFriendsFragment());

      await tester.tap(find.text('친구 추가').first);
      await tester.pumpAndSettle();

      expect(friends.added, ['a']);
      expect(find.text('친구'), findsOneWidget);
      expect(find.text('노을빛님을 친구로 추가했어요.'), findsOneWidget);
    });

    testWidgets('이름으로 찾으면 맞는 사람만 보이고, 없으면 안내한다', (tester) async {
      await _pump(tester, const AddFriendsFragment());

      await tester.tap(find.text('이름으로 찾기'));
      await tester.pumpAndSettle();
      expect(find.text('이름으로 찾아보세요.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '바다');
      await tester.pumpAndSettle();
      expect(find.text('여름바다'), findsOneWidget);
      expect(find.text('노을빛'), findsNothing);

      await tester.enterText(find.byType(TextField), '없는이름');
      await tester.pumpAndSettle();
      expect(find.text('「없는이름」와 맞는 사람이 없어요.'), findsOneWidget);
    });
  });

  group('친구 목록', () {
    testWidgets('팔로잉·팔로워 수를 탭에 붙이고, 탭을 바꾸면 목록이 바뀐다', (tester) async {
      await _pump(tester, const FavoritesFragment(),
          relations:
              const FriendRelations(following: ['a', 'b'], followers: ['c']));

      expect(tester.takeException(), isNull);
      expect(find.text('팔로잉 2'), findsOneWidget);
      expect(find.text('팔로워 1'), findsOneWidget);
      expect(find.text('노을빛'), findsOneWidget);
      expect(find.text('♪ 파도 소리 · 가수'), findsOneWidget);

      await tester.tap(find.text('팔로워 1'));
      await tester.pumpAndSettle();

      expect(find.text('반짝'), findsOneWidget);
      expect(find.text('인생곡을 아직 정하지 않았어요'), findsOneWidget);
      expect(find.text('노을빛'), findsNothing);
    });

    testWidgets('아무도 없으면 안내를 보여준다', (tester) async {
      await _pump(tester, const FavoritesFragment());

      expect(find.text('아직 팔로우한 사람이 없어요.'), findsOneWidget);
    });
  });
}
