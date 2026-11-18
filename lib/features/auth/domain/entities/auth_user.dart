import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// 로그인한 사용자
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    String? email,

    /// 회원가입 때 입력한 이름. 현재 Firestore 문서 ID로도 쓰인다.
    String? displayName,
  }) = _AuthUser;
}
