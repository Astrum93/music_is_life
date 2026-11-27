import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 맨 위 검은 카드: "412일 동안 287곡을 기록했어요" + 인생 스펙트럼
class SpectrumCard extends StatelessWidget {
  const SpectrumCard({
    super.key,
    required this.stories,
    required this.dayCount,
  });

  /// 내 이야기 (오래된 순)
  final List<Content> stories;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final muted = t.labelSmall?.copyWith(
      color: c.onInverseSurfaceMuted,
      fontWeight: FontWeight.w400,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: c.inverseSurface,
        borderRadius: AppRadius.borderXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIFE SPECTRUM',
                style: AppTypography.display(
                  size: 13,
                  weight: FontWeight.w700,
                  color: c.onInverseSurfaceMuted,
                ),
              ),
              Text('한 줄 = 한 곡', style: muted?.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stories.isEmpty
                ? '첫 이야기를 남기면 스펙트럼이 시작돼요'
                : '${formatCount(dayCount)}일 동안 ${formatCount(stories.length)}곡을 기록했어요',
            style:
                t.titleLarge?.copyWith(fontSize: 20, color: c.onInverseSurface),
          ),
          const SizedBox(height: 14),
          LifeSpectrum(
            colors: stories.map(spectrumColorOf).toList(),
            height: 112,
            semanticLabel: '가입 후 지금까지 ${stories.length}개 기록으로 그린 인생 스펙트럼',
          ),
          if (stories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('yyyy.MM.dd').format(stories.first.createdAt)} 첫 페이지',
                  style: muted,
                ),
                Text('오늘', style: muted),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 나의 인생곡 앨범 · 이름 · 칭호 · D+ · 팔로워 · 소개 · 나의 인생곡 칩
class IdentitySection extends StatelessWidget {
  const IdentitySection({
    super.key,
    required this.profile,
    required this.tier,
    required this.dayCount,
    required this.recordedDays,
    required this.followers,
    required this.following,
    required this.onEditIntroduction,
    required this.onChooseTrack,
    required this.onPlayTrack,
  });

  final UserProfile profile;
  final Tier? tier;
  final int dayCount;
  final int recordedDays;
  final int followers;
  final int following;
  final VoidCallback onEditIntroduction;
  final VoidCallback onChooseTrack;
  final VoidCallback onPlayTrack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final track = profile.track;
    final meta = t.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AlbumArt(
              image: networkImageOrNull(track?.imageUrl),
              size: 76,
              radius: 20,
              semanticLabel: track == null ? null : '나의 인생곡 ${track.name} 앨범',
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.headlineSmall,
                        ),
                      ),
                      if (tier != null) ...[
                        const SizedBox(width: AppSpacing.s),
                        TierBadge(tier!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text:
                            dayCount == 0 ? 'DAY 1' : formatDayCount(dayCount),
                        style: AppTypography.display(
                          size: 13,
                          weight: FontWeight.w800,
                          color: c.textPrimary,
                        ),
                      ),
                      TextSpan(text: ' · 기록한 날 ${formatCount(recordedDays)}일'),
                    ]),
                    style: meta,
                  ),
                  Text(
                    '팔로워 ${formatCount(followers)} · 팔로잉 ${formatCount(following)}',
                    style: meta,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        InkWell(
          onTap: onEditIntroduction,
          borderRadius: AppRadius.borderS,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              profile.introduction.isEmpty
                  ? '소개를 적어보세요.'
                  : profile.introduction,
              style: profile.introduction.isEmpty
                  ? t.bodyMedium?.copyWith(color: c.textTertiary)
                  : t.bodyMedium?.copyWith(fontSize: 14, height: 1.55),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        if (track == null)
          _Chip(
            onTap: onChooseTrack,
            leading: Icon(Icons.add_rounded, size: 18, color: c.textPrimary),
            label: '나의 인생곡 정하기',
          )
        else
          _Chip(
            onTap: onPlayTrack,
            leading: AlbumArt(
              image: networkImageOrNull(track.imageUrl),
              size: 20,
              radius: AppRadius.xs,
            ),
            label: '나의 인생곡 · ${track.name} — ${track.artistsName}',
            trailing:
                Icon(Icons.play_arrow_rounded, size: 18, color: c.textPrimary),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.onTap,
    required this.leading,
    required this.label,
    this.trailing,
  });

  final VoidCallback onTap;
  final Widget leading;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: AppRadius.borderFull,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderFull,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// "다음 칭호 아카이비스트까지 78곡" + 진행 막대 + 칭호 4단계
class TierProgressCard extends StatelessWidget {
  const TierProgressCard({super.key, required this.storyCount});

  final int storyCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final current = Tier.fromCount(storyCount);
    final next = Tier.nextAfter(storyCount);
    final from = current?.threshold ?? 0;
    final progress = next == null
        ? 1.0
        : ((storyCount - from) / (next.threshold - from)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration:
          BoxDecoration(color: c.surface, borderRadius: AppRadius.borderL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (next == null)
            Text('최고 칭호를 달성했어요', style: t.titleMedium?.copyWith(fontSize: 14))
          else
            Row(
              children: [
                Text('다음 칭호 ', style: t.titleMedium?.copyWith(fontSize: 14)),
                TierBadge(next),
                Expanded(
                    child: Text('까지',
                        style: t.titleMedium?.copyWith(fontSize: 14))),
                Text(
                  '${formatCount(next.threshold - storyCount)}곡',
                  style: t.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: c.accentText,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: c.background,
              color: c.accent,
              semanticsLabel: '다음 칭호까지 진행도',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final tier in Tier.values)
                Expanded(
                  child: Text(
                    '${tier.label} · ${formatCount(tier.threshold)}',
                    textAlign: switch (tier) {
                      Tier.collector => TextAlign.start,
                      Tier.chronicler => TextAlign.end,
                      _ => TextAlign.center,
                    },
                    style: t.labelSmall?.copyWith(
                      color: tier == current ? c.accentText : c.textTertiary,
                      fontWeight:
                          tier == current ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 디스코그래피: 해마다 묶은 Vol.N 커버를 가로로, 끝에는 다음 해 빈자리
class DiscographyShelf extends StatelessWidget {
  const DiscographyShelf({super.key, required this.volumes, required this.now});

  /// 최신 해가 앞에 온다.
  final List<DiscographyVolume> volumes;
  final DateTime now;

  static const _cover = 150.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final latest = volumes.first;
    return SizedBox(
      height: _cover + 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _VolumeTile(
            cover: Container(
              width: _cover,
              height: _cover,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(color: c.surfaceMuted, width: 2),
              ),
              child: Text(
                'Vol.${latest.volume + 1}',
                style: AppTypography.display(size: 15, color: c.textTertiary),
              ),
            ),
            title: '${latest.year + 1}',
            subtitle: '1월 1일에 시작돼요',
          ),
          for (final v in volumes)
            _VolumeTile(
              cover: DiscographyCover(
                volume: v.volume,
                covers: v.stories.reversed
                    .take(4)
                    .map((s) => networkImageOrNull(s.track?.imageUrl))
                    .toList(),
                recording: v.year == now.year,
                size: _cover,
              ),
              title: '${v.year}',
              subtitle: v.year == now.year
                  ? '${formatCount(v.stories.length)}곡 · 기록 중'
                  : '${formatCount(v.stories.length)}곡',
            ),
        ].reversed.toList(),
      ),
    );
  }
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({
    required this.cover,
    required this.title,
    required this.subtitle,
  });

  final Widget cover;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: SizedBox(
        width: DiscographyShelf._cover,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cover,
            const SizedBox(height: AppSpacing.s),
            Text(title,
                style: context.textStyles.titleMedium?.copyWith(fontSize: 14)),
            Text(subtitle,
                style: context.textStyles.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

/// 타임라인 맨 끝: "DAY 1 · 첫 페이지"
class FirstPageCard extends StatelessWidget {
  const FirstPageCard({super.key, required this.first});

  final Content first;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final track = first.track;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: c.inverseSurface, borderRadius: AppRadius.borderL),
      child: Row(
        children: [
          AlbumArt(
              image: networkImageOrNull(track?.imageUrl), size: 52, radius: 12),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAY 1 · 첫 페이지',
                  style: AppTypography.display(
                      size: 12, weight: FontWeight.w700, color: c.gold),
                ),
                Text(
                  DateFormat('yyyy년 M월 d일').format(first.createdAt),
                  style: t.titleMedium?.copyWith(color: c.onInverseSurface),
                ),
                Text(
                  track == null
                      ? first.title
                      : '♪ ${track.name} — ${track.artistsName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(color: c.onInverseSurfaceMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
