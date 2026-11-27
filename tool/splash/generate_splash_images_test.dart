// 스플래시 화면용 로고 이미지를 앱 글꼴(Bricolage Grotesque)로 그려 assets/splash/에 저장한다.
//
//   flutter test tool/splash --update-goldens
//   dart run flutter_native_splash:create
//
// 웰컴·로그인 화면의 "music is life." 로고와 같은 글꼴·색을 쓴다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

const _out = '../../assets/splash';

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}

/// 투명 바탕 위의 "music is life." (마지막 점만 강조색)
Widget _wordmark(double size) => Text.rich(
      TextSpan(children: [
        const TextSpan(text: 'music is life'),
        TextSpan(
            text: '.',
            style: TextStyle(color: AppColorTokens.light.accent)),
      ]),
      textDirection: TextDirection.ltr,
      style: AppTypography.display(
          size: size, color: AppColorTokens.light.textPrimary),
    );

Future<void> _capture(WidgetTester tester,
    {required String name, required Size size, required Widget child}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          child: SizedBox.fromSize(size: size, child: Center(child: child)),
        ),
      ),
    ),
  );
  await expectLater(
      find.byType(RepaintBoundary).first, matchesGoldenFile('$_out/$name'));
}

void main() {
  setUpAll(() => _loadFont(
      'BricolageGrotesque', ['assets/fonts/BricolageGrotesque-Variable.ttf']));

  // iOS·Android(11 이하): 가운데 로고. 4배 밀도로 그리므로 화면에서는 약 220pt 폭이 된다.
  testWidgets('splash_logo.png', (tester) async {
    await _capture(tester,
        name: 'splash_logo.png',
        size: const Size(1000, 280),
        child: _wordmark(136));
  });

  // Android 12+: 아이콘 자리(지름의 2/3 원 안만 보임)에 들어가도록 작게 그린다.
  testWidgets('splash_logo_android12.png', (tester) async {
    await _capture(tester,
        name: 'splash_logo_android12.png',
        size: const Size(1152, 1152),
        child: _wordmark(96));
  });
}
