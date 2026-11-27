import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/entities/sign_up_params.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_is_life/features/auth/presentation/join/join_controller.dart';
import 'package:music_is_life/features/auth/presentation/join/join_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  Completer<Result<AuthUser>>? pending;
  SignUpParams? lastSignUp;

  @override
  Future<Result<AuthUser>> signUp(SignUpParams params) {
    lastSignUp = params;
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
  Get.put(JoinController(repository));
  await tester.pumpWidget(GetMaterialApp(
    initialRoute: Routes.join,
    getPages: [
      GetPage(name: Routes.join, page: () => const JoinScreen()),
      GetPage(
          name: Routes.home, page: () => const Scaffold(body: Text('HOME'))),
      GetPage(
          name: Routes.login, page: () => const Scaffold(body: Text('LOGIN'))),
    ],
  ));
  return repository;
}

Finder _field(int index) => find.byType(TextFormField).at(index);

Future<void> _fill(WidgetTester tester,
    {String name = '뮤직러버',
    String email = 'lover@example.com',
    String password = 'secret123',
    String confirm = 'secret123',
    String phone = '010-1234-5678'}) async {
  await tester.enterText(_field(0), name);
  await tester.enterText(_field(1), email);
  await tester.enterText(_field(2), password);
  await tester.enterText(_field(3), confirm);
  await tester.enterText(_field(4), phone);
}

Future<void> _tapJoin(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('가입하기'), 200,
      scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text('가입하기'));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('비밀번호가 다르면 가입하지 않고 재확인 칸 아래에 알려준다', (tester) async {
    final repository = await _pump(tester);

    await _fill(tester, confirm: 'secret999');
    await _tapJoin(tester);

    expect(repository.lastSignUp, isNull);
    expect(find.text('비밀번호가 일치하지 않습니다.'), findsOneWidget);
  });

  testWidgets('제대로 입력하면 공백을 정리해서 가입하고, 성공하면 홈으로 간다', (tester) async {
    final repository = await _pump(tester);

    await _fill(tester, name: ' 뮤직러버 ', email: ' lover@example.com ');
    await _tapJoin(tester);

    expect(
      repository.lastSignUp,
      const SignUpParams(
        name: '뮤직러버',
        email: 'lover@example.com',
        password: 'secret123',
        phoneNumber: '010-1234-5678',
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.pending!.complete(const Success(AuthUser(uid: 'u1')));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('실패하면 그대로 머물고 메시지를 보여준다', (tester) async {
    final repository = await _pump(tester);

    await _fill(tester);
    await _tapJoin(tester);
    repository.pending!.complete(const Failed(AuthFailure('이미 가입된 이메일이에요.')));
    await tester.pumpAndSettle();

    expect(find.text('이미 가입된 이메일이에요.'), findsOneWidget);
    expect(find.text('가입하기'), findsOneWidget);
  });

  testWidgets('비밀번호 보기 버튼은 두 칸을 함께 보이게 한다', (tester) async {
    await _pump(tester);
    bool obscured(int i) => tester
        .widget<EditableText>(
            find.descendant(of: _field(i), matching: find.byType(EditableText)))
        .obscureText;

    await tester.tap(find.byTooltip('비밀번호 보기'));
    await tester.pump();

    expect(obscured(2), isFalse);
    expect(obscured(3), isFalse);
  });

  testWidgets('로그인을 누르면 로그인 화면으로 간다', (tester) async {
    await _pump(tester);

    await tester.scrollUntilVisible(find.text('로그인'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });
}
