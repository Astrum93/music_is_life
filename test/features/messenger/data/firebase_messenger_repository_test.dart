import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/data/models/chat_mapper.dart';
import 'package:music_is_life/features/messenger/data/repositories/firebase_messenger_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late FirebaseMessengerRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    repository = FirebaseMessengerRepository(
      firestore,
      storage,
      now: () => DateTime(2026, 11, 17, 9, 30),
    );
  });

  group('mapper', () {
    test('memberNames가 없는 예전 채팅방은 uid를 이름 대신 보여준다', () {
      final room = chatRoomFromFirestore('r1', {
        'chatName': '방',
        'member': ['u1', 'u2'],
        'memberNames': {'u1': '나'},
      });

      expect(room.memberDisplayNames, ['나', 'u2']);
    });

    test('senderName이 없는 메시지는 sender를 이름으로 쓴다', () {
      final message = chatMessageFromFirestore('m1', {
        'sender': 'u1',
        'text': 'hi',
        'timestamp': Timestamp.fromDate(DateTime(2024)),
      });

      expect(message.senderName, 'u1');
      expect(message.sentAt, DateTime(2024));
    });
  });

  test('watchRooms는 내가 멤버인 방만 내보낸다', () async {
    await firestore.collection('UserChats').doc('a').set({'chatName': 'A', 'member': ['me', 'x']});
    await firestore.collection('UserChats').doc('b').set({'chatName': 'B', 'member': ['x']});

    final rooms = await repository.watchRooms('me').first;

    expect(rooms.map((r) => r.id), ['a']);
  });

  test('sendMessage는 자동 ID로 sender(uid)·senderName·timestamp를 저장한다', () async {
    final result = await repository.sendMessage(
      roomId: 'r1',
      senderUid: 'me',
      senderName: '나',
      text: '  안녕  ',
    );

    expect(result.isSuccess, isTrue);
    final messages = await repository.watchMessages('r1').first;
    expect(messages.single.senderUid, 'me');
    expect(messages.single.senderName, '나');
    expect(messages.single.text, '안녕');
    expect(messages.single.sentAt, DateTime(2026, 11, 17, 9, 30));
  });

  test('빈 메시지는 보내지 않는다', () async {
    final result = await repository.sendMessage(roomId: 'r1', senderUid: 'me', senderName: '나', text: '   ');

    expect((result as Failed).failure, isA<InvalidRequestFailure>());
    expect(await repository.watchMessages('r1').first, isEmpty);
  });

  test('watchMessages는 최신순이다', () async {
    final messages = firestore.collection('UserChats').doc('r1').collection('messages');
    await messages.add({'sender': 'a', 'text': 'old', 'timestamp': Timestamp.fromDate(DateTime(2024))});
    await messages.add({'sender': 'a', 'text': 'new', 'timestamp': Timestamp.fromDate(DateTime(2025))});

    final result = await repository.watchMessages('r1').first;

    expect(result.map((m) => m.text), ['new', 'old']);
  });

  test('createRoom은 자동 ID로 만들고 멤버 uid와 이름을 함께 저장한다', () async {
    final result = await repository.createRoom(
      name: ' 같은 이름 ',
      imageUrl: 'img',
      members: {'me': '나', 'you': '너'},
      managerEmail: 'me@example.com',
    );

    final room = result.valueOrNull!;
    final doc = await firestore.collection('UserChats').doc(room.id).get();
    expect(doc.data()!['chatName'], '같은 이름');
    expect(doc.data()!['member'], ['me', 'you']);
    expect(doc.data()!['memberNames'], {'me': '나', 'you': '너'});
    expect(doc.data()!['likedMember'], isEmpty);
  });

  test('이름이 비어 있으면 채팅방을 만들지 않는다', () async {
    final result = await repository.createRoom(
      name: '  ',
      imageUrl: '',
      members: {'me': '나'},
      managerEmail: '',
    );

    expect(result.isFailed, isTrue);
    expect((await firestore.collection('UserChats').get()).docs, isEmpty);
  });

  test('uploadRoomImage는 userChatImage/에 image 형식으로 올리고 URL을 돌려준다', () async {
    final file = File('${Directory.systemTemp.path}/chat_test.jpg')..writeAsBytesSync([1]);

    final result = await repository.uploadRoomImage(file);

    expect(result.valueOrNull, contains('userChatImage/'));
    final meta = storage.storedSettableMetadataMap.values.single;
    expect(meta['contentType'], 'image/jpeg');
  });

  test('setRoomLiked는 내 uid를 넣고 뺀다', () async {
    await firestore.collection('UserChats').doc('r1').set({'member': ['me'], 'likedMember': <String>[]});

    await repository.setRoomLiked(roomId: 'r1', uid: 'me', liked: true);
    expect((await firestore.collection('UserChats').doc('r1').get()).data()!['likedMember'], ['me']);

    await repository.setRoomLiked(roomId: 'r1', uid: 'me', liked: false);
    expect((await firestore.collection('UserChats').doc('r1').get()).data()!['likedMember'], isEmpty);
  });
}
