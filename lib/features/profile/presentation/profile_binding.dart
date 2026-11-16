import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
      () => FirebaseProfileRepository(
        Get.find<FirebaseFirestore>(),
        Get.find<FirebaseStorage>(),
      ),
      fenix: true,
    );
    // 마이페이지는 AuthMiddleware 뒤에 있으므로 로그인한 사용자가 항상 있다.
    final uid = Get.find<SessionController>().currentUser.value!.uid;
    Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>(), uid));
  }
}
