import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/friends/presentation/widgets/follow_button.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/presentation/widgets/mini_profile_sheet.dart';

/// 친구 목록: [팔로잉 N | 팔로워 N]
///
/// 예전에는 팔로워·팔로잉 화면이 거의 같은 코드로 따로 있었고,
/// 항목마다 UserInfo 문서를 하나씩 따로 읽었다.
class FavoritesFragment extends StatefulWidget {
  const FavoritesFragment({super.key});

  @override
  State<FavoritesFragment> createState() => _FavoritesFragmentState();
}

class _FavoritesFragmentState extends State<FavoritesFragment> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final friends = Get.find<FriendsController>();
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) {
            final c = context.colors;
            return Scaffold(
              body: SafeArea(
                child: Obx(() {
                  final relations = friends.relations.value;
                  final people = (_tab == 0
                          ? friends.followingProfiles
                          : friends.followerProfiles)
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ScreenTopBar(title: '친구 목록'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: PillSegmentedControl(
                            labels: [
                              '팔로잉 ${formatCount(relations.following.length)}',
                              '팔로워 ${formatCount(relations.followers.length)}',
                            ],
                            selectedIndex: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                        ),
                      ),
                      Expanded(
                        child: people.isEmpty
                            ? ListView(children: [
                                EmptyNotice(
                                  icon: Icons.people_outline_rounded,
                                  title: _tab == 0
                                      ? '아직 팔로우한 사람이 없어요.'
                                      : '아직 나를 팔로우한 사람이 없어요.',
                                  body: _tab == 0
                                      ? '검색이나 친구 찾기에서 마음에 드는 사람을 팔로우해 보세요.'
                                      : '이야기를 남기면 같은 노래를 좋아하는 사람이 찾아와요.',
                                ),
                              ])
                            : ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 32),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: c.surface,
                                        borderRadius:
                                            BorderRadius.circular(22)),
                                    child: Column(
                                      children: [
                                        for (var i = 0;
                                            i < people.length;
                                            i++) ...[
                                          if (i > 0)
                                            Divider(
                                                height: 1, color: c.background),
                                          FollowRow(
                                              profile: people[i],
                                              isMe:
                                                  people[i].uid == friends.uid),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 팔로잉·팔로워 한 줄: 인생곡 앨범 · 이름 · 인생곡 · [팔로우]
///
/// 누르면 미니 프로필이 열린다.
class FollowRow extends StatelessWidget {
  const FollowRow({super.key, required this.profile, this.isMe = false});

  final UserProfile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final track = profile.track;
    return InkWell(
      onTap: () => showMiniProfile(context, profile),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AlbumArt(
                image: networkImageOrNull(track?.imageUrl),
                size: 48,
                radius: 13),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium),
                  Text(
                    track == null
                        ? '인생곡을 아직 정하지 않았어요'
                        : '♪ ${track.name} · ${track.artistsName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium?.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            if (!isMe) ...[
              const SizedBox(width: AppSpacing.s),
              FollowButton(uid: profile.uid),
            ],
          ],
        ),
      ),
    );
  }
}
