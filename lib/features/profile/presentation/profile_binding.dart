import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // ProfileRepository는 InitialBinding에서 전역으로 등록한다.
    // 마이페이지는 AuthMiddleware 뒤에 있으므로 로그인한 사용자가 항상 있다.
    final uid = Get.find<SessionController>().currentUser.value!.uid;
    Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>(), uid));
  }
}
