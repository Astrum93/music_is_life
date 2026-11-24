import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

void main() {
  group('AppTheme.dark', () {
    final theme = AppTheme.dark;
    const tokens = AppColorTokens.dark;

    test('색상 토큰이 테마 확장으로 등록된다', () {
      expect(theme.extension<AppColorTokens>(), tokens);
    });

    test('ColorScheme이 토큰 값을 따른다', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, tokens.accent);
      expect(theme.colorScheme.surface, tokens.background);
      expect(theme.colorScheme.onSurface, tokens.textPrimary);
      expect(theme.colorScheme.error, tokens.danger);
      expect(theme.scaffoldBackgroundColor, tokens.background);
    });

    test('글자 토큰 크기가 정해진 단계를 따른다', () {
      final t = theme.textTheme;
      expect(t.headlineSmall?.fontSize, 24);
      expect(t.titleLarge?.fontSize, 20);
      expect(t.titleMedium?.fontSize, 17);
      expect(t.bodyMedium?.fontSize, 15);
      expect(t.bodySmall?.fontSize, 13);
      expect(t.labelMedium?.fontSize, 12);
      expect(t.bodyMedium?.color, tokens.textPrimary);
      expect(t.bodySmall?.color, tokens.textSecondary);
    });
  });

  testWidgets('context.colors / context.textStyles로 토큰을 꺼낼 수 있다',
      (tester) async {
    late AppColorTokens colors;
    late TextTheme textStyles;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(builder: (context) {
          colors = context.colors;
          textStyles = context.textStyles;
          return const SizedBox();
        }),
      ),
    );

    expect(colors, AppColorTokens.dark);
    expect(textStyles.titleLarge?.fontSize, 20);
  });
}
