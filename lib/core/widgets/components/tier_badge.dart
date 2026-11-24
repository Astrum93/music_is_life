import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 칭호: 인기도가 아니라 쌓은 기록(이야기) 수로 오른다.
enum Tier {
  collector(30, '수집가'),
  recorder(100, '기록가'),
  archivist(365, '아카이비스트'),
  chronicler(1000, '연대기 작가');

  const Tier(this.threshold, this.label);

  /// 이 칭호를 받는 최소 기록 수
  final int threshold;
  final String label;

  /// 기록 수에 맞는 칭호. 30개 미만이면 칭호가 없다.
  static Tier? fromCount(int count) {
    Tier? result;
    for (final tier in values) {
      if (count >= tier.threshold) result = tier;
    }
    return result;
  }

  /// 아직 받지 못한 다음 칭호. 가장 높은 칭호까지 받았으면 null.
  static Tier? nextAfter(int count) {
    for (final tier in values) {
      if (count < tier.threshold) return tier;
    }
    return null;
  }
}

/// 이름 옆에 붙는 칭호 배지
class TierBadge extends StatelessWidget {
  const TierBadge(this.tier, {super.key});

  final Tier tier;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (background, foreground) = switch (tier) {
      Tier.collector => (c.background, c.textSecondary),
      Tier.recorder => (c.accentMuted, c.accentText),
      Tier.archivist => (c.inverseSurface, c.gold),
      Tier.chronicler => (c.accentText, c.onAccent),
    };
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        tier.label,
        style: context.textStyles.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
