import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';
import 'package:music_is_life/features/contents/presentation/screens/create_content_screen.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/add_friends_fragment.dart';
import 'package:music_is_life/features/friends/presentation/favorites/favorites_fragment.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_fragment.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_screen.dart';
import 'package:music_is_life/features/music/presentation/screens/youtube_search_screen.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';
import 'package:music_is_life/features/profile/presentation/widgets/edit_introduction_dialog.dart';
import 'package:music_is_life/features/profile/presentation/widgets/my_page_sections.dart';

/// 마이페이지 "내 일기장": 인생 스펙트럼 · 칭호 · 디스코그래피 · 타임라인
///
/// 개인 사진(프로필·배경)은 올리지 않고, 나의 인생곡 앨범이 나를 대표한다.
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  ProfileController get _profile => Get.find<ProfileController>();
  ContentsController get _contents => Get.find<ContentsController>();
  FriendsController get _friends => Get.find<FriendsController>();

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// 소개 수정 창은 자체적으로 라이트 테마를 입혀서 연다.
  void _editIntroduction() => EditIntroductionDialog.show(context);

  /// 나의 인생곡을 Spotify 앱으로 재생한다.
  Future<void> _playTrack(String trackId) async {
    final result = await Get.find<MusicController>().play(trackId);
    if (result case Failed(:final failure) when mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Obx(() {
              final profile = _profile.profile.value;
              if (profile == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final mine = [..._contents.myContents]
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
              final relations = _friends.relations.value;
              final now = DateTime.now();
              final stats = StoryStats(mine);
              final dayCount = stats.dayCountOf(_contents.uid, now);
              final volumes = discographyOf(mine);
              final months = groupByMonth(mine);
              final track = profile.track;

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _Header()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverList.list(
                      children: [
                        SpectrumCard(stories: mine, dayCount: dayCount),
                        const SizedBox(height: 20),
                        IdentitySection(
                          profile: profile,
                          tier: Tier.fromCount(mine.length),
                          dayCount: dayCount,
                          recordedDays: recordedDayCount(mine),
                          followers: relations.followers.length,
                          following: relations.following.length,
                          onEditIntroduction: _editIntroduction,
                          onChooseTrack: () =>
                              _push(const MusicCollectionScreen()),
                          onPlayTrack: () {
                            if (track != null) _playTrack(track.id);
                          },
                        ),
                        const SizedBox(height: AppSpacing.l),
                        TierProgressCard(storyCount: mine.length),
                        const SizedBox(height: 14),
                        _Actions(
                          onWrite: () => _push(const CreateContentScreen()),
                          onEditIntroduction: _editIntroduction,
                          onAddFriends: () => _push(const AddFriendsFragment()),
                          onMessages: () => _push(const MessengerFragment()),
                          onMusic: () => _push(const MusicCollectionScreen()),
                          onFavorites: () => _push(const FavoritesFragment()),
                          onYoutube: () => _push(const YoutubeSearchScreen()),
                        ),
                      ],
                    ),
                  ),
                  if (volumes.isNotEmpty) ...[
                    _SectionTitle(
                      title: '디스코그래피',
                      trailing: '정규 ${volumes.first.volume}집',
                    ),
                    SliverToBoxAdapter(
                      child: DiscographyShelf(volumes: volumes, now: now),
                    ),
                  ],
                  const _SectionTitle(title: '타임라인', trailing: '최신순'),
                  if (mine.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(child: _EmptyTimeline()),
                    )
                  else ...[
                    for (final group in months) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            '${group.year}년 ${group.month}월 · ${formatCount(group.stories.length)}곡',
                            style: context.textStyles.labelLarge?.copyWith(
                              fontSize: 13,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.builder(
                          itemCount: group.stories.length,
                          itemBuilder: (context, index) {
                            final story = group.stories[index];
                            final t = story.track;
                            return TimelineEntryTile(
                              date: story.createdAt,
                              storyIndex: stats.indexOf(story),
                              title: story.title,
                              trackLabel: t == null
                                  ? '곡 없음'
                                  : '${t.name} · ${t.artistsName}',
                              cover: networkImageOrNull(t?.imageUrl),
                              dotColor: spectrumColorOf(story),
                              onTap: () =>
                                  _push(ContentDetailScreen(content: story)),
                            );
                          },
                        ),
                      ),
                    ],
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverToBoxAdapter(
                        child: FirstPageCard(first: mine.first),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: '뒤로 가기',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: c.textPrimary),
          ),
          Expanded(
            child: Text(
              '내 일기장',
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// [이야기 쓰기] [소개 수정] + 바로가기 칩
class _Actions extends StatelessWidget {
  const _Actions({
    required this.onWrite,
    required this.onEditIntroduction,
    required this.onAddFriends,
    required this.onMessages,
    required this.onMusic,
    required this.onFavorites,
    required this.onYoutube,
  });

  final VoidCallback onWrite;
  final VoidCallback onEditIntroduction;
  final VoidCallback onAddFriends;
  final VoidCallback onMessages;
  final VoidCallback onMusic;
  final VoidCallback onFavorites;
  final VoidCallback onYoutube;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shortcuts = <(String, IconData, VoidCallback)>[
      ('친구 찾기', Icons.person_add_alt_1_outlined, onAddFriends),
      ('메시지', Icons.chat_bubble_outline_rounded, onMessages),
      ('음악 컬렉션', Icons.library_music_outlined, onMusic),
      ('친구 목록', Icons.people_outline_rounded, onFavorites),
      ('YouTube', Icons.smart_display_outlined, onYoutube),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onWrite,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                child: const Text('이야기 쓰기'),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: FilledButton(
                onPressed: onEditIntroduction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  backgroundColor: c.surface,
                  foregroundColor: c.textPrimary,
                ),
                child: const Text('소개 수정'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (label, icon, onTap) in shortcuts)
              ActionChip(
                onPressed: onTap,
                avatar: Icon(icon, size: 16, color: c.textPrimary),
                label: Text(label),
                labelStyle: context.textStyles.labelMedium?.copyWith(
                  fontSize: 13,
                  color: c.textPrimary,
                ),
                backgroundColor: c.surface,
                side: BorderSide.none,
                shape: const StadiumBorder(),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(title, style: context.textStyles.titleLarge)),
            Text(trailing, style: context.textStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.borderL,
      ),
      child: Column(
        children: [
          Icon(Icons.edit_note_rounded,
              size: 32, color: context.colors.textTertiary),
          const SizedBox(height: AppSpacing.s),
          Text('아직 남긴 이야기가 없어요.', style: context.textStyles.titleMedium),
          const SizedBox(height: 2),
          Text('첫 이야기가 일기장의 첫 페이지가 돼요.', style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}
