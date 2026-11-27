import 'package:flutter/widgets.dart';

/// 간격 토큰: 여백과 위젯 사이 간격은 4의 배수 단계만 쓴다.
///
/// `SizedBox(height: 10)`, `height20` 대신 `AppSpacing.gapM`처럼 쓰고,
/// 패딩은 `EdgeInsets.all(AppSpacing.l)`처럼 쓴다.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// 화면 좌우 여백
  static const double screenHorizontal = l;

  /// 섹션과 섹션 사이 간격
  static const double section = xxl;

  static const screenPadding =
      EdgeInsets.symmetric(horizontal: screenHorizontal);

  // 세로·가로 간격 위젯 (Column, Row 안에서 사용)
  static const gapXs = SizedBox(width: xs, height: xs);
  static const gapS = SizedBox(width: s, height: s);
  static const gapM = SizedBox(width: m, height: m);
  static const gapL = SizedBox(width: l, height: l);
  static const gapXl = SizedBox(width: xl, height: xl);
  static const gapXxl = SizedBox(width: xxl, height: xxl);
  static const gapSection = SizedBox(width: section, height: section);
}
