import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';

/// 채팅방 (UserChats/{id})
@freezed
abstract class ChatRoom with _$ChatRoom {
  const ChatRoom._();

  const factory ChatRoom({
    required String id,
    required String name,
    @Default('') String imageUrl,

    /// 멤버 uid (Firestore 쿼리·보안 규칙용)
    @Default(<String>[]) List<String> memberUids,

    /// 멤버 uid -> 화면에 보여줄 이름
    @Default(<String, String>{}) Map<String, String> memberNames,

    /// 즐겨찾기(좋아요)한 멤버 uid
    @Default(<String>[]) List<String> likedBy,
  }) = _ChatRoom;

  /// 화면에 보여줄 멤버 이름 목록 (이름이 없으면 uid)
  List<String> get memberDisplayNames =>
      [for (final uid in memberUids) memberNames[uid] ?? uid];

  bool isLikedBy(String uid) => likedBy.contains(uid);
}

/// 채팅 메시지 (UserChats/{roomId}/messages/{id})
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderUid,

    /// 보낸 당시 이름 (화면 표시용으로 함께 저장된 값)
    required String senderName,
    required String text,
    required DateTime sentAt,
  }) = _ChatMessage;
}
