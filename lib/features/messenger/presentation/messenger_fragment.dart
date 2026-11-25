import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/messenger/presentation/screen/chat_bubble_screen.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_player_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 메신저: 친구들의 인생곡 · 채팅방 목록
///
/// 하단 탭으로도, 마이페이지의 [메시지] 바로가기(새 화면)로도 열린다.
class MessengerFragment extends StatelessWidget {
  const MessengerFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // 마이페이지에서 새 화면으로 열었을 때만 뒤로 가기 버튼이 필요하다.
    final canPop = Navigator.of(context).canPop();
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header(canPop: canPop)),
                  const SliverToBoxAdapter(child: _FriendsLifeSongs()),
                  const _RoomList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.canPop});

  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(canPop ? 4 : 16, 12, 12, 0),
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
              child: Text('메신저', style: context.textStyles.headlineMedium)),
          IconButton.filled(
            tooltip: '새 채팅방 만들기',
            onPressed: () => Get.toNamed(Routes.createChat),
            style: IconButton.styleFrom(
              backgroundColor: c.textPrimary,
              foregroundColor: c.surface,
              fixedSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

/// 팔로우한 사람들의 나의 인생곡: 누르면 그 곡을 재생한다.
class _FriendsLifeSongs extends StatelessWidget {
  const _FriendsLifeSongs();

  @override
  Widget build(BuildContext context) {
    final friends = Get.find<FriendsController>();
    return Obx(() {
      final withSong =
          friends.followingProfiles.where((p) => p.track != null).toList();
      if (withSong.isEmpty) return const SizedBox(height: AppSpacing.s);
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '친구들의 인생곡',
                style: context.textStyles.labelLarge?.copyWith(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: withSong.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) =>
                    FriendSongBubble(profile: withSong[index]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 친구 한 명: 인생곡 앨범을 그 곡 색의 고리로 두르고, 아래에 이름과 곡 이름
class FriendSongBubble extends StatelessWidget {
  const FriendSongBubble({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final track = profile.track!;
    final t = context.textStyles;
    final cover = networkImageOrNull(track.imageUrl);
    return Semantics(
      button: true,
      label: '${profile.userName}님의 인생곡 ${track.name} 듣기',
      child: InkWell(
        borderRadius: AppRadius.borderL,
        onTap: () => showTrackPlayerSheet(
          context,
          title: track.name,
          artist: track.artistsName,
          cover: cover,
        ),
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: spectrumColorForKey(track.imageUrl), width: 3),
                ),
                child: ClipOval(
                    child: AlbumArt(image: cover, size: 50, radius: 0)),
              ),
              const SizedBox(height: 6),
              Text(profile.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall?.copyWith(fontWeight: FontWeight.w500)),
              Text('♪ ${track.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  const _RoomList();

  @override
  Widget build(BuildContext context) {
    final messenger = Get.find<MessengerController>();
    return Obx(() {
      final rooms = messenger.rooms.toList();
      if (rooms.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyRooms(),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        sliver: DecoratedSliver(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(22),
          ),
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            sliver: SliverList.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.colors.background),
              itemBuilder: (context, index) => ChatRoomTile(room: rooms[index]),
            ),
          ),
        ),
      );
    });
  }
}

/// 채팅방 한 줄: 상대 멤버의 인생곡 앨범 · 방 이름 · 인원 · 멤버 · 즐겨찾기
class ChatRoomTile extends StatelessWidget {
  const ChatRoomTile({super.key, required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    final messenger = Get.find<MessengerController>();
    final c = context.colors;
    final t = context.textStyles;
    final others = room.memberUids.where((u) => u != messenger.uid).toList();
    final liked = room.isLikedBy(messenger.uid);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatBubbleScreen(room: room)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // 채팅방 사진 대신 상대 멤버의 인생곡 앨범을 보여준다. (개인 사진은 쓰지 않는다)
            StreamBuilder<UserProfile?>(
              stream:
                  others.isEmpty ? null : messenger.watchSender(others.first),
              builder: (context, snapshot) => AlbumArt(
                image: networkImageOrNull(snapshot.data?.track?.imageUrl),
                size: 50,
                radius: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          room.name.isEmpty ? '이름 없는 채팅방' : room.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('${room.memberUids.length}',
                          style:
                              t.labelMedium?.copyWith(color: c.textTertiary)),
                    ],
                  ),
                  Text(
                    room.memberDisplayNames.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: liked ? '즐겨찾기 해제' : '즐겨찾기',
              onPressed: () async {
                final result = await messenger.toggleLike(room);
                if (result case Failed(:final failure) when context.mounted) {
                  showErrorSnackBar(context, failure.message);
                }
              },
              icon: Icon(
                liked ? Icons.star_rounded : Icons.star_outline_rounded,
                color: liked ? c.gold : c.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRooms extends StatelessWidget {
  const _EmptyRooms();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined,
              size: 36, color: context.colors.textTertiary),
          const SizedBox(height: AppSpacing.s),
          Text('아직 채팅방이 없어요.', style: context.textStyles.titleMedium),
          const SizedBox(height: 2),
          Text('오른쪽 위 + 버튼으로 친구와 대화를 시작해 보세요.',
              textAlign: TextAlign.center, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}
