import 'package:flutter/widgets.dart';

/// 모서리 토큰: 둥글기는 아래 단계만 쓴다.
abstract final class AppRadius {
  /// 칭호 배지, 작은 태그
  static const double xs = 6;

  /// 팔로우 버튼, 작은 앨범 썸네일
  static const double s = 10;

  /// 입력창, 주요 버튼, 프로필 앨범
  static const double m = 14;

  /// 목록 카드, 타임라인 항목, 디스코그래피 커버
  static const double l = 18;

  /// 이야기 카드, 스펙트럼 카드
  static const double xl = 24;

  /// 라운지 몰입형 카드, 바텀시트 윗모서리
  static const double xxl = 28;

  /// 알약 모양 (토글, 반응 버튼)
  static const double full = 999;

  static const borderXs = BorderRadius.all(Radius.circular(xs));
  static const borderS = BorderRadius.all(Radius.circular(s));
  static const borderM = BorderRadius.all(Radius.circular(m));
  static const borderL = BorderRadius.all(Radius.circular(l));
  static const borderXl = BorderRadius.all(Radius.circular(xl));
  static const borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const borderFull = BorderRadius.all(Radius.circular(full));
}
