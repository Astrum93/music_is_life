import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/messenger/presentation/create_chat_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 새 채팅방: 채팅방 이름 → 함께할 친구 고르기 → [만들기]
///
/// 개인 사진은 올리지 않는다. 채팅방 목록에서는 상대 멤버의 인생곡 앨범이 채팅방 사진이 된다.
class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  CreateChatController get _chat => Get.find<CreateChatController>();
  FriendsController get _friends => Get.find<FriendsController>();

  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    final result = await _chat.create();
    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.of(context).pop();
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: '닫기',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon:
                                Icon(Icons.close_rounded, color: c.textPrimary),
                          ),
                          Expanded(
                              child: Text('새 채팅방',
                                  style:
                                      t.titleMedium?.copyWith(fontSize: 16))),
                          Obx(() => FilledButton(
                                onPressed:
                                    _chat.isCreating.value ? null : _create,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(72, 40),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadius.borderS),
                                ),
                                child: _chat.isCreating.value
                                    ? SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: c.textTertiary),
                                      )
                                    : const Text('만들기'),
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l, vertical: 14),
                        decoration: BoxDecoration(
                            color: c.surface, borderRadius: AppRadius.borderL),
                        child: TextField(
                          maxLength: 30,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) => _chat.name.value = value,
                          style: t.headlineSmall,
                          decoration: InputDecoration(
                            hintText: '채팅방 이름',
                            hintStyle: t.headlineSmall
                                ?.copyWith(color: c.textTertiary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isCollapsed: true,
                            counterText: '',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                      child: Row(
                        children: [
                          Expanded(child: Text('함께할 친구', style: t.titleLarge)),
                          // 나는 항상 멤버라서 1명을 뺀 수가 고른 친구 수다.
                          Obx(() => Text(
                                '${formatCount(_chat.members.length - 1)}명 선택',
                                style: t.bodySmall?.copyWith(
                                    color: c.accentText,
                                    fontWeight: FontWeight.w700),
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        final friends = _friends.friendProfiles.toList();
                        if (friends.isEmpty) return const _NoFriends();
                        // 고른 친구 상태(members)가 바뀔 때도 다시 그리도록 여기서 읽는다.
                        final selected = _chat.members.keys.toSet();
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: friends.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.s),
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return FriendPickTile(
                              friend: friend,
                              selected: selected.contains(friend.uid),
                              onTap: () => _chat.toggleMember(
                                  friend.uid, friend.userName),
                            );
                          },
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: c.textTertiary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '채팅방 사진은 따로 없어요. 함께하는 친구의 인생곡 앨범이 보여요.',
                              style:
                                  t.bodySmall?.copyWith(color: c.textTertiary),
                            ),
                          ),
                        ],
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

/// 친구 한 줄: 인생곡 앨범 · 이름 · 인생곡 · 선택 표시
class FriendPickTile extends StatelessWidget {
  const FriendPickTile({
    super.key,
    required this.friend,
    required this.selected,
    required this.onTap,
  });

  final UserProfile friend;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final track = friend.track;
    return Semantics(
      button: true,
      selected: selected,
      label: '${friend.userName}${selected ? ', 선택됨' : ''}',
      child: Material(
        color: c.surface,
        borderRadius: AppRadius.borderL,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderL,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderL,
              border: Border.all(
                  color: selected ? c.accent : Colors.transparent, width: 1.5),
            ),
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
                      Text(friend.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleMedium),
                      Text(
                        track == null
                            ? '인생곡을 아직 정하지 않았어요'
                            : '♪ ${track.name} · ${track.artistsName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                ExcludeSemantics(
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? c.accent : c.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoFriends extends StatelessWidget {
  const _NoFriends();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add_outlined,
                size: 36, color: context.colors.textTertiary),
            const SizedBox(height: AppSpacing.s),
            Text('아직 친구가 없어요.', style: context.textStyles.titleMedium),
            const SizedBox(height: 2),
            Text('마이페이지의 [친구 추가]에서 친구를 찾아보세요.',
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
