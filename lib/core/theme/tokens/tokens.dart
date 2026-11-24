import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/app_color_tokens.dart';

export 'app_color_tokens.dart';
export 'app_radius.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// 화면에서 토큰을 꺼내 쓰는 단축 경로
///
/// ```dart
/// Text('Top 10', style: context.textStyles.titleLarge);
/// Container(color: context.colors.surface);
/// ```
extension ThemeTokensX on BuildContext {
  AppColorTokens get colors =>
      Theme.of(this).extension<AppColorTokens>() ?? AppColorTokens.dark;

  TextTheme get textStyles => Theme.of(this).textTheme;
}
