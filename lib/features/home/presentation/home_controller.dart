import 'dart:async';

import 'package:get/get.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 홈 화면·드로어의 내 프로필 (상단 프로필 사진, 드로어 이름·사진)
///
/// 예전 HomeData는 사진 하나를 보여주려고 모든 사용자·게시물·플레이리스트를 읽었고,
/// FutureBuilder 때문에 화면을 다시 그릴 때마다 또 읽었다.
class HomeController extends GetxController {
  HomeController(this._profiles, {required this.uid});

  final ProfileRepository _profiles;

  /// 로그인한 나
  final String uid;

  final me = Rxn<UserProfile>();

  StreamSubscription<UserProfile?>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _profiles.watchProfile(uid).listen(me.call);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
