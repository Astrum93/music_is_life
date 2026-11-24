import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/features/auth/presentation/welcome/welcome_screen.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(
    initialRoute: Routes.welcome,
    getPages: [
      GetPage(name: Routes.welcome, page: () => const WelcomeScreen()),
      GetPage(
          name: Routes.login, page: () => const Scaffold(body: Text('로그인 화면'))),
      GetPage(
          name: Routes.join, page: () => const Scaffold(body: Text('회원가입 화면'))),
    ],
  ));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('문구와 예시 스펙트럼 카드를 보여준다', (tester) async {
    await _pump(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.text('당신의 인생곡은\n무엇인가요?'), findsOneWidget);
    expect(find.text('1,180일 동안 1,042곡을 기록하면'), findsOneWidget);
    expect(find.text('연대기 작가'), findsOneWidget);
    expect(find.text('DAY 1,180'), findsOneWidget);
  });

  testWidgets('[시작하기]는 회원가입, [로그인]은 로그인 화면으로 간다', (tester) async {
    await _pump(tester, const Size(390, 844));
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('회원가입 화면'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();
    await tester.tap(find.text('이미 계정이 있어요 · 로그인'));
    await tester.pumpAndSettle();
    expect(find.text('로그인 화면'), findsOneWidget);
  });

  testWidgets('세로가 짧은 화면에서도 넘치지 않고 스크롤해서 버튼에 닿는다', (tester) async {
    await _pump(tester, const Size(360, 560));
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('이미 계정이 있어요 · 로그인'), 200);
    expect(find.text('이미 계정이 있어요 · 로그인'), findsOneWidget);
  });
}
