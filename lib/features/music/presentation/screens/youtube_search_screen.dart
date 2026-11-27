import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube에서 찾기: 곡 제목과 가수로 영상을 찾아 바로 재생한다. (검색은 네이버를 거친다)
class YoutubeSearchScreen extends StatefulWidget {
  const YoutubeSearchScreen({super.key});

  @override
  State<YoutubeSearchScreen> createState() => _YoutubeSearchScreenState();
}

class _YoutubeSearchScreenState extends State<YoutubeSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _singer = TextEditingController();
  final _singerFocus = FocusNode();

  var _searching = false;

  /// 재생 중인 곡 (찾기에 성공했을 때의 입력값)
  ({String title, String singer})? _playing;

  /// 검색에 성공하면 만들어지는 플레이어 컨트롤러
  YoutubePlayerController? _player;

  MusicController get _music => Get.find<MusicController>();

  /// 예전에는 검색 결과가 없거나 주소 형식이 다르면 영상 ID를 자르다가 앱이 멈췄다.
  Future<void> _search() async {
    if (_searching || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final title = _title.text.trim();
    final singer = _singer.text.trim();
    setState(() => _searching = true);
    final result = await _music.findYoutubeVideo(title: title, singer: singer);
    if (!mounted) return;
    setState(() => _searching = false);
    switch (result) {
      case Success(:final value):
        _player?.close();
        setState(() {
          _playing = (title: title, singer: singer);
          _player = YoutubePlayerController.fromVideoId(
              videoId: value, autoPlay: true);
        });
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  @override
  void dispose() {
    _player?.close();
    _title.dispose();
    _singer.dispose();
    _singerFocus.dispose();
    super.dispose();
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
                    const ScreenTopBar(title: 'YouTube에서 찾기'),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _title,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      _singerFocus.requestFocus(),
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? '곡 제목을 적어 주세요.'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: '곡 제목',
                                    prefixIcon: Icon(Icons.music_note_rounded,
                                        color: c.textSecondary),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s),
                                TextFormField(
                                  controller: _singer,
                                  focusNode: _singerFocus,
                                  textInputAction: TextInputAction.search,
                                  onFieldSubmitted: (_) => _search(),
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? '가수 이름을 적어 주세요.'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: '가수',
                                    prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: c.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              '곡 제목과 가수를 정확히 적으면 찾자마자 바로 재생돼요.',
                              style: t.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: c.textTertiary),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          FilledButton.icon(
                            onPressed: _searching ? null : _search,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              disabledBackgroundColor: c.textPrimary,
                              disabledForegroundColor: c.surface,
                            ),
                            icon: _searching
                                ? SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: c.surface),
                                  )
                                : const Icon(Icons.smart_display_outlined,
                                    size: 20),
                            label: Text(_searching ? '찾는 중' : '찾기'),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          _PlayerCard(player: _player, playing: _playing),
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

/// 검은 플레이어 카드: 찾기 전에는 안내, 찾으면 영상과 곡 이름
class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player, required this.playing});

  final YoutubePlayerController? player;
  final ({String title, String singer})? playing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final controller = player;
    return ClipRRect(
      borderRadius: AppRadius.borderXl,
      child: ColoredBox(
        color: c.inverseSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: controller == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_display_outlined,
                            size: 40, color: c.onInverseSurfaceMuted),
                        const SizedBox(height: AppSpacing.s),
                        Text('찾은 영상이 여기서 바로 재생돼요',
                            style: t.bodySmall
                                ?.copyWith(color: c.onInverseSurfaceMuted)),
                      ],
                    )
                  : YoutubePlayer(controller: controller),
            ),
            if (playing != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playing!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            t.titleLarge?.copyWith(color: c.onInverseSurface)),
                    Text('${playing!.singer} · YouTube',
                        style: t.bodySmall
                            ?.copyWith(color: c.onInverseSurfaceMuted)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
