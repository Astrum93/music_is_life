import 'package:music_is_life/core/error/failure.dart';

/// 성공 또는 실패를 담는 결과 타입.
///
/// Repository는 예외를 던지지 않고 [Result]를 돌려준다.
/// ```dart
/// final result = await repository.fetchProfile(uid);
/// switch (result) {
///   case Success(:final value): profile.value = value;
///   case Failed(:final failure): errorMessage.value = failure.message;
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailed => this is Failed<T>;

  /// 성공이면 값을, 실패면 null을 돌려준다.
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failed() => null,
      };

  /// 성공과 실패를 각각 다른 값으로 바꾼다.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failed(:final failure) => onFailure(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;
}
