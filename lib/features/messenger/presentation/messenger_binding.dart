import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/messenger/data/repositories/firebase_messenger_repository.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

void _registerRepository() => Get.lazyPut<MessengerRepository>(
      () => FirebaseMessengerRepository(
        Get.find<FirebaseFirestore>(),
        Get.find<FirebaseStorage>(),
      ),
      fenix: true,
    );

/// 홈·마이페이지의 메신저 탭 (채팅방 목록, 채팅방)
class MessengerBinding extends Bindings {
  @override
  void dependencies() {
    _registerRepository();
    final user = Get.find<SessionController>().currentUser.value!;
    Get.lazyPut(
      () => MessengerController(
        Get.find<MessengerRepository>(),
        Get.find<ProfileRepository>(),
        uid: user.uid,
        userName: user.displayName ?? '',
      ),
    );
  }
}

/// 새 채팅방 만들기 화면. 화면을 닫으면 입력 상태도 함께 사라진다.
class CreateChatBinding extends Bindings {
  @override
  void dependencies() {
    _registerRepository();
    final user = Get.find<SessionController>().currentUser.value!;
    Get.lazyPut(
      () => CreateChatController(
        Get.find<MessengerRepository>(),
        uid: user.uid,
        userName: user.displayName ?? '',
        email: user.email ?? '',
      ),
    );
  }
}
