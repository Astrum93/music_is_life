import 'package:flutter/widgets.dart';

/// 모서리 토큰: 둥글기는 아래 단계만 쓴다.
abstract final class AppRadius {
  /// 태그, 작은 배지
  static const double s = 8;

  /// 입력창, 버튼, 썸네일
  static const double m = 12;

  /// 카드, 다이얼로그
  static const double l = 20;

  /// 바텀시트 윗모서리
  static const double xl = 28;

  /// 알약 모양 버튼, 프로필 사진
  static const double full = 999;

  static const borderS = BorderRadius.all(Radius.circular(s));
  static const borderM = BorderRadius.all(Radius.circular(m));
  static const borderL = BorderRadius.all(Radius.circular(l));
  static const borderFull = BorderRadius.all(Radius.circular(full));
}
