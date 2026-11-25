import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/album_art.dart';
import 'package:music_is_life/core/widgets/components/format.dart';

/// 마이페이지 타임라인의 한 줄: 날짜 · 세로선과 앨범 색 점 · 기록 카드
class TimelineEntryTile extends StatelessWidget {
  const TimelineEntryTile({
    super.key,
    required this.date,
    required this.storyIndex,
    required this.title,
    required this.trackLabel,
    required this.cover,
    required this.dotColor,
    this.onTap,
  });

  final DateTime date;

  /// 몇 번째 이야기인지 (#287)
  final int storyIndex;
  final String title;

  /// "곡 · 아티스트"
  final String trackLabel;
  final ImageProvider? cover;

  /// 이 곡의 앨범 대표색 (스펙트럼과 같은 색)
  final Color dotColor;
  final VoidCallback? onTap;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  Text('${date.day}',
                      style: AppTypography.display(
                          size: 18, color: c.textPrimary)),
                  const SizedBox(height: 2),
                  Text(_weekdays[date.weekday - 1],
                      style: t.labelSmall?.copyWith(
                          color: c.textTertiary, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          SizedBox(
            width: 10,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Center(child: Container(width: 2, color: c.border)),
                ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Material(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        AlbumArt(image: cover, size: 48),
                        const SizedBox(width: AppSpacing.s + 2),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titleMedium?.copyWith(fontSize: 14)),
                              Text('♪ $trackLabel',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        Text('#${formatCount(storyIndex)}',
                            style:
                                t.labelSmall?.copyWith(color: c.textTertiary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
