import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/content_track_search_screen.dart';

/// 해시태그 입력을 나눈다: 띄어쓰기·쉼표로 구분, # 제거, 중복 제거, 최대 3개
List<String> parseHashTags(String input) {
  final tags = <String>[];
  for (final raw in input.split(RegExp(r'[\s,]+'))) {
    final tag = raw.replaceAll('#', '').trim();
    if (tag.isEmpty || tags.contains(tag)) continue;
    tags.add(tag);
    if (tags.length == 3) break;
  }
  return tags;
}

/// 새 이야기 쓰기: 곡 고르기 → 제목 → 짧은 이야기 → 해시태그
///
/// 개인 사진은 올리지 않는다. 이야기의 이미지는 고른 곡의 앨범 아트뿐이다.
class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _tags = TextEditingController();

  ContentsController get _contents => Get.find<ContentsController>();
  MusicController get _music => Get.find<MusicController>();

  @override
  void initState() {
    super.initState();
    // 이전에 작성하다 만 이야기의 곡이 남아 있지 않도록 비운다.
    _music.clearPickedTrack();
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _pickTrack() {
    // 곡 선택은 게시물당 한 곡이라, 이미 골랐으면 비우고 다시 고르게 한다. ([바꾸기])
    _music.clearPickedTrack();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ContentTrackSearchScreen()),
    );
  }

  Future<void> _submit() async {
    final track = _music.pickedTrack.value;
    if (track == null) {
      showErrorSnackBar(context, '이 이야기에 어울리는 곡을 골라주세요.');
      return;
    }
    if (_title.text.trim().isEmpty) {
      showErrorSnackBar(context, '제목을 적어주세요.');
      return;
    }
    if (_body.text.trim().isEmpty) {
      showErrorSnackBar(context, '짧은 이야기를 적어주세요.');
      return;
    }
    FocusScope.of(context).unfocus();

    final result = await _contents.post(NewContent(
      title: _title.text,
      body: _body.text,
      hashTags: parseHashTags(_tags.text),
      track: ContentTrack(
        name: track.name,
        artistsName: track.artistsName,
        imageUrl: track.imageUrl,
      ),
    ));
    if (!mounted) return;
    if (result case Failed(:final failure)) {
      showErrorSnackBar(context, failure.message);
      return;
    }
    _music.clearPickedTrack();
    Navigator.of(context).pop();
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
                  children: [
                    _TopBar(
                        onClose: () => Navigator.of(context).maybePop(),
                        onSubmit: _submit),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        children: [
                          Obx(() => Text(
                                '${formatCount(_contents.myContents.length + 1)}번째 이야기',
                                style: AppTypography.display(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: c.accentText),
                              )),
                          const SizedBox(height: AppSpacing.s),
                          Obx(() => _TrackPicker(
                              track: _music.pickedTrack.value,
                              onPick: _pickTrack)),
                          const SizedBox(height: AppSpacing.l),
                          _Field(
                            child: TextField(
                              controller: _title,
                              maxLength: 40,
                              textInputAction: TextInputAction.next,
                              style: t.headlineSmall,
                              decoration: _plain(
                                  '제목',
                                  t.headlineSmall
                                      ?.copyWith(color: c.textTertiary)),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s + 2),
                          _Field(
                            child: TextField(
                              controller: _body,
                              minLines: 6,
                              maxLines: null,
                              maxLength: 500,
                              keyboardType: TextInputType.multiline,
                              style: t.bodyMedium,
                              decoration: _plain(
                                '이 노래와 함께한 순간을 짧게 적어보세요.',
                                t.bodyMedium?.copyWith(color: c.textTertiary),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s + 2),
                          _Field(
                            child: TextField(
                              controller: _tags,
                              textInputAction: TextInputAction.done,
                              style: t.bodyLarge,
                              decoration: _plain(
                                '#새벽 #위로  (띄어쓰기로 구분, 최대 3개)',
                                t.bodyLarge?.copyWith(color: c.textTertiary),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: c.textTertiary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '사진은 올리지 않아요. 고른 곡의 앨범이 이야기의 이미지가 돼요.',
                                  style: t.bodySmall
                                      ?.copyWith(color: c.textTertiary),
                                ),
                              ),
                            ],
                          ),
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

  InputDecoration _plain(String hint, TextStyle? hintStyle) => InputDecoration(
        hintText: hint,
        hintStyle: hintStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isCollapsed: true,
        counterText: '',
      );
}

/// 닫기 · "새 이야기" · [올리기]
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onSubmit});

  final VoidCallback onClose;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final posting = Get.find<ContentsController>().isPosting;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: '닫기',
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: c.textPrimary),
          ),
          Expanded(
              child: Text('새 이야기',
                  style:
                      context.textStyles.titleMedium?.copyWith(fontSize: 16))),
          Obx(() => FilledButton(
                onPressed: posting.value ? null : onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(72, 40),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderS),
                ),
                child: posting.value
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: c.textTertiary),
                      )
                    : const Text('올리기'),
              )),
        ],
      ),
    );
  }
}

/// 곡 고르기: 고르기 전에는 점선 안내, 고른 뒤에는 앨범과 곡 정보
class _TrackPicker extends StatelessWidget {
  const _TrackPicker({required this.track, required this.onPick});

  final Track? track;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final picked = track;
    if (picked == null) {
      return Material(
        color: c.surface,
        borderRadius: AppRadius.borderXl,
        child: InkWell(
          onTap: onPick,
          borderRadius: AppRadius.borderXl,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: c.surfaceMuted, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.album_outlined, size: 36, color: c.textPrimary),
                const SizedBox(height: AppSpacing.s),
                Text('이 이야기에 어울리는 곡을 골라주세요', style: t.titleMedium),
                const SizedBox(height: 2),
                Text('곡의 앨범이 이야기 카드의 B면이 돼요', style: t.bodySmall),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration:
          BoxDecoration(color: c.surface, borderRadius: AppRadius.borderXl),
      child: Row(
        children: [
          AlbumArt(
            image: networkImageOrNull(picked.imageUrl),
            size: 72,
            radius: AppRadius.m,
            semanticLabel: '${picked.name} 앨범 커버',
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SIDE B · 노래',
                    style: AppTypography.display(
                        size: 11,
                        weight: FontWeight.w700,
                        color: c.textTertiary)),
                Text(picked.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(fontSize: 16)),
                Text(picked.artistsName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall),
              ],
            ),
          ),
          TextButton(onPressed: onPick, child: const Text('바꾸기')),
        ],
      ),
    );
  }
}

/// 흰 입력 카드
class _Field extends StatelessWidget {
  const _Field({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 14),
      decoration: BoxDecoration(
          color: context.colors.surface, borderRadius: AppRadius.borderL),
      child: child,
    );
  }
}
