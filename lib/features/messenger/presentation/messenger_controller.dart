import 'dart:async';

import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 내 채팅방 목록과 채팅방 화면 상태
class MessengerController extends GetxController {
  MessengerController(
    this._repository,
    this._profileRepository, {
    required this.uid,
    required this.userName,
  });

  final MessengerRepository _repository;
  final ProfileRepository _profileRepository;

  /// 로그인한 나
  final String uid;
  final String userName;

  final rooms = <ChatRoom>[].obs;

  StreamSubscription<List<ChatRoom>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _repository.watchRooms(uid).listen(rooms.assignAll);
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) =>
      _repository.watchMessages(roomId);

  bool isMine(ChatMessage message) => message.senderUid == uid;

  /// 메시지 보낸 사람의 현재 프로필 (사진 표시용)
  Stream<UserProfile?> watchSender(String senderUid) =>
      _profileRepository.watchProfile(senderUid);

  Future<Result<void>> send(String roomId, String text) =>
      _repository.sendMessage(
        roomId: roomId,
        senderUid: uid,
        senderName: userName,
        text: text,
      );

  Future<Result<void>> toggleLike(ChatRoom room) => _repository.setRoomLiked(
        roomId: room.id,
        uid: uid,
        liked: !room.isLikedBy(uid),
      );

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
