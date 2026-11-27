import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';

/// 작성자 팔로우 버튼 (홈 이야기 카드, 라운지 몰입형 카드)
class FollowButton extends StatelessWidget {
  const FollowButton({super.key, required this.uid, this.onImage = false});

  final String uid;

  /// 앨범 이미지 위에 올릴 때 true: 흰 테두리 버튼으로 그린다.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final friends = Get.find<FriendsController>();
    final c = context.colors;
    return Obx(() {
      final following = friends.isFollowing(uid);
      final (Color background, Color foreground, BorderSide side) =
          switch ((onImage, following)) {
        (true, false) => (
            Colors.transparent,
            Colors.white,
            const BorderSide(color: Color(0x80FFFFFF)),
          ),
        (true, true) => (
            const Color(0x33FFFFFF),
            Colors.white,
            BorderSide.none,
          ),
        (false, false) => (c.background, c.textPrimary, BorderSide.none),
        (false, true) => (
            Colors.transparent,
            c.textSecondary,
            BorderSide(color: c.border),
          ),
      };
      return TextButton(
        onPressed: () async {
          final result = await friends.toggleFollow(uid);
          if (result case Failed(:final failure) when context.mounted) {
            showErrorSnackBar(context, failure.message);
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderS,
            side: side,
          ),
          textStyle: context.textStyles.labelLarge?.copyWith(fontSize: 13),
        ),
        child: Text(following ? '팔로잉' : '팔로우'),
      );
    });
  }
}
