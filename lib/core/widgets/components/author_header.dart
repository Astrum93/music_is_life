import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/album_art.dart';
import 'package:music_is_life/core/widgets/components/format.dart';
import 'package:music_is_life/core/widgets/components/tier_badge.dart';

/// 이야기 카드 위의 작성자 줄: 앨범 아바타, 이름, 칭호, "142번째 이야기 · D+530"
class AuthorHeader extends StatelessWidget {
  const AuthorHeader({
    super.key,
    required this.name,
    required this.avatar,
    required this.storyIndex,
    required this.dayCount,
    this.tier,
    this.trailing,
    this.onTap,
    this.onImage = false,
  });

  final String name;

  /// 작성자의 인생곡 앨범
  final ImageProvider? avatar;

  /// 이 이야기가 작성자의 몇 번째 기록인지
  final int storyIndex;

  /// 작성자의 가입일부터 지난 날
  final int dayCount;

  final Tier? tier;

  /// 오른쪽 끝 (팔로우 버튼 등)
  final Widget? trailing;

  final VoidCallback? onTap;

  /// 앨범 이미지 위에 올릴 때 true: 글자를 흰색으로 그린다.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final primary = onImage ? Colors.white : c.textPrimary;
    final secondary =
        onImage ? Colors.white.withValues(alpha: 0.8) : c.textSecondary;

    final content = Row(
      children: [
        AlbumArt(image: avatar, size: 38, radius: 11),
        const SizedBox(width: AppSpacing.s + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          t.titleMedium?.copyWith(fontSize: 14, color: primary),
                    ),
                  ),
                  if (tier != null) ...[
                    const SizedBox(width: 6),
                    TierBadge(tier!),
                  ],
                ],
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${formatCount(storyIndex)}번째 이야기',
                      style: TextStyle(
                          color: primary, fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' · ${formatDayCount(dayCount)}'),
                  ],
                ),
                style: t.labelMedium
                    ?.copyWith(color: secondary, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s),
          trailing!,
        ],
      ],
    );

    if (onTap == null) return content;
    return InkWell(
        onTap: onTap, borderRadius: AppRadius.borderM, child: content);
  }
}
