import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// 곡 제목·가수로 YouTube 영상을 찾아 바텀시트에서 재생한다.
Future<void> showTrackPlayerSheet(
  BuildContext context, {
  required String title,
  required String artist,
  ImageProvider? cover,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Theme(
      data: AppTheme.light,
      child: _TrackPlayerSheet(title: title, artist: artist, cover: cover),
    ),
  );
}

class _TrackPlayerSheet extends StatefulWidget {
  const _TrackPlayerSheet({
    required this.title,
    required this.artist,
    this.cover,
  });

  final String title;
  final String artist;
  final ImageProvider? cover;

  @override
  State<_TrackPlayerSheet> createState() => _TrackPlayerSheetState();
}

class _TrackPlayerSheetState extends State<_TrackPlayerSheet> {
  YoutubePlayerController? _player;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await Get.find<MusicController>()
        .findYoutubeVideo(title: widget.title, singer: widget.artist);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Success(:final value):
          _player = YoutubePlayerController.fromVideoId(
            videoId: value,
            autoPlay: true,
          );
        case Failed(:final failure):
          _error = failure.message;
      }
    });
  }

  @override
  void dispose() {
    _player?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.surfaceMuted,
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              AlbumArt(image: widget.cover, size: 52, radius: AppRadius.s),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium?.copyWith(fontSize: 16)),
                    Text(widget.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ClipRRect(
            borderRadius: AppRadius.borderL,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: c.inverseSurface,
                child: switch ((_player, _error)) {
                  (final player?, _) => YoutubePlayer(controller: player),
                  (_, final error?) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: t.bodySmall
                              ?.copyWith(color: c.onInverseSurfaceMuted),
                        ),
                      ),
                    ),
                  _ => Center(
                      child:
                          CircularProgressIndicator(color: c.onInverseSurface),
                    ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
