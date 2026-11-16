import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/contents/data/repositories/firebase_contents_repository.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 홈(피드·라운지)과 마이페이지(내 게시물·작성)에서 쓰는 게시물 의존성
class ContentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContentsRepository>(
      () => FirebaseContentsRepository(
        Get.find<FirebaseFirestore>(),
        Get.find<FirebaseStorage>(),
      ),
      fenix: true,
    );
    // 홈·마이페이지는 AuthMiddleware 뒤에 있으므로 로그인한 사용자가 항상 있다.
    final user = Get.find<SessionController>().currentUser.value!;
    Get.lazyPut(
      () => ContentsController(
        Get.find<ContentsRepository>(),
        Get.find<ProfileRepository>(),
        uid: user.uid,
        userName: user.displayName ?? '',
      ),
    );
  }
}
