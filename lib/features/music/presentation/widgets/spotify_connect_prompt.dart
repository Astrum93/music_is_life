import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';

/// Spotify 계정이 연결되지 않았을 때 보여주는 안내와 연결 버튼
///
/// 곡 검색은 사용자의 Spotify 계정으로 받은 토큰(PKCE)으로 한다. 처음 한 번만 연결하면 된다.
/// 색은 토큰을 따르므로 라이트(곡 고르기)·다크(아직 옮기지 않은 화면) 어느 쪽에서도 보인다.
class SpotifyConnectPrompt extends StatelessWidget {
  const SpotifyConnectPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Get.find<MusicController>();
    final c = context.colors;
    final t = context.textStyles;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_music_outlined, size: 36, color: c.textTertiary),
          const SizedBox(height: AppSpacing.s),
          Text('Spotify를 연결해 주세요', style: t.titleMedium),
          const SizedBox(height: 2),
          Text(
            '곡 검색은 Spotify 계정으로 해요.\n처음 한 번만 연결하면 돼요.',
            textAlign: TextAlign.center,
            style: t.bodySmall,
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton.icon(
            onPressed: () async {
              final result = await music.connectSpotify();
              if (result case Failed(:final failure) when context.mounted) {
                showErrorSnackBar(context, failure.message);
              }
            },
            icon: const Icon(Icons.link_rounded, size: 20),
            label: const Text('Spotify 연결하기'),
          ),
        ],
      ),
    );
  }
}
