import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_search_screen.dart';
import 'package:music_is_life/features/music/presentation/widgets/spotify_track_search.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_player_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 음악 컬렉션: 나의 인생곡 카드 · 담아 둔 곡 (길게 눌러 인생곡으로, 왼쪽으로 밀어 지우기)
class MusicCollectionScreen extends StatefulWidget {
  const MusicCollectionScreen({super.key});

  @override
  State<MusicCollectionScreen> createState() => _MusicCollectionScreenState();
}

class _MusicCollectionScreenState extends State<MusicCollectionScreen> {
  MusicController get _music => Get.find<MusicController>();

  // 스트림을 build마다 새로 만들지 않도록 한 번만 만든다.
  late final Stream<UserProfile?> _me = _music.watchMyProfile();

  void _openSearch(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const PlaylistSearchScreen()));

  Future<void> _remove(PlaylistEntry entry) async {
    final result = await _music.removeFromPlaylist(entry);
    if (!mounted) return;
    switch (result) {
      case Success():
        showDoneSnackBar(context, '「${entry.track.name}」을 지웠어요.');
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  Future<void> _askLifeSong(BuildContext context, Track track) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Theme(
        data: AppTheme.light,
        child: _LifeSongDialog(track: track),
      ),
    );
    if (ok != true || !mounted) return;
    final result = await _music.setProfileTrack(track);
    if (!mounted) return;
    switch (result) {
      case Success():
        showDoneSnackBar(this.context, '인생곡을 「${track.name}」으로 바꿨어요.');
      case Failed(:final failure):
        showErrorSnackBar(this.context, failure.message);
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenTopBar(
                      title: '음악 컬렉션',
                      trailing: FilledButton.icon(
                        onPressed: () => _openSearch(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderS),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('곡 담기'),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<UserProfile?>(
                        stream: _me,
                        builder: (context, snapshot) {
                          final lifeSong = snapshot.data?.track;
                          return Obx(() {
                            final entries = _music.playlist.toList();
                            return ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              children: [
                                _LifeSongCard(track: lifeSong),
                                const SizedBox(height: 20),
                                Text.rich(
                                  TextSpan(children: [
                                    const TextSpan(text: '담아 둔 곡 '),
                                    TextSpan(
                                        text: formatCount(entries.length),
                                        style:
                                            TextStyle(color: c.textTertiary)),
                                  ]),
                                  style: t.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        size: 14, color: c.textTertiary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '길게 누르면 인생곡으로 정해요 · 왼쪽으로 밀면 지워요',
                                        style: t.labelMedium?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: c.textTertiary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (entries.isEmpty)
                                  EmptyNotice(
                                    icon: Icons.library_music_outlined,
                                    title: '담아 둔 곡이 없어요.',
                                    body:
                                        '마음에 드는 곡을 담아 두면\n여기서 인생곡으로 정할 수 있어요.',
                                    action: FilledButton(
                                      onPressed: () => _openSearch(context),
                                      child: const Text('곡 담으러 가기'),
                                    ),
                                  )
                                else
                                  for (final entry in entries)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.s),
                                      child: _CollectionRow(
                                        entry: entry,
                                        isLifeSong:
                                            entry.track.id == lifeSong?.id,
                                        onRemove: () => _remove(entry),
                                        onLongPress: () =>
                                            _askLifeSong(context, entry.track),
                                      ),
                                    ),
                              ],
                            );
                          });
                        },
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

/// 검은 "나의 인생곡" 카드
class _LifeSongCard extends StatelessWidget {
  const _LifeSongCard({required this.track});

  final ProfileTrack? track;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final song = track;
    final cover = networkImageOrNull(song?.imageUrl);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: c.inverseSurface, borderRadius: AppRadius.borderXl),
      child: Row(
        children: [
          AlbumArt(image: cover, size: 76, radius: AppRadius.l - 2),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LIFE SONG · 나의 인생곡',
                    style: AppTypography.display(
                        size: 12, weight: FontWeight.w700, color: c.gold)),
                const SizedBox(height: 2),
                Text(song?.name ?? '아직 정하지 않았어요',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleLarge?.copyWith(color: c.onInverseSurface)),
                Text(song?.artistsName ?? '아래 곡을 길게 눌러 정해 보세요',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        t.bodySmall?.copyWith(color: c.onInverseSurfaceMuted)),
              ],
            ),
          ),
          if (song != null)
            IconButton.filled(
              tooltip: '인생곡 듣기',
              onPressed: () => showTrackPlayerSheet(context,
                  title: song.name, artist: song.artistsName, cover: cover),
              style: IconButton.styleFrom(
                backgroundColor: c.onInverseSurface,
                foregroundColor: c.inverseSurface,
                fixedSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
            ),
        ],
      ),
    );
  }
}

/// 담아 둔 곡 한 줄: 왼쪽으로 밀면 빨간 [지우기]가 드러난다.
class _CollectionRow extends StatelessWidget {
  const _CollectionRow({
    required this.entry,
    required this.isLifeSong,
    required this.onRemove,
    required this.onLongPress,
  });

  final PlaylistEntry entry;
  final bool isLifeSong;
  final VoidCallback onRemove;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final track = entry.track;
    return Dismissible(
      // 예전에는 순서(index)를 키로 써서, 삭제하면 다른 곡과 키가 겹쳤다.
      key: ValueKey(entry.docId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration:
            BoxDecoration(color: c.danger, borderRadius: AppRadius.borderL),
        child: Text('지우기',
            style:
                context.textStyles.labelLarge?.copyWith(color: Colors.white)),
      ),
      child: TrackResultTile(
        track: track,
        badge: isLifeSong ? '인생곡' : null,
        onLongPress: onLongPress,
        trailing: IconButton.filled(
          tooltip: '${track.name} 듣기',
          onPressed: () => showTrackPlayerSheet(context,
              title: track.name,
              artist: track.artistsName,
              cover: networkImageOrNull(track.imageUrl)),
          style: IconButton.styleFrom(
            backgroundColor: c.background,
            foregroundColor: c.textPrimary,
            fixedSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
        ),
      ),
    );
  }
}

/// "이 곡을 인생곡으로 정할까요?"
class _LifeSongDialog extends StatelessWidget {
  const _LifeSongDialog({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Dialog(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXxl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AlbumArt(
              image: networkImageOrNull(track.imageUrl),
              size: 96,
              radius: AppRadius.l,
              semanticLabel: '${track.name} 앨범 커버',
            ),
            const SizedBox(height: 14),
            Text('인생곡으로 정할까요?', style: t.headlineSmall?.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.s),
            Text(
              '「${track.name}」 · ${track.artistsName}\n프로필과 미니 프로필에 이 곡의 앨범이 보여요.',
              textAlign: TextAlign.center,
              style:
                  t.bodyMedium?.copyWith(fontSize: 14, color: c.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: c.background,
                      foregroundColor: c.textPrimary,
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    child: const Text('정하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
