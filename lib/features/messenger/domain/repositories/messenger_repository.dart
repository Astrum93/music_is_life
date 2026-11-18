import 'dart:io';

import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';

/// 메신저 Repository
abstract interface class MessengerRepository {
  /// [uid]가 멤버인 채팅방
  Stream<List<ChatRoom>> watchRooms(String uid);

  /// 채팅방 메시지 (최신순)
  Stream<List<ChatMessage>> watchMessages(String roomId);

  Future<Result<void>> sendMessage({
    required String roomId,
    required String senderUid,
    required String senderName,
    required String text,
  });

  /// 채팅방 대표 사진을 올리고 다운로드 URL을 돌려준다.
  Future<Result<String>> uploadRoomImage(File image);

  /// 채팅방을 만든다. [members]는 uid -> 이름이고, 만드는 사람도 포함해야 한다.
  Future<Result<ChatRoom>> createRoom({
    required String name,
    required String imageUrl,
    required Map<String, String> members,
    required String managerEmail,
  });

  /// 채팅방 즐겨찾기를 켜거나 끈다.
  Future<Result<void>> setRoomLiked({
    required String roomId,
    required String uid,
    required bool liked,
  });
}
