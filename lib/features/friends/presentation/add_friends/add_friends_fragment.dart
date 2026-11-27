import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/presentation/widgets/mini_profile_sheet.dart';

/// 친구 찾기: [추천 | 이름으로 찾기]
///
/// 친구로 추가한 사람은 채팅방에 초대할 수 있다. (팔로우와는 다른 관계)
class AddFriendsFragment extends StatefulWidget {
  const AddFriendsFragment({super.key});

  @override
  State<AddFriendsFragment> createState() => _AddFriendsFragmentState();
}

class _AddFriendsFragmentState extends State<AddFriendsFragment> {
  final _query = TextEditingController();
  var _tab = 0;

  FriendsController get _friends => Get.find<FriendsController>();

  @override
  void initState() {
    super.initState();
    _friends.loadRecommendations();
    _query.addListener(() => _friends.search(_query.text));
  }

  @override
  void dispose() {
    _query.dispose();
    _friends.searchResults.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) {
            final c = context.colors;
            final t = context.textStyles;
            return Scaffold(
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ScreenTopBar(title: '친구 찾기'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: PillSegmentedControl(
                          labels: const ['추천', '이름으로 찾기'],
                          selectedIndex: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                      ),
                    ),
                    if (_tab == 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: TextField(
                          controller: _query,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: '찾고 싶은 사람의 이름',
                            prefixIcon: Icon(Icons.search_rounded,
                                color: c.textSecondary),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Text('친구로 추가하면 채팅방에 초대할 수 있어요.',
                          style: t.labelMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: c.textTertiary)),
                    ),
                    Expanded(
                      child: Obx(() {
                        final people = (_tab == 0
                                ? _friends.recommendations
                                : _friends.searchResults)
                            .toList();
                        if (people.isEmpty) {
                          return ListView(children: [_emptyNotice()]);
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                          itemCount: people.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.s),
                          itemBuilder: (context, index) =>
                              FriendCandidateCard(profile: people[index]),
                        );
                      }),
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

  Widget _emptyNotice() {
    if (_tab == 0) {
      return const EmptyNotice(
        icon: Icons.people_outline_rounded,
        title: '추천할 사람이 아직 없어요.',
        body: '이름으로 찾기에서 아는 사람을 찾아보세요.',
      );
    }
    final keyword = _query.text.trim();
    return keyword.isEmpty
        ? const EmptyNotice(
            icon: Icons.person_search_outlined,
            title: '이름으로 찾아보세요.',
            body: '이름의 일부만 적어도 찾을 수 있어요.',
          )
        : EmptyNotice(
            icon: Icons.search_off_rounded,
            title: '「$keyword」와 맞는 사람이 없어요.',
            body: '다른 이름으로 찾아보세요.',
          );
  }
}

/// 친구 후보 한 명: 인생곡 앨범 · 이름 · 칭호 · 기록 · 스펙트럼 · [친구 추가]
///
/// 누르면 미니 프로필이 열린다.
class FriendCandidateCard extends StatelessWidget {
  const FriendCandidateCard({super.key, required this.profile});

  final UserProfile profile;

  Future<void> _add(BuildContext context) async {
    final result = await Get.find<FriendsController>().addFriend(profile.uid);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        showDoneSnackBar(context, '${profile.userName}님을 친구로 추가했어요.');
      case Failed(failure: InvalidRequestFailure(code: 'self')):
        showErrorSnackBar(context, '나 자신은 친구로 추가할 수 없어요.');
      case Failed(failure: InvalidRequestFailure(code: 'already-friend')):
        showErrorSnackBar(context, '이미 친구예요.');
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final friends = Get.find<FriendsController>();
    final contents = Get.find<ContentsController>();
    return Material(
      color: c.surface,
      borderRadius: AppRadius.borderL,
      child: InkWell(
        onTap: () => showMiniProfile(context, profile),
        borderRadius: AppRadius.borderL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Obx(() {
            final stats = StoryStats(contents.allContents.toList());
            final stories = stats.storiesOf(profile.uid);
            final count = stories.length;
            final tier = stats.tierOf(profile.uid);
            final days = stats.dayCountOf(profile.uid, DateTime.now());
            final isFriend = friends.relations.value.isFriend(profile.uid);
            final track = profile.track;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(profile.userName,
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
                          Text(
                            count > 0
                                ? '${formatDayCount(days)} · 이야기 ${formatCount(count)}개'
                                : track != null
                                    ? '♪ ${track.name} · ${track.artistsName}'
                                    : '아직 남긴 이야기가 없어요',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    FilledButton(
                      onPressed: isFriend ? null : () => _add(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderS),
                        disabledBackgroundColor: c.background,
                        disabledForegroundColor: c.textSecondary,
                        textStyle: t.labelLarge?.copyWith(fontSize: 13),
                      ),
                      child: Text(isFriend ? '친구' : '친구 추가'),
                    ),
                  ],
                ),
                if (count > 0) ...[
                  const SizedBox(height: 10),
                  LifeSpectrum(
                    colors: [for (final s in stories) spectrumColorOf(s)],
                    height: 10,
                    radius: 4,
                    semanticLabel: '${profile.userName}님의 인생 스펙트럼',
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
