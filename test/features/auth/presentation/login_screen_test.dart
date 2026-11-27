import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_is_life/features/auth/presentation/login/login_controller.dart';
import 'package:music_is_life/features/auth/presentation/login/login_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  Completer<Result<AuthUser>>? pending;
  ({String email, String password})? lastSignIn;

  @override
  Future<Result<AuthUser>> signIn(
      {required String email, required String password}) {
    lastSignIn = (email: email, password: password);
    pending = Completer();
    return pending!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeAuthRepository> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _FakeAuthRepository();
  Get.put(LoginController(repository));
  await tester.pumpWidget(GetMaterialApp(
    initialRoute: Routes.login,
    getPages: [
      GetPage(name: Routes.login, page: () => const LogInScreen()),
      GetPage(
          name: Routes.home, page: () => const Scaffold(body: Text('HOME'))),
      GetPage(
          name: Routes.join, page: () => const Scaffold(body: Text('JOIN'))),
    ],
  ));
  return repository;
}

Finder _field(int index) => find.byType(TextFormField).at(index);

void main() {
  tearDown(Get.reset);

  testWidgets('잘못 입력하면 보내지 않고 입력칸 아래에 이유를 보여준다', (tester) async {
    final repository = await _pump(tester);

    await tester.enterText(_field(0), 'not-mail');
    await tester.enterText(_field(1), '123');
    await tester.tap(find.text('로그인'));
    await tester.pump();

    expect(repository.lastSignIn, isNull);
    expect(find.text('올바른 메일을 입력해 주세요.'), findsOneWidget);
    expect(find.text('최소 6자리 이상을 입력해주세요.'), findsOneWidget);
  });

  testWidgets('로그인 중에는 버튼이 로딩으로 바뀌고, 성공하면 홈으로 간다', (tester) async {
    final repository = await _pump(tester);

    await tester.enterText(_field(0), '  me@example.com ');
    await tester.enterText(_field(1), 'secret1');
    await tester.tap(find.text('로그인'));
    await tester.pump();

    expect(
        repository.lastSignIn, (email: 'me@example.com', password: 'secret1'));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.pending!.complete(const Success(AuthUser(uid: 'u1')));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('실패하면 그대로 머물고 메시지를 보여준다', (tester) async {
    final repository = await _pump(tester);

    await tester.enterText(_field(0), 'me@example.com');
    await tester.enterText(_field(1), 'secret1');
    await tester.tap(find.text('로그인'));
    await tester.pump();
    repository.pending!
        .complete(const Failed(AuthFailure('이메일 또는 비밀번호가 맞지 않아요.')));
    await tester.pumpAndSettle();

    expect(find.text('이메일 또는 비밀번호가 맞지 않아요.'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('비밀번호 보기 버튼으로 가렸다 보였다 한다', (tester) async {
    await _pump(tester);
    bool obscured() => tester
        .widget<EditableText>(
            find.descendant(of: _field(1), matching: find.byType(EditableText)))
        .obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byTooltip('비밀번호 보기'));
    await tester.pump();
    expect(obscured(), isFalse);
  });

  testWidgets('시작하기를 누르면 회원가입으로 간다', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('JOIN'), findsOneWidget);
  });
}
