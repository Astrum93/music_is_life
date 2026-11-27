import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/widgets/follow_button.dart';
import 'package:music_is_life/features/profile/presentation/widgets/mini_profile_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';

/// 검색: 사용자 이름 / 이야기 제목
///
/// 사용자 결과에는 칭호와 인생 스펙트럼을 붙인다. 스펙트럼은 모두 같은 폭을 쓰고,
/// 기록 수는 줄의 개수(촘촘함)로만 드러난다.
class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final _query = TextEditingController();
  int _tab = 0;

  AppSearchController get _search => Get.find<AppSearchController>();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => _search.search(_query.text));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 홈 헤더의 검색 버튼으로 열렸을 때만 뒤로 가기 버튼이 필요하다.
    final canPop = Navigator.of(context).canPop();
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) {
            final c = context.colors;
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(canPop ? 4 : 16, 12, 16, 0),
                      child: Row(
                        children: [
                          if (canPop)
                            IconButton(
                              tooltip: '뒤로 가기',
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 20, color: c.textPrimary),
                            ),
                          Expanded(
                            child: TextField(
                              controller: _query,
                              textInputAction: TextInputAction.search,
                              style: context.textStyles.bodyLarge,
                              decoration: InputDecoration(
                                hintText: '사용자 이름이나 이야기 제목',
                                prefixIcon: Icon(Icons.search_rounded,
                                    color: c.textSecondary),
                                suffixIcon: ValueListenableBuilder(
                                  valueListenable: _query,
                                  builder: (context, value, _) =>
                                      value.text.isEmpty
                                          ? const SizedBox.shrink()
                                          : IconButton(
                                              tooltip: '지우기',
                                              onPressed: _query.clear,
                                              icon: Icon(Icons.cancel_rounded,
                                                  size: 20,
                                                  color: c.textTertiary),
                                            ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          PillSegmentedControl(
                            labels: const ['사용자', '이야기'],
                            selectedIndex: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                          const Spacer(),
                          // 결과 목록(Obx)과 검색어(ValueListenable) 어느 쪽이 바뀌어도 다시 그린다.
                          ValueListenableBuilder(
                            valueListenable: _query,
                            builder: (context, value, _) => Obx(() {
                              final count = _tab == 0
                                  ? _search.userResults.length
                                  : _search.contentResults.length;
                              return value.text.trim().isEmpty
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _tab == 0
                                          ? '사용자 ${formatCount(count)}명'
                                          : '이야기 ${formatCount(count)}개',
                                      style: context.textStyles.bodySmall,
                                    );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _query,
                        builder: (context, value, _) => Obx(() {
                          final keyword = value.text.trim();
                          final users = _search.userResults.toList();
                          final contents = _search.contentResults.toList();
                          if (keyword.isEmpty) {
                            return const _Message(
                              icon: Icons.manage_search_rounded,
                              title: '누구의 인생곡이 궁금한가요?',
                              subtitle: '사용자 이름이나 이야기 제목으로 찾아보세요.',
                            );
                          }
                          if ((_tab == 0 ? users.length : contents.length) ==
                              0) {
                            return _Message(
                              icon: Icons.search_off_rounded,
                              title: '‘$keyword’에 맞는 결과가 없어요.',
                              subtitle: '다른 단어로 찾아보세요.',
                            );
                          }
                          final stats = StoryStats(
                              Get.find<ContentsController>()
                                  .allContents
                                  .toList());
                          return _tab == 0
                              ? _UserResults(users: users, stats: stats)
                              : _StoryResults(contents: contents, stats: stats);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserResults extends StatelessWidget {
  const _UserResults({required this.users, required this.stats});

  final List<UserProfile> users;
  final StoryStats stats;

  @override
  Widget build(BuildContext context) {
    final me = Get.find<ContentsController>().uid;
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserResultCard(
          user: user,
          stories: stats.storiesOf(user.uid),
          dayCount: stats.dayCountOf(user.uid, now),
          showFollow: user.uid != me,
        );
      },
    );
  }
}

/// 사용자 결과 한 줄: 앨범 · 이름 · 칭호 · D+ · 이야기 수 · 팔로우 + 같은 폭의 스펙트럼
class UserResultCard extends StatelessWidget {
  const UserResultCard({
    super.key,
    required this.user,
    required this.stories,
    required this.dayCount,
    required this.showFollow,
  });

  final UserProfile user;

  /// 이 사용자의 이야기 (오래된 순)
  final List<Content> stories;
  final int dayCount;
  final bool showFollow;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final tier = Tier.fromCount(stories.length);
    return Material(
      color: c.surface,
      borderRadius: AppRadius.borderL,
      child: InkWell(
        borderRadius: AppRadius.borderL,
        onTap: () => showMiniProfile(context, user),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              Row(
                children: [
                  AlbumArt(
                      image: networkImageOrNull(user.track?.imageUrl),
                      size: 48,
                      radius: 13),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(user.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titleMedium),
                            ),
                            if (tier != null) ...[
                              const SizedBox(width: 6),
                              TierBadge(tier),
                            ],
                          ],
                        ),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: stories.isEmpty
                                  ? '아직 기록 없음'
                                  : formatDayCount(dayCount),
                              style: stories.isEmpty
                                  ? null
                                  : AppTypography.display(
                                      size: 12,
                                      weight: FontWeight.w800,
                                      color: c.textPrimary),
                            ),
                            if (stories.isNotEmpty)
                              TextSpan(
                                  text:
                                      ' · 이야기 ${formatCount(stories.length)}개'),
                          ]),
                          style: t.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  if (showFollow) FollowButton(uid: user.uid),
                ],
              ),
              const SizedBox(height: 10),
              LifeSpectrum(
                colors: stories.map(spectrumColorOf).toList(),
                height: 10,
                radius: 4,
                semanticLabel:
                    '${user.userName}님의 인생 스펙트럼, 기록 ${stories.length}개',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryResults extends StatelessWidget {
  const _StoryResults({required this.contents, required this.stats});

  final List<Content> contents;
  final StoryStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.s + 2;
        final tile = (constraints.maxWidth - 32 - gap) / 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: tile + 80,
          ),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final content = contents[index];
            return StoryResultTile(
              content: content,
              storyIndex: stats.indexOf(content),
              size: tile,
            );
          },
        );
      },
    );
  }
}

/// 이야기 결과 한 칸: 앨범 · 제목 · "작성자 · N번째"
class StoryResultTile extends StatelessWidget {
  const StoryResultTile({
    super.key,
    required this.content,
    required this.storyIndex,
    required this.size,
  });

  final Content content;
  final int storyIndex;
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
                  Text(content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '${content.authorName} · ${formatCount(storyIndex)}번째',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium?.copyWith(fontWeight: FontWeight.w400),
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

class _Message extends StatelessWidget {
  const _Message(
      {required this.icon, required this.title, required this.subtitle});

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
            Text(title,
                textAlign: TextAlign.center,
                style: context.textStyles.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
