import 'package:flutter/material.dart';

/// 색상 토큰: 색의 "이름"이 아니라 "역할"로 부른다.
///
/// 화면 코드에서는 `Colors.white` 대신 `context.colors.textPrimary`처럼 쓴다.
/// 테마에 붙는 [ThemeExtension]이라 나중에 라이트 모드를 추가할 때
/// [light] 값만 만들면 화면 코드는 그대로 둘 수 있다.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentMuted,
    required this.danger,
    required this.success,
    required this.warning,
  });

  /// 화면 전체 바탕
  final Color background;

  /// 카드, 입력창, 바텀시트처럼 바탕 위에 한 겹 올라온 면
  final Color surface;

  /// 다이얼로그, 메뉴처럼 두 겹 올라온 면
  final Color surfaceElevated;

  /// 테두리, 구분선
  final Color border;

  /// 제목, 본문
  final Color textPrimary;

  /// 보조 설명, 비활성 탭
  final Color textSecondary;

  /// 힌트, 캡션처럼 가장 약한 글자
  final Color textTertiary;

  /// 브랜드 강조 색: 선택된 탭, 주요 버튼, 링크
  final Color accent;

  /// [accent] 위에 올리는 글자·아이콘
  final Color onAccent;

  /// 선택된 항목의 옅은 배경
  final Color accentMuted;

  /// 삭제, 로그아웃, 오류
  final Color danger;

  /// 완료, 확인
  final Color success;

  /// 주의
  final Color warning;

  /// 다크 테마 값 (현재 앱의 유일한 테마)
  static const dark = AppColorTokens(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF161616),
    surfaceElevated: Color(0xFF212121),
    border: Color(0xFF2D2D2D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB3B3B3),
    textTertiary: Color(0xFF8B8B8B),
    accent: Color(0xFF00B9CE),
    onAccent: Color(0xFF000000),
    accentMuted: Color(0x2900B9CE),
    danger: Color(0xFFFF6666),
    success: Color(0xFF84CEBF),
    warning: Color(0xFFDE7030),
  );

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    Color? accentMuted,
    Color? danger,
    Color? success,
    Color? warning,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentMuted: accentMuted ?? this.accentMuted,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColorTokens lerp(AppColorTokens? other, double t) {
    if (other == null) return this;
    return AppColorTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
