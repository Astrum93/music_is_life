import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeMessengerRepository implements MessengerRepository {
  final rooms = StreamController<List<ChatRoom>>.broadcast();
  final calls = <String>[];
  Map<String, String>? createdMembers;

  @override
  Stream<List<ChatRoom>> watchRooms(String uid) => rooms.stream;

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId) => const Stream.empty();

  @override
  Future<Result<void>> sendMessage({
    required String roomId,
    required String senderUid,
    required String senderName,
    required String text,
  }) async {
    calls.add('send:$roomId:$senderUid:$senderName:$text');
    return const Success(null);
  }

  @override
  Future<Result<void>> setRoomLiked({required String roomId, required String uid, required bool liked}) async {
    calls.add('like:$roomId:$uid:$liked');
    return const Success(null);
  }

  @override
  Future<Result<ChatRoom>> createRoom({
    required String name,
    required Map<String, String> members,
    required String managerEmail,
  }) async {
    createdMembers = members;
    return Success(ChatRoom(id: 'new', name: name, memberUids: members.keys.toList()));
  }
}

class _NoProfiles implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeMessengerRepository repository;

  setUp(() => repository = _FakeMessengerRepository());

  group('MessengerController', () {
    late MessengerController controller;

    setUp(() {
      controller = MessengerController(repository, _NoProfiles(), uid: 'me', userName: '나')..onInit();
    });

    tearDown(() => controller.onClose());

    test('내 채팅방 목록을 구독한다', () async {
      repository.rooms.add([const ChatRoom(id: 'r1', name: '방')]);
      await Future<void>.delayed(Duration.zero);

      expect(controller.rooms.single.id, 'r1');
    });

    test('메시지는 내 uid와 이름으로 보낸다', () async {
      await controller.send('r1', '안녕');

      expect(repository.calls, ['send:r1:me:나:안녕']);
    });

    test('내 메시지인지 senderUid로 판단한다 (예전에는 이름으로 비교)', () {
      final mine = ChatMessage(id: '1', senderUid: 'me', senderName: '다른이름', text: '', sentAt: DateTime(2024));
      final other = ChatMessage(id: '2', senderUid: 'you', senderName: '나', text: '', sentAt: DateTime(2024));

      expect(controller.isMine(mine), isTrue);
      expect(controller.isMine(other), isFalse);
    });

    test('즐겨찾기가 꺼져 있으면 켜고, 켜져 있으면 끈다', () async {
      await controller.toggleLike(const ChatRoom(id: 'a', name: ''));
      await controller.toggleLike(const ChatRoom(id: 'b', name: '', likedBy: ['me']));

      expect(repository.calls, ['like:a:me:true', 'like:b:me:false']);
    });
  });

  group('CreateChatController', () {
    late CreateChatController controller;

    setUp(() {
      controller = CreateChatController(repository, uid: 'me', userName: '나', email: 'me@example.com')
        ..onInit();
    });

    test('처음부터 나는 멤버이고, 나를 뺄 수 없다', () {
      controller.toggleMember('me', '나');

      expect(controller.members, {'me': '나'});
    });

    test('친구를 누르면 추가되고 다시 누르면 빠진다', () {
      controller.toggleMember('you', '너');
      expect(controller.members, {'me': '나', 'you': '너'});

      controller.toggleMember('you', '너');
      expect(controller.members, {'me': '나'});
    });

    test('이름이 없으면 만들지 않는다', () async {
      final result = await controller.create();

      expect((result as Failed).failure, isA<InvalidRequestFailure>());
      expect(repository.createdMembers, isNull);
    });

    test('친구를 고르지 않으면(나 혼자면) 만들지 않는다', () async {
      controller.name.value = '방';

      final result = await controller.create();

      expect((result as Failed).failure, isA<InvalidRequestFailure>());
      expect(repository.createdMembers, isNull);
    });

    test('이름과 친구가 있으면 사진 없이 멤버를 함께 넘겨 만든다', () async {
      controller
        ..name.value = '방'
        ..toggleMember('you', '너');

      final result = await controller.create();

      expect(result.valueOrNull?.imageUrl, '');
      expect(repository.createdMembers, {'me': '나', 'you': '너'});
    });
  });
}
