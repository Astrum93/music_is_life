import 'package:flutter/material.dart';

/// 글자 토큰: 앱에서 쓰는 글자 크기는 아래 단계만 쓴다.
///
/// 화면 코드에서는 `TextStyle(fontSize: 20, ...)` 대신
/// `context.textStyles.titleLarge`처럼 쓴다.
///
/// | 토큰            | 크기 | 굵기 | 용도                                   |
/// |-----------------|------|------|----------------------------------------|
/// | headlineMedium  | 26   | 800  | 화면 제목 ("라운지", "메신저")         |
/// | headlineSmall   | 22   | 800  | 이야기 제목 (카드 SIDE A)              |
/// | titleLarge      | 18   | 800  | 섹션 제목 ("디스코그래피")             |
/// | titleMedium     | 15   | 700  | 사용자 이름, 목록 제목                 |
/// | bodyLarge       | 16   | 400  | 입력창                                 |
/// | bodyMedium      | 15   | 400  | 이야기 본문, 기본 글자                 |
/// | bodySmall       | 13   | 400  | 보조 설명                              |
/// | labelLarge      | 14   | 700  | 버튼                                   |
/// | labelMedium     | 12   | 500  | 메타 정보 (142번째 이야기 · D+530)     |
/// | labelSmall      | 11   | 700  | 하단 탭, 칭호 배지                     |
///
/// 로고와 숫자(D+412, Vol.2, 날짜)는 [display]로 쓴다.
abstract final class AppTypography {
  /// 한글·본문 글꼴
  static const fontFamily = 'Pretendard';

  /// 로고·숫자 글꼴
  static const displayFontFamily = 'BricolageGrotesque';

  /// 글꼴 파일이 없을 때 쓰는 대체 글꼴
  static const fontFamilyFallback = <String>[
    'Apple SD Gothic Neo',
    'Noto Sans KR'
  ];

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle style(
      double size,
      FontWeight weight, {
      required double height,
      Color? color,
      double letterSpacing = -0.2,
    }) =>
        TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
          color: color ?? primary,
        );

    return TextTheme(
      headlineMedium:
          style(26, FontWeight.w800, height: 1.3, letterSpacing: -0.8),
      headlineSmall:
          style(22, FontWeight.w800, height: 1.32, letterSpacing: -0.7),
      titleLarge: style(18, FontWeight.w800, height: 1.35, letterSpacing: -0.5),
      titleMedium: style(15, FontWeight.w700, height: 1.4),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(15, FontWeight.w400, height: 1.6),
      bodySmall: style(13, FontWeight.w400, height: 1.5, color: secondary),
      labelLarge: style(14, FontWeight.w700, height: 1.3),
      labelMedium: style(12, FontWeight.w500, height: 1.35, color: secondary),
      labelSmall: style(11, FontWeight.w700, height: 1.3, letterSpacing: 0),
    );
  }

  /// 로고와 숫자용 글꼴 (Bricolage Grotesque)
  static TextStyle display({
    required double size,
    FontWeight weight = FontWeight.w800,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: displayFontFamily,
        fontFamilyFallback: const [fontFamily, ...fontFamilyFallback],
        fontSize: size,
        fontWeight: weight,
        // 가변 글꼴이라 굵기 축(wght)을 직접 지정해야 굵기가 바뀐다.
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
        height: 1.1,
        letterSpacing: size >= 20 ? -size * 0.04 : 0,
        color: color,
      );
}
