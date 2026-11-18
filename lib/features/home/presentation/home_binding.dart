import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 홈은 AuthMiddleware 뒤에 있으므로 로그인한 사용자가 항상 있다.
    final uid = Get.find<SessionController>().currentUser.value!.uid;
    Get.lazyPut(() => HomeController(Get.find<ProfileRepository>(), uid: uid));
  }
}
