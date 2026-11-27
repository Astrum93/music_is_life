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

  /// 멤버 uid -> 이름
  final members = <String, String>{}.obs;

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

  Future<Result<ChatRoom>> create() async {
    if (name.value.trim().isEmpty) {
      return const Failed(
          InvalidRequestFailure('채팅방 이름을 입력해 주세요.', code: 'no-name'));
    }
    if (members.length < 2) {
      return const Failed(
          InvalidRequestFailure('함께할 친구를 한 명 이상 골라주세요.', code: 'no-member'));
    }
    if (isCreating.value) {
      return const Failed(
          InvalidRequestFailure('채팅방을 만드는 중입니다.', code: 'busy'));
    }
    isCreating.value = true;
    try {
      return await _repository.createRoom(
        name: name.value,
        members: Map.of(members),
        managerEmail: email,
      );
    } finally {
      isCreating.value = false;
    }
  }
}
