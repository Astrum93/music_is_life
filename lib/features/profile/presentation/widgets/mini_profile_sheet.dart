import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_player_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 홈·검색에서 사람을 누르면 아래에서 올라오는 미니 프로필
Future<void> showMiniProfile(BuildContext context, UserProfile profile) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Theme(
      data: AppTheme.light,
      child: MiniProfileSheet(profile: profile),
    ),
  );
}

/// 인생곡 앨범 · 이름 · 칭호 · 소개 · 인생 스펙트럼 · 숫자 · 인생곡 · [팔로우]
///
/// 개인 사진 대신 그 사람의 인생곡 앨범을 보여준다.
class MiniProfileSheet extends StatefulWidget {
  const MiniProfileSheet({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<MiniProfileSheet> createState() => _MiniProfileSheetState();
}

class _MiniProfileSheetState extends State<MiniProfileSheet> {
  FriendsController get _friends => Get.find<FriendsController>();

  // 스트림을 build마다 새로 만들지 않도록 한 번만 만든다.
  late final Stream<FriendRelations> _relations =
      _friends.watchRelationsOf(widget.profile.uid);
  late final Stream<List<Content>> _stories =
      Get.find<ContentsController>().watchContentsOf(widget.profile.uid);

  bool get _isMe => widget.profile.uid == _friends.uid;

  Future<void> _toggleFollow() async {
    final result = await _friends.toggleFollow(widget.profile.uid);
    if (result case Failed(:final failure) when mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final profile = widget.profile;
    final track = profile.track;
    final cover = networkImageOrNull(track?.imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: StreamBuilder<List<Content>>(
            stream: _stories,
            builder: (context, snapshot) {
              final stories = [...?snapshot.data]
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
              final stats = StoryStats(stories);
              final count = stories.length;
              final tier = Tier.fromCount(count);
              final days = stats.dayCountOf(profile.uid, DateTime.now());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: c.border, borderRadius: AppRadius.borderFull),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      AlbumArt(
                        image: cover,
                        size: 68,
                        radius: AppRadius.l,
                        semanticLabel: track == null
                            ? null
                            : '${profile.userName}님의 인생곡 ${track.name} 앨범',
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(profile.userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.headlineSmall),
                                ),
                                if (tier != null) ...[
                                  const SizedBox(width: 6),
                                  TierBadge(tier),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              count == 0
                                  ? '아직 남긴 이야기가 없어요'
                                  : '${formatDayCount(days)} · 이야기 ${formatCount(count)}개',
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profile.introduction.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(profile.introduction.trim(),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium?.copyWith(fontSize: 14)),
                  ],
                  if (count > 0) ...[
                    const SizedBox(height: 14),
                    LifeSpectrum(
                      colors: [for (final s in stories) spectrumColorOf(s)],
                      height: 40,
                      radius: AppRadius.s,
                      semanticLabel:
                          '${profile.userName}님의 인생 스펙트럼, 기록 ${formatCount(count)}개',
                    ),
                  ],
                  const SizedBox(height: 14),
                  StreamBuilder<FriendRelations>(
                    stream: _relations,
                    builder: (context, snapshot) {
                      final relations = snapshot.data;
                      return _Numbers(
                        stories: count,
                        following: relations?.following.length,
                        followers: relations?.followers.length,
                      );
                    },
                  ),
                  if (track != null) ...[
                    const SizedBox(height: 14),
                    _LifeSongCard(
                      title: track.name,
                      artist: track.artistsName,
                      cover: cover,
                    ),
                  ],
                  if (!_isMe) ...[
                    const SizedBox(height: AppSpacing.m),
                    Obx(() {
                      final following = _friends.isFollowing(profile.uid);
                      return FilledButton(
                        onPressed: _toggleFollow,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor:
                              following ? c.background : c.textPrimary,
                          foregroundColor:
                              following ? c.textPrimary : c.surface,
                        ),
                        child: Text(following ? '팔로잉' : '팔로우'),
                      );
                    }),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 이야기 · 팔로잉 · 팔로워 (불러오는 중이면 -)
class _Numbers extends StatelessWidget {
  const _Numbers({required this.stories, this.following, this.followers});

  final int stories;
  final int? following;
  final int? followers;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    Widget cell(String label, int? value) => Expanded(
          child: Column(
            children: [
              Text(label,
                  style: t.labelSmall?.copyWith(
                      fontWeight: FontWeight.w400, color: c.textSecondary)),
              const SizedBox(height: 2),
              Text(value == null ? '-' : formatCount(value),
                  style: AppTypography.display(
                      size: 18, weight: FontWeight.w800, color: c.textPrimary)),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      decoration:
          BoxDecoration(color: c.background, borderRadius: AppRadius.borderL),
      child: Row(
        children: [
          cell('이야기', stories),
          cell('팔로잉', following),
          cell('팔로워', followers),
        ],
      ),
    );
  }
}

/// 검은 인생곡 카드: 누르면 그 곡을 재생한다.
class _LifeSongCard extends StatelessWidget {
  const _LifeSongCard(
      {required this.title, required this.artist, required this.cover});

  final String title;
  final String artist;
  final ImageProvider? cover;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: c.inverseSurface, borderRadius: AppRadius.borderL),
      child: Row(
        children: [
          AlbumArt(image: cover, size: 44, radius: AppRadius.s),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LIFE SONG',
                    style: AppTypography.display(
                        size: 11,
                        weight: FontWeight.w700,
                        color: c.onInverseSurfaceMuted)),
                Text('$title · $artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium
                        ?.copyWith(fontSize: 14, color: c.onInverseSurface)),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: '인생곡 듣기',
            onPressed: () => showTrackPlayerSheet(context,
                title: title, artist: artist, cover: cover),
            style: IconButton.styleFrom(
              backgroundColor: c.onInverseSurface,
              foregroundColor: c.inverseSurface,
              fixedSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}
