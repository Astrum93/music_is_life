import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';

class LoginController extends GetxController {
  LoginController(this._repository);

  final AuthRepository _repository;

  final isLoading = false.obs;

  String email = '';
  String password = '';

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || !v.contains('@')) return '올바른 메일을 입력해 주세요.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) return '최소 6자리 이상을 입력해주세요.';
    return null;
  }

  /// 로그인을 시도한다. 결과에 따른 화면 이동과 메시지는 화면에서 처리한다.
  Future<Result<AuthUser>> login() async {
    isLoading.value = true;
    try {
      return await _repository.signIn(email: email, password: password);
    } finally {
      isLoading.value = false;
    }
  }
}
