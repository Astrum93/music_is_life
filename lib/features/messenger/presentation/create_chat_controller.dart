import 'dart:io';

import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';

/// 새 채팅방 만들기 화면 상태 (예전 ChatData)
class CreateChatController extends GetxController {
  CreateChatController(
    this._repository, {
    required this.uid,
    required this.userName,
    required this.email,
  });

  final MessengerRepository _repository;

  /// 방을 만드는 나 (항상 멤버에 포함되고 뺄 수 없다)
  final String uid;
  final String userName;
  final String email;

  final name = ''.obs;
  final imageUrl = ''.obs;

  /// 멤버 uid -> 이름
  final members = <String, String>{}.obs;

  final isUploading = false.obs;
  final isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    members[uid] = userName;
  }

  bool isMember(String memberUid) => members.containsKey(memberUid);

  void toggleMember(String memberUid, String memberName) {
    if (memberUid == uid) return;
    if (members.containsKey(memberUid)) {
      members.remove(memberUid);
    } else {
      members[memberUid] = memberName;
    }
  }

  Future<Result<void>> uploadImage(File image) async {
    isUploading.value = true;
    try {
      final result = await _repository.uploadRoomImage(image);
      if (result case Success(:final value)) imageUrl.value = value;
      return result;
    } finally {
      isUploading.value = false;
    }
  }

  Future<Result<ChatRoom>> create() async {
    if (name.value.trim().isEmpty) {
      return const Failed(
          InvalidRequestFailure('채팅방 이름을 입력해 주세요.', code: 'no-name'));
    }
    if (isCreating.value) {
      return const Failed(
          InvalidRequestFailure('채팅방을 만드는 중입니다.', code: 'busy'));
    }
    isCreating.value = true;
    try {
      return await _repository.createRoom(
        name: name.value,
        imageUrl: imageUrl.value,
        members: Map.of(members),
        managerEmail: email,
      );
    } finally {
      isCreating.value = false;
    }
  }
}
