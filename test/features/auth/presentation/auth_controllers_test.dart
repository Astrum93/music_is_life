import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/entities/sign_up_params.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_is_life/features/auth/presentation/join/join_controller.dart';
import 'package:music_is_life/features/auth/presentation/login/login_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  Completer<Result<AuthUser>>? pending;
  SignUpParams? lastSignUp;
  ({String email, String password})? lastSignIn;

  @override
  Future<Result<AuthUser>> signIn({required String email, required String password}) {
    lastSignIn = (email: email, password: password);
    pending = Completer();
    return pending!.future;
  }

  @override
  Future<Result<AuthUser>> signUp(SignUpParams params) {
    lastSignUp = params;
    pending = Completer();
    return pending!.future;
  }

  @override
  Stream<AuthUser?> authStateChanges() => const Stream.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<Result<void>> signOut() async => const Success(null);
}

void main() {
  late _FakeAuthRepository repository;

  setUp(() => repository = _FakeAuthRepository());

  group('LoginController', () {
    test('로그인 중에는 isLoading이 true이고 끝나면 false다', () async {
      final controller = LoginController(repository)
        ..email = 'a@b.com'
        ..password = 'pw1234';

      final future = controller.login();
      expect(controller.isLoading.value, isTrue);
      expect(repository.lastSignIn, (email: 'a@b.com', password: 'pw1234'));

      repository.pending!.complete(const Failed(AuthFailure('실패')));
      final result = await future;

      expect(controller.isLoading.value, isFalse);
      expect(result.isFailed, isTrue);
    });

    test('검증: 메일에 @가 없거나 비밀번호가 6자 미만이면 에러 메시지', () {
      final controller = LoginController(repository);

      expect(controller.validateEmail('abc'), isNotNull);
      expect(controller.validateEmail('a@b.com'), isNull);
      expect(controller.validatePassword('12345'), isNotNull);
      expect(controller.validatePassword('123456'), isNull);
    });
  });

  group('JoinController', () {
    test('비밀번호 재확인이 다르면 에러 (예전에는 길이만 검사했음)', () {
      final controller = JoinController(repository)..password = 'secret123';

      expect(controller.validatePasswordConfirm('secret999'), '비밀번호가 일치하지 않습니다.');
      expect(controller.validatePasswordConfirm('secret123'), isNull);
    });

    test('이름은 공백을 빼고 2자 이상이어야 한다', () {
      final controller = JoinController(repository);

      expect(controller.validateName('a'), isNotNull);
      expect(controller.validateName(' a '), isNotNull);
      expect(controller.validateName('뮤직러버'), isNull);
    });

    test('전화번호는 000-0000-0000 형식이어야 한다', () {
      final controller = JoinController(repository);

      expect(controller.validatePhoneNumber('-'), isNotNull);
      expect(controller.validatePhoneNumber('01012345678'), isNotNull);
      expect(controller.validatePhoneNumber('010-1234-5678'), isNull);
      expect(controller.validatePhoneNumber('02-123-4567'), isNull);
    });

    test('join은 입력값을 SignUpParams로 넘기고 isLoading을 관리한다', () async {
      final controller = JoinController(repository)
        ..name = '뮤직러버'
        ..email = 'lover@example.com'
        ..password = 'secret123'
        ..phoneNumber = '010-1234-5678';

      final future = controller.join();
      expect(controller.isLoading.value, isTrue);
      expect(
        repository.lastSignUp,
        const SignUpParams(
          name: '뮤직러버',
          email: 'lover@example.com',
          password: 'secret123',
          phoneNumber: '010-1234-5678',
        ),
      );

      repository.pending!.complete(const Success(AuthUser(uid: 'u1')));
      await future;
      expect(controller.isLoading.value, isFalse);
    });
  });
}
