import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/entities/sign_up_params.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';

class JoinController extends GetxController {
  JoinController(this._repository);

  final AuthRepository _repository;

  final isLoading = false.obs;

  String name = '';
  String email = '';
  String password = '';
  String passwordConfirm = '';
  String phoneNumber = '';

  // 이름은 Firestore 문서 ID로 쓰이므로 경로 구분자(/)는 허용하지 않는다.
  static final _invalidNameChars = RegExp(r'[/]');
  static final _phonePattern = RegExp(r'^\d{2,3}-\d{3,4}-\d{4}$');

  String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2) return '이름을 2자 이상 입력해 주세요.';
    if (_invalidNameChars.hasMatch(v)) return '이름에 / 는 사용할 수 없습니다.';
    return null;
  }

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || !v.contains('@')) return '올바른 메일을 입력해 주세요.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) return '최소 6자리 이상을 입력해주세요.';
    return null;
  }

  String? validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 한 번 더 입력해 주세요.';
    if (value != password) return '비밀번호가 일치하지 않습니다.';
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (!_phonePattern.hasMatch(value?.trim() ?? '')) {
      return '올바른 휴대전화 번호를 입력해 주세요. (000-0000-0000)';
    }
    return null;
  }

  /// 회원가입을 시도한다. 성공하면 바로 로그인된 상태가 된다.
  Future<Result<AuthUser>> join() async {
    isLoading.value = true;
    try {
      return await _repository.signUp(
        SignUpParams(
          name: name,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
