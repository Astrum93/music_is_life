import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/widgets/spotify_track_search.dart';

/// 곡 담기: 음악 컬렉션에 담을 곡을 Spotify에서 찾는다.
///
/// 이미 담은 곡은 [담음]으로 보이고 다시 담지 않는다.
class PlaylistSearchScreen extends StatelessWidget {
  const PlaylistSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Get.find<MusicController>();

    Future<void> add(Track track) async {
      final result = await music.addToPlaylist(track);
      if (!context.mounted) return;
      switch (result) {
        case Success():
          showDoneSnackBar(context, '「${track.name}」을 담았어요.');
        case Failed(:final failure):
          showErrorSnackBar(context, failure.message);
      }
    }

    return SpotifyTrackSearchPage(
      title: '곡 담기',
      resultNote: '음악 컬렉션에 담아요',
      trailingOf: (track) => Obx(() {
        final added = music.playlist.any((e) => e.track.id == track.id);
        return SmallPillButton(
          label: added ? '담음' : '담기',
          icon: added ? Icons.check_rounded : Icons.add_rounded,
          selected: added,
          onPressed: added ? null : () => add(track),
        );
      }),
    );
  }
}
