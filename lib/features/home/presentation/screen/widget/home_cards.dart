import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/widgets/follow_button.dart';
import 'package:music_is_life/features/home/presentation/screen/widget/user_info_mini.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_player_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 홈 맨 위: "D+412 · 오늘은 288번째 이야기를 남겨볼까요?"
class MyDiaryCard extends StatelessWidget {
  const MyDiaryCard({
    super.key,
    required this.storyCount,
    required this.dayCount,
    required this.onWrite,
  });

  final int storyCount;
  final int dayCount;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final first = storyCount == 0;
    return _WhiteCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  first ? 'DAY 1' : formatDayCount(dayCount),
                  style: AppTypography.display(
                    size: 13,
                    weight: FontWeight.w700,
                    color: c.accentText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  first
                      ? '첫 번째 이야기를 남겨볼까요?'
                      : '오늘은 ${formatCount(storyCount + 1)}번째 이야기를 남겨볼까요?',
                  style: context.textStyles.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          FilledButton(
            onPressed: onWrite,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape:
                  const RoundedRectangleBorder(borderRadius: AppRadius.borderS),
            ),
            child: const Text('기록하기'),
          ),
        ],
      ),
    );
  }
}

/// "1년 전 오늘 · 52번째 이야기"
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.content,
    required this.storyIndex,
    required this.now,
  });

  final Content content;
  final int storyIndex;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final years = now.year - content.createdAt.year;
    final track = content.track;
    return _WhiteCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      child: Row(
        children: [
          AlbumArt(
              image: networkImageOrNull(track?.imageUrl), size: 52, radius: 12),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$years년 전 오늘 · ${formatCount(storyIndex)}번째 이야기',
                    style:
                        t.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium),
                if (track != null)
                  Text('♪ ${track.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 검은 기념 카드: "○○님이 365번째 이야기를 남겼어요 · 아카이비스트 달성"
class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.stats,
    required this.author,
  });

  final Milestone milestone;
  final StoryStats stats;

  /// 작성자 프로필 (인생곡 앨범). 아직 불러오지 못했으면 null.
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final content = milestone.content;
    final tier = milestone.reachedTier;
    final colors = stats
        .storiesOf(content.authorUid)
        .take(milestone.index)
        .map(spectrumColorOf)
        .toList();
    final onDark =
        t.bodyMedium?.copyWith(color: c.onInverseSurface, height: 1.4);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: c.inverseSurface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AlbumArt(
                image: networkImageOrNull(author?.track?.imageUrl),
                size: 36,
                radius: 10,
              ),
              const SizedBox(width: AppSpacing.s + 2),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: content.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                        text:
                            '님이\n${formatCount(milestone.index)}번째 이야기를 남겼어요'),
                  ]),
                  style: onDark?.copyWith(fontSize: 14),
                ),
              ),
              if (tier != null)
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.gold,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    '${tier.label} 달성',
                    style: t.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.inverseSurface,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LifeSpectrum(
            colors: colors,
            height: 34,
            radius: 8,
            semanticLabel:
                '${content.authorName}님의 ${formatCount(milestone.index)}개 기록으로 그린 스펙트럼',
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DAY 1',
                  style: t.labelSmall?.copyWith(
                      color: c.onInverseSurfaceMuted,
                      fontWeight: FontWeight.w400)),
              Text('오늘',
                  style: t.labelSmall?.copyWith(
                      color: c.onInverseSurfaceMuted,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "지금 공감받는 이야기" 카드: 작성자 줄 + SIDE A/B 카드 + 반응 줄
class HomeStoryCard extends StatelessWidget {
  const HomeStoryCard({
    super.key,
    required this.content,
    required this.stats,
    required this.now,
  });

  static const width = 334.0;

  final Content content;
  final StoryStats stats;
  final DateTime now;

  ContentsController get _contents => Get.find<ContentsController>();

  Future<void> _toggleResonance(BuildContext context) async {
    final result = await _contents.toggleLike(content);
    if (result case Failed(:final failure) when context.mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  void _openAuthor(BuildContext context, UserProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => UserInfoMini(
        profileImage: profile.profileImageUrl,
        uid: profile.uid,
        name: profile.userName,
        userProfileInfo: profile.introduction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // pickHotStories가 곡이 붙은 이야기만 고르므로 track은 항상 있다.
    final track = content.track!;
    final cover = networkImageOrNull(track.imageUrl);
    final isMine = content.authorUid == _contents.uid;

    return SizedBox(
      width: width,
      child: _WhiteCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          children: [
            StreamBuilder<UserProfile?>(
              stream: _contents.watchAuthor(content.authorUid),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                return AuthorHeader(
                  name: content.authorName,
                  avatar: networkImageOrNull(profile?.track?.imageUrl),
                  storyIndex: stats.indexOf(content),
                  dayCount: stats.dayCountOf(content.authorUid, now),
                  tier: stats.tierOf(content.authorUid),
                  trailing:
                      isMine ? null : FollowButton(uid: content.authorUid),
                  onTap: profile == null
                      ? null
                      : () => _openAuthor(context, profile),
                );
              },
            ),
            const SizedBox(height: AppSpacing.m),
            if (cover == null)
              const SizedBox(height: 306)
            else
              StoryFlipCard(
                title: content.title,
                body: content.body,
                albumImage: cover,
                trackName: track.name,
                artistName: track.artistsName,
                onPlay: () => showTrackPlayerSheet(
                  context,
                  title: track.name,
                  artist: track.artistsName,
                  cover: cover,
                ),
              ),
            const SizedBox(height: AppSpacing.s),
            ReactionBar(
              resonanceCount: content.likeCount,
              resonated: _contents.isLikedByMe(content),
              onResonance: () => _toggleResonance(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 이야기가 하나도 없을 때
class EmptyStoriesCard extends StatelessWidget {
  const EmptyStoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.library_music_outlined,
              size: 32, color: context.colors.textTertiary),
          const SizedBox(height: AppSpacing.s),
          Text('아직 공감받은 이야기가 없어요.', style: context.textStyles.titleMedium),
          const SizedBox(height: 2),
          Text('인생곡과 함께 첫 이야기를 남겨보세요.', style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}

/// YouTube에서 곡 찾기: 곡 제목과 가수로 영상을 찾아 재생한다.
class HomeYoutubeSearch extends StatefulWidget {
  const HomeYoutubeSearch({super.key});

  @override
  State<HomeYoutubeSearch> createState() => _HomeYoutubeSearchState();
}

class _HomeYoutubeSearchState extends State<HomeYoutubeSearch> {
  final _title = TextEditingController();
  final _artist = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    super.dispose();
  }

  void _search() {
    final title = _title.text.trim();
    final artist = _artist.text.trim();
    if (title.isEmpty || artist.isEmpty) {
      showErrorSnackBar(context, '곡 제목과 가수를 모두 입력해 주세요.');
      return;
    }
    FocusScope.of(context).unfocus();
    showTrackPlayerSheet(context, title: title, artist: artist);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    InputDecoration field(String hint, IconData icon) => InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: c.textTertiary, size: 20),
          fillColor: c.background,
        );
    return _WhiteCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('YouTube에서 곡 찾기', style: context.textStyles.titleLarge),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: field('곡 제목', Icons.music_note_rounded),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _artist,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: field('가수', Icons.person_search_outlined),
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
            label: const Text('찾아서 듣기'),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.borderXl,
      ),
      child: child,
    );
  }
}
