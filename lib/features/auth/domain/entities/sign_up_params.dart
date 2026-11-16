import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_params.freezed.dart';

/// 회원가입 입력값
@freezed
abstract class SignUpParams with _$SignUpParams {
  const factory SignUpParams({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) = _SignUpParams;
}
