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
import 'package:music_is_life/features/music/presentation/widgets/spotify_connect_prompt.dart';

/// 곡 고르기: 이야기에 붙일 곡을 Spotify에서 찾아 고른다. (이야기 하나에 한 곡)
///
/// [고르기]를 누르면 곡을 정하고 바로 이야기 쓰기로 돌아간다.
class ContentTrackSearchScreen extends StatefulWidget {
  const ContentTrackSearchScreen({super.key});

  @override
  State<ContentTrackSearchScreen> createState() =>
      _ContentTrackSearchScreenState();
}

class _ContentTrackSearchScreenState extends State<ContentTrackSearchScreen> {
  final _query = TextEditingController();

  /// 한 번이라도 검색했는지 (결과가 없을 때 안내 문구를 고르는 데 쓴다)
  var _searched = false;

  MusicController get _music => Get.find<MusicController>();

  @override
  void initState() {
    super.initState();
    _music
      ..clearSearch()
      ..refreshConnection();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    if (value.trim().isEmpty) return;
    setState(() => _searched = true);
    final result = await _music.searchTracks(value.trim());
    if (result case Failed(:final failure) when mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  void _pick(Track track) {
    final result = _music.pickForContent(track);
    if (result case Failed(:final failure)) {
      showErrorSnackBar(context, failure.message);
      return;
    }
    _music.clearSearch();
    Navigator.of(context).pop();
  }

  void _back() {
    _music.clearSearch();
    Navigator.of(context).maybePop();
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: '뒤로 가기',
                            onPressed: _back,
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 20, color: c.textPrimary),
                          ),
                          Text('곡 고르기',
                              style: t.titleMedium?.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (!_music.isSpotifyConnected.value) {
                          return const Center(child: SpotifyConnectPrompt());
                        }
                        final tracks = _music.searchResults.toList();
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: [
                            TextField(
                              controller: _query,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              onSubmitted: _search,
                              decoration: InputDecoration(
                                hintText: '곡 이름이나 아티스트',
                                prefixIcon: Icon(Icons.search_rounded,
                                    color: c.textSecondary),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                'Spotify에서 찾아요. 영어로 검색하면 더 정확해요.',
                                style: t.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: c.textTertiary),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.l),
                            if (_music.isSearching.value)
                              const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.xl),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (tracks.isEmpty)
                              _EmptyResult(searched: _searched)
                            else ...[
                              Row(
                                children: [
                                  Expanded(
                                      child:
                                          Text('검색 결과', style: t.titleMedium)),
                                  Text('이야기 하나에 한 곡', style: t.labelMedium),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s),
                              for (final track in tracks)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.s),
                                  child: TrackPickTile(
                                      track: track, onPick: () => _pick(track)),
                                ),
                            ],
                          ],
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
}

/// 검색 결과 한 줄: 앨범 · 곡 · 아티스트 · [고르기]
class TrackPickTile extends StatelessWidget {
  const TrackPickTile({super.key, required this.track, required this.onPick});

  final Track track;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Material(
      color: c.surface,
      borderRadius: AppRadius.borderL,
      child: InkWell(
        onTap: onPick,
        borderRadius: AppRadius.borderL,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AlbumArt(
                image: networkImageOrNull(track.imageUrl),
                size: 52,
                radius: AppRadius.m - 2,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium),
                    Text(track.artistsName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              FilledButton(
                onPressed: onPick,
                style: FilledButton.styleFrom(
                  backgroundColor: c.background,
                  foregroundColor: c.textPrimary,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderS),
                  textStyle: t.labelLarge?.copyWith(fontSize: 13),
                ),
                child: const Text('고르기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.searched});

  final bool searched;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(searched ? Icons.search_off_rounded : Icons.album_outlined,
              size: 36, color: context.colors.textTertiary),
          const SizedBox(height: AppSpacing.s),
          Text(searched ? '찾는 곡이 없어요.' : '이 이야기에 어울리는 곡을 찾아보세요.',
              style: t.titleMedium),
          const SizedBox(height: 2),
          Text(
            searched ? '다른 이름이나 영어 제목으로 찾아보세요.' : '곡 이름이나 아티스트를 입력하고 검색하세요.',
            textAlign: TextAlign.center,
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
