import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 앱 시작 시 한 번 등록하는 전역 의존성.
///
/// Firebase 인스턴스와 여러 기능이 함께 쓰는 의존성(인증 등)을 여기서 등록하고,
/// 각 기능의 Binding에서 `Get.find`로 받아 생성자로 넘긴다.
/// Controller, Repository 안에서는 `Get.find`를 직접 호출하지 않는다.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);

    Get.put<AuthRepository>(
      FirebaseAuthRepository(Get.find<FirebaseAuth>(), Get.find<FirebaseFirestore>()),
      permanent: true,
    );
    Get.put(SessionController(Get.find<AuthRepository>()), permanent: true);

    // 프로필은 마이페이지뿐 아니라 게시물 작성자 표시 등 여러 기능에서 쓴다.
    Get.put<ProfileRepository>(
      FirebaseProfileRepository(Get.find<FirebaseFirestore>()),
      permanent: true,
    );
  }
}
