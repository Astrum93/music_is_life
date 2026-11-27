import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/features/messenger/presentation/screen/create_chat_screen.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeMessengerRepository implements MessengerRepository {
  final created = <({String name, Map<String, String> members})>[];

  @override
  Future<Result<ChatRoom>> createRoom({
    required String name,
    required Map<String, String> members,
    required String managerEmail,
  }) async {
    created.add((name: name, members: members));
    return Success(
        ChatRoom(id: 'new', name: name, memberUids: members.keys.toList()));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profiles);

  final List<UserProfile> profiles;

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      Success(profiles.where((p) => uids.contains(p.uid)).toList());

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      Success(profiles);

  @override
  Stream<UserProfile?> watchProfile(String uid) => const Stream.empty();

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
  _FakeFriendsRepository(this.friends);

  final List<String> friends;

  @override
  Stream<FriendRelations> watchRelations(String uid) =>
      Stream.value(FriendRelations(
          friends: friends, followers: const [], following: const []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeMessengerRepository> _pump(WidgetTester tester,
    {List<String> friends = const ['neon', 'sea']}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final profiles = _FakeProfileRepository([
    const UserProfile(
      uid: 'neon',
      userName: 'night_neon',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: ProfileTrack(
          id: '1',
          name: '밤의 거리',
          artistsName: '시그널',
          imageUrl: 'https://example.com/1.jpg'),
    ),
    const UserProfile(
        uid: 'sea',
        userName: 'morae_al',
        profileImageUrl: '',
        backgroundImageUrl: ''),
  ]);
  final messenger = _FakeMessengerRepository();
  Get.put(CreateChatController(messenger,
      uid: 'me', userName: '정민', email: 'me@example.com'));
  Get.put(
      FriendsController(_FakeFriendsRepository(friends), profiles, uid: 'me'));

  // 채팅방 만들기는 메신저 위에 열려서, 만들면 이전 화면으로 돌아간다.
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateChatScreen())),
          child: const Text('열기'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
  return messenger;
}

void main() {
  tearDown(Get.reset);

  testWidgets('친구 목록에 인생곡을 보여주고, 누르면 선택 수가 바뀐다', (tester) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('night_neon'), findsOneWidget);
    expect(find.text('♪ 밤의 거리 · 시그널'), findsOneWidget);
    expect(find.text('인생곡을 아직 정하지 않았어요'), findsOneWidget);
    expect(find.text('0명 선택'), findsOneWidget);

    await tester.tap(find.text('night_neon'));
    await tester.pump();
    expect(find.text('1명 선택'), findsOneWidget);

    await tester.tap(find.text('night_neon'));
    await tester.pump();
    expect(find.text('0명 선택'), findsOneWidget);
  });

  testWidgets('이름이나 친구가 없으면 알려주고, 둘 다 있으면 만들고 돌아간다', (tester) async {
    final messenger = await _pump(tester);

    await tester.tap(find.text('만들기'));
    await tester.pump();
    expect(find.text('채팅방 이름을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '새벽 감성 모임');
    await tester.tap(find.text('만들기'));
    await tester.pump();
    expect(find.text('함께할 친구를 한 명 이상 골라주세요.'), findsOneWidget);
    expect(messenger.created, isEmpty);

    await tester.tap(find.text('morae_al'));
    await tester.tap(find.text('만들기'));
    await tester.pumpAndSettle();

    expect(messenger.created, hasLength(1));
    expect(messenger.created.single.name, '새벽 감성 모임');
    expect(messenger.created.single.members, {'me': '정민', 'sea': 'morae_al'});
    expect(find.text('열기'), findsOneWidget);
  });

  testWidgets('친구가 없으면 친구 추가 안내를 보여준다', (tester) async {
    await _pump(tester, friends: const []);
    expect(find.text('아직 친구가 없어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
