import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/create_content_screen.dart';
import 'package:music_is_life/features/home/presentation/drawer/home_drawer.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';
import 'package:music_is_life/features/home/presentation/screen/widget/home_cards.dart';
import 'package:music_is_life/features/home/presentation/story_stats.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/search/presentation/screen/search_fragment.dart';

/// 홈: 내 일기장 카드, N년 전 오늘, 기념 카드, 지금 공감받는 이야기, YouTube에서 곡 찾기
///
/// 리디자인 라이트 테마를 이 화면에만 먼저 적용한다. 다른 탭은 옮기기 전까지 다크 테마다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          drawer: HomeDrawer(),
          body: _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  ContentsController get _contents => Get.find<ContentsController>();
  HomeController get _home => Get.find<HomeController>();

  void _write(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateContentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = _contents.allContents.toList();
      final mine = _contents.myContents.toList();
      final me = _home.me.value;
      final now = DateTime.now();
      final stats = StoryStats(all);
      final hot = pickHotStories(all);
      final memory = pickMemory(mine, now);
      final milestone = pickRecentMilestone(all, stats, now);

      return ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          _HomeHeader(me: me),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                MyDiaryCard(
                  storyCount: mine.length,
                  dayCount: stats.dayCountOf(_contents.uid, now),
                  onWrite: () => _write(context),
                ),
                if (memory != null) ...[
                  const SizedBox(height: AppSpacing.s + 2),
                  MemoryCard(
                    content: memory,
                    storyIndex: stats.indexOf(memory),
                    now: now,
                  ),
                ],
                if (milestone != null) ...[
                  const SizedBox(height: AppSpacing.s + 2),
                  StreamBuilder<UserProfile?>(
                    stream: _contents.watchAuthor(milestone.content.authorUid),
                    builder: (context, snapshot) => MilestoneCard(
                      milestone: milestone,
                      stats: stats,
                      author: snapshot.data,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child:
                      Text('지금 공감받는 이야기', style: context.textStyles.titleLarge),
                ),
                if (hot.isNotEmpty)
                  Text('${hot.length}개', style: context.textStyles.bodySmall),
              ],
            ),
          ),
          if (hot.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmptyStoriesCard(),
            )
          else
            SizedBox(
              height: 470,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: hot.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.m),
                itemBuilder: (context, index) => Align(
                  alignment: Alignment.topCenter,
                  child: HomeStoryCard(
                    key: ValueKey(hot[index].id),
                    content: hot[index],
                    stats: stats,
                    now: now,
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: HomeYoutubeSearch(),
          ),
        ],
      );
    });
  }
}

/// 메뉴 · 로고 · 검색 · 내 인생곡 앨범(마이페이지)
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.me});

  final UserProfile? me;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: '메뉴 열기',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu_rounded, color: c.textPrimary),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'music is life'),
                TextSpan(text: '.', style: TextStyle(color: c.accent)),
              ]),
              style: AppTypography.display(size: 25, color: c.textPrimary),
            ),
          ),
          IconButton(
            tooltip: '검색',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchFragment()),
            ),
            icon: Icon(Icons.search_rounded, color: c.textPrimary),
          ),
          Semantics(
            button: true,
            label: '마이페이지',
            child: InkWell(
              onTap: () => Get.toNamed(Routes.myPage),
              borderRadius: AppRadius.borderS,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: AlbumArt(
                  image: networkImageOrNull(me?.track?.imageUrl),
                  size: 32,
                  radius: AppRadius.s,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
