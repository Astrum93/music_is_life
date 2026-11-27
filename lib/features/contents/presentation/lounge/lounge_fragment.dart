import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/lounge/lounge_story_page.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';

/// 라운지: [전체] 세로로 넘기는 몰입형 이야기 피드 / [내 게시물] 내 이야기 2열 목록
///
/// 리디자인 라이트 테마를 이 화면에 적용한다.
class LoungeFragment extends StatefulWidget {
  const LoungeFragment({super.key});

  @override
  State<LoungeFragment> createState() => _LoungeFragmentState();
}

class _LoungeFragmentState extends State<LoungeFragment> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('라운지',
                            style: context.textStyles.headlineMedium),
                      ),
                      PillSegmentedControl(
                        labels: const ['전체', '내 게시물'],
                        selectedIndex: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _tab == 0 ? const _LoungeFeed() : const _MyStories(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 전체: 한 장씩 멈추며 넘어가고, 다음 이야기가 아래에 살짝 비친다.
class _LoungeFeed extends StatefulWidget {
  const _LoungeFeed();

  @override
  State<_LoungeFeed> createState() => _LoungeFeedState();
}

class _LoungeFeedState extends State<_LoungeFeed> {
  /// 화면의 92%만 한 장이 차지해서 다음 카드 윗부분이 보이게 한다.
  final _pages = PageController(viewportFraction: 0.92);
  int _current = 0;

  ContentsController get _contents => Get.find<ContentsController>();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = _contents.allContents.toList();
      final stats = StoryStats(all);
      final stories = all.where((c) => c.track != null).toList();
      final now = DateTime.now();

      if (stories.isEmpty) {
        return const _EmptyMessage(
          icon: Icons.album_outlined,
          title: '아직 라운지에 이야기가 없어요.',
          subtitle: '인생곡과 함께 첫 이야기를 남겨보세요.',
        );
      }
      final current = _current.clamp(0, stories.length - 1);

      return Stack(
        children: [
          PageView.builder(
            controller: _pages,
            scrollDirection: Axis.vertical,
            padEnds: false,
            itemCount: stories.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 10),
              child: LoungeStoryPage(
                key: ValueKey(stories[index].id),
                content: stories[index],
                stats: stats,
                now: now,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 24,
            child: _PositionTicks(stories: stories, current: current),
          ),
        ],
      );
    });
  }
}

/// 오른쪽 가장자리의 앨범 색 눈금: 지금 보는 이야기는 길고 진하게
class _PositionTicks extends StatelessWidget {
  const _PositionTicks({required this.stories, required this.current});

  final List<Content> stories;
  final int current;

  static const _window = 12;

  @override
  Widget build(BuildContext context) {
    final start = (current - _window ~/ 2)
        .clamp(0, (stories.length - _window).clamp(0, stories.length));
    final end = (start + _window).clamp(0, stories.length);
    return ExcludeSemantics(
      child: Column(
        children: [
          for (var i = start; i < end; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: i == current ? 28 : 14,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: spectrumColorOf(stories[i])
                    .withValues(alpha: i == current ? 1 : 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

/// 내 게시물: 내가 남긴 이야기를 최신순 2열로
class _MyStories extends StatelessWidget {
  const _MyStories();

  @override
  Widget build(BuildContext context) {
    final contents = Get.find<ContentsController>();
    final date = DateFormat('MM.dd');
    return Obx(() {
      final mine = contents.myContents.toList();
      if (mine.isEmpty) {
        return const _EmptyMessage(
          icon: Icons.edit_note_rounded,
          title: '아직 남긴 이야기가 없어요.',
          subtitle: '홈의 [기록하기]로 첫 이야기를 남겨보세요.',
        );
      }
      final stats = StoryStats(mine);
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                '내가 남긴 이야기 ${formatCount(mine.length)}개 · 최신순',
                style: context.textStyles.bodySmall,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                const gap = AppSpacing.s + 2;
                final tile = (constraints.crossAxisExtent - gap) / 2;
                return SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap,
                    mainAxisExtent: tile + 76,
                  ),
                  itemCount: mine.length,
                  itemBuilder: (context, index) {
                    final content = mine[index];
                    return _MyStoryTile(
                      content: content,
                      label:
                          '#${formatCount(stats.indexOf(content))} · ${date.format(content.createdAt)}',
                      size: tile,
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _MyStoryTile extends StatelessWidget {
  const _MyStoryTile({
    required this.content,
    required this.label,
    required this.size,
  });

  final Content content;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Material(
      color: c.surface,
      borderRadius: AppRadius.borderL,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => ContentDetailScreen(content: content)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumArt(
                image: networkImageOrNull(content.track?.imageUrl),
                size: size,
                radius: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: t.labelSmall?.copyWith(color: c.textTertiary)),
                  const SizedBox(height: 2),
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: context.colors.textTertiary),
            const SizedBox(height: AppSpacing.s),
            Text(title, style: context.textStyles.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: context.textStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
