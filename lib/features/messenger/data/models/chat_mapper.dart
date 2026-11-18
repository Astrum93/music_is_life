import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';

List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const <String>[];

String _str(Object? v) => v is String ? v : '';

/// UserChats 문서 -> [ChatRoom] (기존 필드 이름: chatName, chatImage, member, memberNames, likedMember)
ChatRoom chatRoomFromFirestore(String id, Map<String, dynamic> data) {
  final names = data['memberNames'];
  return ChatRoom(
    id: id,
    name: _str(data['chatName']),
    imageUrl: _str(data['chatImage']),
    memberUids: _strList(data['member']),
    memberNames: names is Map
        ? {
            for (final e in names.entries)
              if (e.key is String && e.value is String)
                e.key as String: e.value as String,
          }
        : const {},
    likedBy: _strList(data['likedMember']),
  );
}

/// messages 문서 -> [ChatMessage] (기존 필드 이름: sender, senderName, text, timestamp)
ChatMessage chatMessageFromFirestore(String id, Map<String, dynamic> data) {
  final ts = data['timestamp'];
  final sender = _str(data['sender']);
  final senderName = _str(data['senderName']);
  return ChatMessage(
    id: id,
    senderUid: sender,
    senderName: senderName.isEmpty ? sender : senderName,
    text: _str(data['text']),
    sentAt:
        ts is Timestamp ? ts.toDate() : DateTime.fromMillisecondsSinceEpoch(0),
  );
}
