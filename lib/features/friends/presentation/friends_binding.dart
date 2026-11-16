import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/friends/data/repositories/firebase_friends_repository.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 홈(드로어·미니 프로필)과 마이페이지(팔로워 수·친구 찾기·팔로워 목록)에서 쓰는 친구 의존성
class FriendsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FriendsRepository>(
      () => FirebaseFriendsRepository(Get.find<FirebaseFirestore>()),
      fenix: true,
    );
    // 홈·마이페이지는 AuthMiddleware 뒤에 있으므로 로그인한 사용자가 항상 있다.
    final uid = Get.find<SessionController>().currentUser.value!.uid;
    Get.lazyPut(
      () => FriendsController(
        Get.find<FriendsRepository>(),
        Get.find<ProfileRepository>(),
        uid: uid,
      ),
    );
  }
}
