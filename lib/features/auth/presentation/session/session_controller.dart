import 'dart:async';

import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';

/// 앱 전역 로그인 상태.
///
/// InitialBinding에서 permanent로 등록되며, `AuthMiddleware`와 로그아웃 버튼이 사용한다.
class SessionController extends GetxController {
  SessionController(this._repository);

  final AuthRepository _repository;

  final currentUser = Rxn<AuthUser>();

  StreamSubscription<AuthUser?>? _subscription;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _repository.currentUser;
    _subscription = _repository.authStateChanges().listen(currentUser.call);
  }

  Future<Result<void>> logout() => _repository.signOut();

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
