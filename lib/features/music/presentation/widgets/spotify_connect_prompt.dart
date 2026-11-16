import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';

/// Spotify 계정이 연결되지 않았을 때 보여주는 안내와 연결 버튼
///
/// 곡 검색은 사용자의 Spotify 계정으로 받은 토큰(PKCE)으로 한다. 처음 한 번만 연결하면 된다.
class SpotifyConnectPrompt extends StatelessWidget {
  const SpotifyConnectPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Get.find<MusicController>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '곡 검색은 Spotify 계정으로 로그인해야 사용할 수 있어요.\n처음 한 번만 연결하면 됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
            onPressed: () async {
              final result = await music.connectSpotify();
              if (result case Failed(:final failure) when context.mounted) {
                showErrorSnackBar(context, failure.message);
              }
            },
            icon: const Icon(Icons.music_note_rounded),
            label: const Text('Spotify 연결하기'),
          ),
        ],
      ),
    );
  }
}
