/// 앱 전역에서 사용하는 실패 타입.
///
/// data 계층은 Firebase, 네트워크 등의 예외를 잡아서 [Failure]로 바꿔 돌려주고,
/// presentation 계층은 예외 대신 [Failure]만 다룬다.
sealed class Failure {
  const Failure(this.message);

  /// 사용자에게 보여줄 수 있는 메시지
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 로그인, 회원가입 등 인증 관련 실패
final class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.code});

  /// FirebaseAuthException.code 같은 원본 에러 코드
  final String? code;
}

/// Firestore, Storage 등 서버 요청 실패
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.code});

  final String? code;
}

/// 네트워크 연결 실패
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해 주세요.']);
}

/// 규칙상 할 수 없는 요청 (예: 나 자신을 친구로 추가, 이미 친구인 사용자 추가)
final class InvalidRequestFailure extends Failure {
  const InvalidRequestFailure(super.message, {this.code});

  final String? code;
}

/// 요청한 데이터가 없을 때
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = '데이터를 찾을 수 없습니다.']);
}

/// 분류되지 않은 실패
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다.', this.error]);

  /// 원본 예외 (디버깅용)
  final Object? error;
}
