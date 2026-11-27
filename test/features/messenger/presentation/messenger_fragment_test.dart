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
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_fragment.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeMessengerRepository implements MessengerRepository {
  _FakeMessengerRepository(this.rooms);

  final List<ChatRoom> rooms;
  final liked = <({String roomId, bool liked})>[];

  @override
  Stream<List<ChatRoom>> watchRooms(String uid) => Stream.value(rooms);

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId) =>
      const Stream.empty();

  @override
  Future<Result<void>> setRoomLiked(
      {required String roomId,
      required String uid,
      required bool liked}) async {
    this.liked.add((roomId: roomId, liked: liked));
    return const Success(null);
  }

  @override
  Future<Result<void>> sendMessage(
          {required String roomId,
          required String senderUid,
          required String senderName,
          required String text}) =>
      throw UnimplementedError();

  @override
  Future<Result<ChatRoom>> createRoom(
          {required String name,
          required Map<String, String> members,
          required String managerEmail}) =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profiles);

  final Map<String, UserProfile> profiles;

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(profiles[uid]);

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      Success([
        for (final uid in uids)
          if (profiles[uid] != null) profiles[uid]!
      ]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      Success(profiles.values.toList());

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
  _FakeFriendsRepository(this.following);

  final List<String> following;

  @override
  Stream<FriendRelations> watchRelations(String uid) =>
      Stream.value(FriendRelations(
          friends: const [], followers: const [], following: following));

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

UserProfile _profile(String uid, {ProfileTrack? track}) => UserProfile(
    uid: uid,
    userName: uid,
    profileImageUrl: '',
    backgroundImageUrl: '',
    track: track);

Future<_FakeMessengerRepository> _pump(
  WidgetTester tester, {
  required List<ChatRoom> rooms,
  List<String> following = const [],
}) async {
  tester.view.physicalSize = const Size(360, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final profiles = _FakeProfileRepository({
    'me': _profile('me'),
    'neon': _profile('neon',
        track: const ProfileTrack(
            id: '1',
            name: '도시의 불빛',
            artistsName: '네온 라디오',
            imageUrl: 'https://example.com/1.jpg')),
    'sea': _profile('sea',
        track: const ProfileTrack(
            id: '2',
            name: '파도 소리',
            artistsName: '해변의 오후',
            imageUrl: 'https://example.com/2.jpg')),
    'noSong': _profile('noSong'),
  });
  final messenger = _FakeMessengerRepository(rooms);
  Get.put(MessengerController(messenger, profiles, uid: 'me', userName: 'me'));
  Get.put(FriendsController(_FakeFriendsRepository(following), profiles,
      uid: 'me'));

  await tester.pumpWidget(const MaterialApp(home: MessengerFragment()));
  await tester.pump();
  await tester.pump();
  return messenger;
}

void main() {
  tearDown(Get.reset);

  testWidgets('친구들의 인생곡과 채팅방 목록을 보여주고, 즐겨찾기를 누를 수 있다', (tester) async {
    final messenger = await _pump(
      tester,
      following: const ['neon', 'sea', 'noSong'],
      rooms: const [
        ChatRoom(
          id: 'r1',
          name: '새벽 감성 모임',
          memberUids: ['me', 'neon', 'sea'],
          memberNames: {'me': '나', 'neon': 'night_neon', 'sea': 'morae_al'},
        ),
        ChatRoom(
            id: 'r2', name: '', memberUids: ['me', 'sea'], likedBy: ['me']),
      ],
    );

    expect(tester.takeException(), isNull);
    expect(find.text('친구들의 인생곡'), findsOneWidget);
    expect(find.text('♪ 도시의 불빛'), findsOneWidget);
    expect(find.text('♪ 파도 소리'), findsOneWidget);
    // 인생곡이 없는 친구는 나오지 않는다.
    expect(find.text('noSong'), findsNothing);

    expect(find.text('새벽 감성 모임'), findsOneWidget);
    expect(find.text('나, night_neon, morae_al'), findsOneWidget);
    expect(find.text('이름 없는 채팅방'), findsOneWidget);

    await tester.tap(find.byTooltip('즐겨찾기'));
    await tester.pump();
    expect(messenger.liked, [(roomId: 'r1', liked: true)]);
  });

  testWidgets('채팅방이 없으면 안내 문구, 인생곡 있는 친구가 없으면 그 줄을 숨긴다', (tester) async {
    await _pump(tester, rooms: const []);
    expect(find.text('아직 채팅방이 없어요.'), findsOneWidget);
    expect(find.text('친구들의 인생곡'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
