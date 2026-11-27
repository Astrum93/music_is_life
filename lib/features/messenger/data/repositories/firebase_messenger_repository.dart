import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/data/models/chat_mapper.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';

class FirebaseMessengerRepository implements MessengerRepository {
  FirebaseMessengerRepository(this._firestore, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('UserChats');

  @override
  Stream<List<ChatRoom>> watchRooms(String uid) => _rooms
      // 보안 규칙: member에 내 uid가 있는 방만 읽을 수 있다.
      .where('member', arrayContains: uid)
      .snapshots()
      .map((snap) =>
          [for (final d in snap.docs) chatRoomFromFirestore(d.id, d.data())]);

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId) => _rooms
      .doc(roomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => [
            for (final d in snap.docs) chatMessageFromFirestore(d.id, d.data())
          ]);

  @override
  Future<Result<void>> sendMessage({
    required String roomId,
    required String senderUid,
    required String senderName,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const Failed(
          InvalidRequestFailure('메시지를 입력해 주세요.', code: 'empty'));
    }
    try {
      // 예전에는 "분 + 마이크로초"로 만든 문자열을 문서 ID로 써서 ID가 겹칠 수 있었다.
      await _rooms.doc(roomId).collection('messages').add({
        'sender': senderUid,
        'senderName': senderName,
        'text': trimmed,
        'timestamp': Timestamp.fromDate(_now()),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('메시지를 보내지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('메시지를 보내지 못했습니다.', e));
    }
  }

  @override
  Future<Result<ChatRoom>> createRoom({
    required String name,
    required Map<String, String> members,
    required String managerEmail,
  }) async {
    if (name.trim().isEmpty || members.isEmpty) {
      return const Failed(
          InvalidRequestFailure('필요한 정보를 입력 해 주세요.', code: 'invalid'));
    }
    try {
      // 채팅방 이름이 같아도 다른 방을 덮어쓰지 않도록 자동 ID를 쓴다.
      final doc = _rooms.doc();
      await doc.set({
        'chatName': name.trim(),
        // 개인 사진은 올리지 않는다. 예전 채팅방과 형식을 맞추려고 필드는 빈 문자열로 남긴다.
        'chatImage': '',
        'manager': managerEmail,
        'member': members.keys.toList(),
        'memberNames': members,
        'likedMember': <String>[],
        'createdAt': Timestamp.fromDate(_now()),
      });
      return Success(ChatRoom(
        id: doc.id,
        name: name.trim(),
        memberUids: members.keys.toList(),
        memberNames: members,
      ));
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('채팅방을 만들지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('채팅방을 만들지 못했습니다.', e));
    }
  }

  @override
  Future<Result<void>> setRoomLiked({
    required String roomId,
    required String uid,
    required bool liked,
  }) async {
    try {
      await _rooms.doc(roomId).update({
        'likedMember': liked
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('즐겨찾기를 바꾸지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('즐겨찾기를 바꾸지 못했습니다.', e));
    }
  }
}
