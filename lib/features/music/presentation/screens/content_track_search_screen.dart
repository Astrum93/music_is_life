import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/widgets/spotify_track_search.dart';

/// 곡 고르기: 이야기에 붙일 곡을 Spotify에서 찾아 고른다. (이야기 하나에 한 곡)
///
/// [고르기]를 누르면 곡을 정하고 바로 이야기 쓰기로 돌아간다.
class ContentTrackSearchScreen extends StatelessWidget {
  const ContentTrackSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void pick(Track track) {
      final music = Get.find<MusicController>();
      final result = music.pickForContent(track);
      if (result case Failed(:final failure)) {
        showErrorSnackBar(context, failure.message);
        return;
      }
      music.clearSearch();
      Navigator.of(context).pop();
    }

    return SpotifyTrackSearchPage(
      title: '곡 고르기',
      resultNote: '이야기 하나에 한 곡',
      onTapTrack: pick,
      trailingOf: (track) =>
          SmallPillButton(label: '고르기', onPressed: () => pick(track)),
    );
  }
}
