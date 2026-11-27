import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/contents/data/repositories/firebase_contents_repository.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    // 홈에서 이미 등록했으면 그대로 쓰고, 아니면 새로 등록한다.
    if (!Get.isRegistered<ContentsRepository>()) {
      Get.lazyPut<ContentsRepository>(
        () => FirebaseContentsRepository(Get.find<FirebaseFirestore>()),
        fenix: true,
      );
    }
    Get.lazyPut(
      () => AppSearchController(
          Get.find<ProfileRepository>(), Get.find<ContentsRepository>()),
    );
  }
}
