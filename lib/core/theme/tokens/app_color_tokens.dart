import 'package:flutter/material.dart';

/// 색상 토큰: 색의 "이름"이 아니라 "역할"로 부른다.
///
/// 화면 코드에서는 `Colors.white` 대신 `context.colors.textPrimary`처럼 쓴다.
/// 테마에 붙는 [ThemeExtension]이라 테마([light] / [dark])만 바꾸면
/// 화면 코드는 그대로 둘 수 있다.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.accentMuted,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.onInverseSurfaceMuted,
    required this.gold,
    required this.live,
    required this.danger,
    required this.success,
    required this.warning,
  });

  /// 화면 전체 바탕
  final Color background;

  /// 카드, 입력창, 하단 탭처럼 바탕 위에 올라온 면
  final Color surface;

  /// 알약 토글의 바탕, 보조 버튼처럼 한 단계 눌린 면
  final Color surfaceMuted;

  /// 구분선, 테두리
  final Color border;

  /// 제목, 본문, 주요 버튼 바탕
  final Color textPrimary;

  /// 메타 정보(D+일수, 시간), 보조 설명
  final Color textSecondary;

  /// 비활성 탭, 힌트처럼 가장 약한 글자 (흰 바탕에서도 4.5:1 이상)
  final Color textTertiary;

  /// 브랜드 강조색: 공감 반응, 진행 막대, 로고의 점
  final Color accent;

  /// [accent] 위에 올리는 글자·아이콘
  final Color onAccent;

  /// 흰 바탕 위에 쓰는 강조색 글자 ([accent]보다 진해서 작은 글자도 읽힌다)
  final Color accentText;

  /// 강조색의 옅은 바탕 (기록가 칭호 배지 등)
  final Color accentMuted;

  /// 스펙트럼 카드, 기념 카드처럼 검게 뒤집힌 면
  final Color inverseSurface;

  /// [inverseSurface] 위의 글자
  final Color onInverseSurface;

  /// [inverseSurface] 위의 보조 글자
  final Color onInverseSurfaceMuted;

  /// 아카이비스트 칭호, DAY 1 같은 기념 표시
  final Color gold;

  /// "기록 중", 새 알림처럼 지금 일어나는 일
  final Color live;

  /// 삭제, 로그아웃, 오류
  final Color danger;

  /// 완료, 확인
  final Color success;

  /// 주의
  final Color warning;

  /// 라이트 테마 값: 리디자인 시안 기준
  static const light = AppColorTokens(
    background: Color(0xFFF4F4F5),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFE4E4E7),
    border: Color(0xFFE7E7EA),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF5C5C66),
    textTertiary: Color(0xFF71717A),
    accent: Color(0xFF6C47FF),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFF5A35F0),
    accentMuted: Color(0xFFEEE9FF),
    inverseSurface: Color(0xFF111111),
    onInverseSurface: Color(0xFFFFFFFF),
    onInverseSurfaceMuted: Color(0xFFA1A1AA),
    gold: Color(0xFFF5C451),
    live: Color(0xFFFF3366),
    danger: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
  );

  /// 다크 테마 값: 기존 화면을 옮기는 동안 앱이 쓰는 테마
  static const dark = AppColorTokens(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF161616),
    surfaceMuted: Color(0xFF212121),
    border: Color(0xFF2D2D2D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB3B3B3),
    textTertiary: Color(0xFF8B8B8B),
    accent: Color(0xFF8B6CFF),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFFA48CFF),
    accentMuted: Color(0x338B6CFF),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF111111),
    onInverseSurfaceMuted: Color(0xFF5C5C66),
    gold: Color(0xFFF5C451),
    live: Color(0xFFFF5C85),
    danger: Color(0xFFFF6666),
    success: Color(0xFF84CEBF),
    warning: Color(0xFFDE7030),
  );

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    Color? accentText,
    Color? accentMuted,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? onInverseSurfaceMuted,
    Color? gold,
    Color? live,
    Color? danger,
    Color? success,
    Color? warning,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentText: accentText ?? this.accentText,
      accentMuted: accentMuted ?? this.accentMuted,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      onInverseSurfaceMuted:
          onInverseSurfaceMuted ?? this.onInverseSurfaceMuted,
      gold: gold ?? this.gold,
      live: live ?? this.live,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColorTokens lerp(AppColorTokens? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorTokens(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentText: mix(accentText, other.accentText),
      accentMuted: mix(accentMuted, other.accentMuted),
      inverseSurface: mix(inverseSurface, other.inverseSurface),
      onInverseSurface: mix(onInverseSurface, other.onInverseSurface),
      onInverseSurfaceMuted:
          mix(onInverseSurfaceMuted, other.onInverseSurfaceMuted),
      gold: mix(gold, other.gold),
      live: mix(live, other.live),
      danger: mix(danger, other.danger),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
    );
  }
}
