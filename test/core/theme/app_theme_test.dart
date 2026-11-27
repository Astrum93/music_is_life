import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

void main() {
  group('AppTheme.light (리디자인 시안)', () {
    final theme = AppTheme.light;
    const tokens = AppColorTokens.light;

    test('라이트 색상 토큰이 테마 확장으로 등록된다', () {
      expect(theme.extension<AppColorTokens>(), tokens);
      expect(theme.brightness, Brightness.light);
    });

    test('ColorScheme과 바탕색이 토큰 값을 따른다', () {
      expect(theme.colorScheme.primary, tokens.accent);
      expect(theme.colorScheme.surface, tokens.background);
      expect(theme.colorScheme.onSurface, tokens.textPrimary);
      expect(theme.colorScheme.error, tokens.danger);
      expect(theme.scaffoldBackgroundColor, tokens.background);
    });

    test('주요 버튼은 강조색이 아니라 글자색 바탕이다', () {
      final style = theme.filledButtonTheme.style!;
      expect(style.backgroundColor?.resolve({}), tokens.textPrimary);
      expect(style.foregroundColor?.resolve({}), tokens.surface);
    });

    test('입력창 테마가 들어간다', () {
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.fillColor, tokens.surface);
    });
  });

  group('AppTheme.dark (다크 모드 준비용)', () {
    final theme = AppTheme.dark;

    test('다크 색상 토큰이 등록된다', () {
      expect(theme.extension<AppColorTokens>(), AppColorTokens.dark);
      expect(theme.brightness, Brightness.dark);
    });

    test('입력창도 다크 토큰으로 채운다', () {
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.fillColor, AppColorTokens.dark.surface);
    });
  });

  test('글자 토큰이 정해진 단계와 글꼴을 따른다', () {
    final t = AppTheme.light.textTheme;
    expect(t.headlineMedium?.fontSize, 26);
    expect(t.headlineSmall?.fontSize, 22);
    expect(t.titleLarge?.fontSize, 18);
    expect(t.titleMedium?.fontSize, 15);
    expect(t.bodyMedium?.fontSize, 15);
    expect(t.bodySmall?.fontSize, 13);
    expect(t.labelMedium?.fontSize, 12);
    expect(t.labelSmall?.fontSize, 11);
    expect(t.headlineMedium?.fontWeight, FontWeight.w800);
    expect(t.bodyMedium?.fontFamily, AppTypography.fontFamily);
    expect(t.bodyMedium?.color, AppColorTokens.light.textPrimary);
    expect(t.bodySmall?.color, AppColorTokens.light.textSecondary);
  });

  test('숫자·로고용 display 글꼴', () {
    final style = AppTypography.display(size: 26);
    expect(style.fontFamily, AppTypography.displayFontFamily);
    expect(style.fontWeight, FontWeight.w800);
  });

  testWidgets('context.colors / context.textStyles로 토큰을 꺼낼 수 있다',
      (tester) async {
    late AppColorTokens colors;
    late TextTheme textStyles;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(builder: (context) {
          colors = context.colors;
          textStyles = context.textStyles;
          return const SizedBox();
        }),
      ),
    );

    expect(colors, AppColorTokens.light);
    expect(textStyles.titleLarge?.fontSize, 18);
  });
}
