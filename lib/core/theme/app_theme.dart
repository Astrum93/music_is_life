import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 앱 전역 테마: 디자인 토큰을 Material 위젯 기본값에 연결한다.
///
/// 여기서 정한 값은 스타일을 직접 지정하지 않은 위젯에 자동으로 적용된다.
///
/// - [light]: 앱 기본 테마 (리디자인 시안)
/// - [dark]: 다크 모드를 위해 토큰만 맞춰 둔 테마. 아직 앱에서 쓰지 않는다.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColorTokens.light, Brightness.light);

  static ThemeData get dark => _build(AppColorTokens.dark, Brightness.dark);

  static ThemeData _build(AppColorTokens c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.textPrimary,
      onSecondary: c.surface,
      error: c.danger,
      onError: c.onAccent,
      surface: c.background,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface,
      surfaceContainerHighest: c.surfaceMuted,
      inverseSurface: c.inverseSurface,
      onInverseSurface: c.onInverseSurface,
      outline: c.border,
      outlineVariant: c.border,
    );

    final textTheme = AppTypography.textTheme(
      primary: c.textPrimary,
      secondary: c.textSecondary,
    );

    // 주요 버튼은 강조색이 아니라 글자색(검정) 바탕이다. 강조색은 반응·진행도에만 쓴다.
    final primaryButtonStyle = FilledButton.styleFrom(
      backgroundColor: c.textPrimary,
      foregroundColor: c.surface,
      textStyle: textTheme.labelLarge,
      minimumSize: const Size(64, 48),
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderM),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: textTheme,
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.textPrimary,
        unselectedItemColor: c.textTertiary,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.textPrimary,
        unselectedLabelColor: c.textTertiary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorColor: c.textPrimary,
        dividerColor: c.border,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderL),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.surfaceMuted,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: c.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderM),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: textTheme.bodyLarge?.copyWith(color: c.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderM,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderM,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderM,
          borderSide: BorderSide(color: c.textPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderM,
          borderSide: BorderSide(color: c.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderM,
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: primaryButtonStyle),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentText,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accentMuted,
        selectionHandleColor: c.accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
    );
  }
}
