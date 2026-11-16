import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/entities/sign_up_params.dart';

/// 인증 Repository.
///
/// 구현체는 예외를 던지지 않고 [Result]로 성공과 실패를 돌려준다.
abstract interface class AuthRepository {
  /// 로그인 상태가 바뀔 때마다 현재 사용자를 내보낸다. 로그아웃 상태면 null.
  Stream<AuthUser?> authStateChanges();

  /// 현재 로그인한 사용자. 로그아웃 상태면 null.
  AuthUser? get currentUser;

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// 계정을 만들고 사용자 기본 문서(UserInfo, UserFriends)를 저장한다.
  ///
  /// 이름이 이미 사용 중이면 `AuthFailure(code: 'name-already-in-use')`를 돌려준다.
  /// 중간에 실패하면 만들어진 계정을 지워서 반쯤 가입된 상태를 남기지 않는다.
  Future<Result<AuthUser>> signUp(SignUpParams params);

  Future<Result<void>> signOut();
}
