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

/// Spotify 곡 검색 화면 틀: 곡 고르기(이야기)와 곡 담기(음악 컬렉션)가 함께 쓴다.
///
/// 검색창 · 안내 · 결과 목록을 그리고, 결과 한 줄 오른쪽 버튼은 [trailingOf]로 받는다.
class SpotifyTrackSearchPage extends StatefulWidget {
  const SpotifyTrackSearchPage({
    super.key,
    required this.title,
    required this.resultNote,
    required this.trailingOf,
    this.onTapTrack,
  });

  final String title;

  /// "검색 결과" 오른쪽 작은 안내 (예: 이야기 하나에 한 곡)
  final String resultNote;

  final Widget Function(Track track) trailingOf;

  /// 결과 한 줄을 눌렀을 때 (없으면 버튼만 눌린다)
  final void Function(Track track)? onTapTrack;

  @override
  State<SpotifyTrackSearchPage> createState() => _SpotifyTrackSearchPageState();
}

class _SpotifyTrackSearchPageState extends State<SpotifyTrackSearchPage> {
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
                    ScreenTopBar(title: widget.title, onBack: _back),
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
                              EmptyNotice(
                                icon: _searched
                                    ? Icons.search_off_rounded
                                    : Icons.album_outlined,
                                title: _searched ? '찾는 곡이 없어요.' : '곡을 찾아보세요.',
                                body: _searched
                                    ? '다른 이름이나 영어 제목으로 찾아보세요.'
                                    : '곡 이름이나 아티스트를 입력하고 검색하세요.',
                              )
                            else ...[
                              Row(
                                children: [
                                  Expanded(
                                      child:
                                          Text('검색 결과', style: t.titleMedium)),
                                  Text(widget.resultNote, style: t.labelMedium),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s),
                              for (final track in tracks)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.s),
                                  child: TrackResultTile(
                                    track: track,
                                    trailing: widget.trailingOf(track),
                                    onTap: widget.onTapTrack == null
                                        ? null
                                        : () => widget.onTapTrack!(track),
                                  ),
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

/// 곡 한 줄: 앨범 · 곡 · 아티스트 · 오른쪽 버튼
class TrackResultTile extends StatelessWidget {
  const TrackResultTile({
    super.key,
    required this.track,
    required this.trailing,
    this.onTap,
    this.onLongPress,
    this.badge,
  });

  final Track track;
  final Widget trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 곡 이름 옆 작은 표시 (예: 인생곡)
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Material(
      color: c.surface,
      borderRadius: AppRadius.borderL,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(track.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.titleMedium),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: c.accentMuted,
                                borderRadius: AppRadius.borderXs),
                            child: Text(badge!,
                                style: t.labelSmall
                                    ?.copyWith(color: c.accentText)),
                          ),
                        ],
                      ],
                    ),
                    Text(track.artistsName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// 작은 회색 알약 버튼 (고르기, 담기). [selected]면 보라색으로 바뀐다.
class SmallPillButton extends StatelessWidget {
  const SmallPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = FilledButton.styleFrom(
      backgroundColor: selected ? c.accentMuted : c.background,
      foregroundColor: selected ? c.accentText : c.textPrimary,
      disabledBackgroundColor: selected ? c.accentMuted : c.background,
      disabledForegroundColor: selected ? c.accentText : c.textTertiary,
      minimumSize: const Size(0, 36),
      padding: EdgeInsets.fromLTRB(icon == null ? 14 : 10, 0, 14, 0),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderS),
      textStyle: context.textStyles.labelLarge?.copyWith(fontSize: 13),
    );
    return icon == null
        ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 16),
            label: Text(label),
          );
  }
}
