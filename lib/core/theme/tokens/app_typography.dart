import 'package:flutter/material.dart';

/// 글자 토큰: 앱에서 쓰는 글자 크기는 아래 단계만 쓴다.
///
/// 화면 코드에서는 `TextStyle(fontSize: 20, ...)` 대신
/// `context.textStyles.titleLarge`처럼 쓴다.
///
/// | 토큰            | 크기 | 굵기 | 용도                        |
/// |-----------------|------|------|-----------------------------|
/// | headlineMedium  | 28   | 700  | 웰컴·빈 화면의 큰 문구      |
/// | headlineSmall   | 24   | 700  | 화면 제목                   |
/// | titleLarge      | 20   | 700  | 섹션 제목 ("Top 10" 등)     |
/// | titleMedium     | 17   | 600  | 카드·목록 제목, 사용자 이름 |
/// | bodyLarge       | 16   | 400  | 강조 본문, 입력창           |
/// | bodyMedium      | 15   | 400  | 기본 본문                   |
/// | bodySmall       | 13   | 400  | 보조 설명                   |
/// | labelLarge      | 15   | 600  | 버튼                        |
/// | labelMedium     | 12   | 500  | 탭, 태그, 캡션              |
/// | labelSmall      | 11   | 500  | 배지, 시간 표시             |
abstract final class AppTypography {
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle style(
      double size,
      FontWeight weight, {
      required double height,
      Color? color,
      double letterSpacing = 0,
    }) =>
        TextStyle(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
          color: color ?? primary,
        );

    return TextTheme(
      headlineMedium:
          style(28, FontWeight.w700, height: 1.3, letterSpacing: -0.4),
      headlineSmall:
          style(24, FontWeight.w700, height: 1.3, letterSpacing: -0.3),
      titleLarge: style(20, FontWeight.w700, height: 1.35, letterSpacing: -0.2),
      titleMedium: style(17, FontWeight.w600, height: 1.4),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(15, FontWeight.w400, height: 1.5),
      bodySmall: style(13, FontWeight.w400, height: 1.45, color: secondary),
      labelLarge: style(15, FontWeight.w600, height: 1.3),
      labelMedium: style(12, FontWeight.w500, height: 1.3, color: secondary),
      labelSmall: style(11, FontWeight.w500, height: 1.3, color: secondary),
    );
  }
}
