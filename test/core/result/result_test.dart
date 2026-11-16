import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';

void main() {
  group('Result', () {
    test('Success는 값을 담고 isSuccess가 true다', () {
      const Result<int> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailed, isFalse);
      expect(result.valueOrNull, 42);
    });

    test('Failed는 Failure를 담고 valueOrNull이 null이다', () {
      const Result<int> result = Failed(NotFoundFailure());

      expect(result.isSuccess, isFalse);
      expect(result.isFailed, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('fold는 성공과 실패를 각각 다른 콜백으로 처리한다', () {
      const Result<int> success = Success(1);
      const Result<int> failed = Failed(AuthFailure('로그인 실패', code: 'wrong-password'));

      String describe(Result<int> r) => r.fold(
            onSuccess: (value) => 'value: $value',
            onFailure: (failure) => 'failure: ${failure.message}',
          );

      expect(describe(success), 'value: 1');
      expect(describe(failed), 'failure: 로그인 실패');
    });

    test('switch로 실패 타입을 구분할 수 있다', () {
      const Result<String> result = Failed(AuthFailure('만료', code: 'token-expired'));

      final code = switch (result) {
        Success() => null,
        Failed(failure: AuthFailure(:final code)) => code,
        Failed() => 'other',
      };

      expect(code, 'token-expired');
    });
  });
}
