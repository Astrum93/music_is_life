import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 프로필 사진 종류
enum ProfileImageKind { profile, background }

/// 내 프로필 화면 상태
class ProfileController extends GetxController {
  ProfileController(this._repository, this.uid);

  final ProfileRepository _repository;

  /// 프로필 주인 (현재는 로그인한 나)
  final String uid;

  final profile = Rxn<UserProfile>();
  final isSaving = false.obs;

  StreamSubscription<UserProfile?>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _repository.watchProfile(uid).listen(profile.call);
  }

  Future<Result<void>> updateImage(ProfileImageKind kind, File image) => _saving(
        () => switch (kind) {
          ProfileImageKind.profile => _repository.updateProfileImage(uid, image),
          ProfileImageKind.background => _repository.updateBackgroundImage(uid, image),
        },
      );

  Future<Result<void>> updateIntroduction(String introduction) =>
      _saving(() => _repository.updateIntroduction(uid, introduction));

  Future<Result<void>> _saving(Future<Result<void>> Function() action) async {
    isSaving.value = true;
    try {
      return await action();
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
