import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/auth/presentation/widgets/logout_dialog.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/add_friends_fragment.dart';
import 'package:music_is_life/features/friends/presentation/favorites/favorites_fragment.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_screen.dart';
import 'package:music_is_life/features/music/presentation/screens/youtube_search_screen.dart';

/// 홈 메뉴: 내 인생곡 앨범 · 이름 · 칭호 · 스펙트럼 · 숫자 · 바로가기 · 로그아웃
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Drawer(
      width: 304,
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: const SafeArea(child: _DrawerBody()),
    );
  }
}

class _DrawerBody extends StatelessWidget {
  const _DrawerBody();

  /// 메뉴를 닫고 [screen]을 연다.
  void _open(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final contents = Get.find<ContentsController>();
    final friends = Get.find<FriendsController>();
    final c = context.colors;
    final t = context.textStyles;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final me = home.me.value;
            final mine = [...contents.myContents]
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            final tier = Tier.fromCount(mine.length);
            final days = StoryStats(mine).dayCountOf(home.uid, DateTime.now());
            final resonance = mine.fold<int>(0, (sum, s) => sum + s.likeCount);
            final followers = friends.relations.value.followers.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AlbumArt(
                      image: networkImageOrNull(me?.track?.imageUrl),
                      size: 56,
                      radius: AppRadius.m + 2,
                      semanticLabel: me?.track == null ? null : '나의 인생곡 앨범',
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(me?.userName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.titleLarge),
                              ),
                              if (tier != null) ...[
                                const SizedBox(width: 6),
                                TierBadge(tier),
                              ],
                            ],
                          ),
                          Text(
                            [
                              if (days > 0) formatDayCount(days),
                              if (me?.track != null) '♪ ${me!.track!.name}',
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (mine.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  LifeSpectrum(
                    colors: [for (final s in mine) spectrumColorOf(s)],
                    height: 14,
                    radius: 5,
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                  decoration: BoxDecoration(
                      color: c.surface, borderRadius: AppRadius.borderL),
                  child: Row(
                    children: [
                      _Stat(label: '이야기', value: mine.length),
                      _Stat(label: '받은 공감', value: resonance),
                      _Stat(label: '팔로워', value: followers),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 18),
          _MenuItem(
            icon: Icons.menu_book_rounded,
            label: '내 일기장',
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed(Routes.myPage);
            },
          ),
          _MenuItem(
            icon: Icons.person_add_alt_rounded,
            label: '친구 찾기',
            onTap: () => _open(context, const AddFriendsFragment()),
          ),
          _MenuItem(
            icon: Icons.people_outline_rounded,
            label: '친구 목록',
            onTap: () => _open(context, const FavoritesFragment()),
          ),
          _MenuItem(
            icon: Icons.library_music_outlined,
            label: '음악 컬렉션',
            onTap: () => _open(context, const MusicCollectionScreen()),
          ),
          _MenuItem(
            icon: Icons.smart_display_outlined,
            label: 'YouTube에서 찾기',
            onTap: () => _open(context, const YoutubeSearchScreen()),
          ),
          const Spacer(),
          _MenuItem(
            icon: Icons.logout_rounded,
            label: '로그아웃',
            color: c.danger,
            showChevron: false,
            onTap: () => confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400, color: c.textSecondary)),
          const SizedBox(height: 2),
          Text(formatCount(value),
              style: AppTypography.display(
                  size: 18, weight: FontWeight.w800, color: c.textPrimary)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = color ?? c.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderM,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(label,
                    style: context.textStyles.titleMedium?.copyWith(color: fg)),
              ),
              if (showChevron)
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
