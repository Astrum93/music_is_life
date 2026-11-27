import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/lounge/lounge_story_page.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/widgets/follow_button.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_player_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 이야기 상세: 작성자 · SIDE B(노래) · SIDE A(이야기 전문) · 공감
///
/// 목록에서 받은 [content]는 열 때의 값이라, 공감 수처럼 바뀌는 값은 컨트롤러의 최신 목록에서 다시 찾는다.
class ContentDetailScreen extends StatelessWidget {
  const ContentDetailScreen({super.key, required this.content});

  final Content content;

  ContentsController get _contents => Get.find<ContentsController>();

  Future<void> _toggleResonance(BuildContext context, Content current) async {
    final result = await _contents.toggleLike(current);
    if (result case Failed(:final failure) when context.mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Obx(() {
                final all = _contents.allContents.toList();
                final current =
                    all.firstWhereOrNull((c) => c.id == content.id) ?? content;
                final stats = StoryStats(all.isEmpty ? [current] : all);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    _Header(onBack: () => Navigator.of(context).maybePop()),
                    StreamBuilder<UserProfile?>(
                      stream: _contents.watchAuthor(current.authorUid),
                      builder: (context, snapshot) => AuthorHeader(
                        name: current.authorName,
                        avatar:
                            networkImageOrNull(snapshot.data?.track?.imageUrl),
                        storyIndex: stats.indexOf(current),
                        dayCount:
                            stats.dayCountOf(current.authorUid, DateTime.now()),
                        tier: stats.tierOf(current.authorUid),
                        trailing: current.authorUid == _contents.uid
                            ? null
                            : FollowButton(uid: current.authorUid),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _SongSide(content: current),
                    const SizedBox(height: AppSpacing.m),
                    _StorySide(content: current),
                    const SizedBox(height: AppSpacing.s),
                    ReactionBar(
                      resonanceCount: current.likeCount,
                      resonated: _contents.isLikedByMe(current),
                      onResonance: () => _toggleResonance(context, current),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: '뒤로 가기',
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: context.colors.textPrimary),
          ),
          Expanded(
            child: Text(
              '이야기',
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// SIDE B · 노래: 앨범과 LP, 곡 정보, [들어보기]
class _SongSide extends StatelessWidget {
  const _SongSide({required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final track = content.track;
    // 곡이 없는 예전 게시물만 예전 사진을 보여준다. 새 게시물은 사진 없이 곡 앨범만 쓴다.
    final cover = networkImageOrNull(track?.imageUrl ?? content.imageUrl);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
          color: c.inverseSurface, borderRadius: AppRadius.borderXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SideLabel('SIDE B · 노래', color: c.onInverseSurfaceMuted),
          const SizedBox(height: AppSpacing.m),
          LayoutBuilder(
            builder: (context, constraints) {
              // 앨범 + 오른쪽으로 빠져나온 LP가 카드 폭에 들어가도록 앨범 크기를 정한다.
              final album = (constraints.maxWidth / 1.4)
                  .clamp(120.0, 236.0)
                  .floorToDouble();
              return track == null
                  ? AlbumArt(image: cover, size: album, radius: 16)
                  : AlbumWithRecord(
                      cover: cover,
                      size: album,
                      semanticLabel: '${track.name} 앨범 커버');
            },
          ),
          if (track != null) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleLarge
                              ?.copyWith(color: c.onInverseSurface)),
                      Text(track.artistsName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall
                              ?.copyWith(color: c.onInverseSurfaceMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                FilledButton.icon(
                  onPressed: () => showTrackPlayerSheet(
                    context,
                    title: track.name,
                    artist: track.artistsName,
                    cover: cover,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.onInverseSurface,
                    foregroundColor: c.inverseSurface,
                    minimumSize: const Size(0, 44),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('들어보기'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// SIDE A · 이야기: 제목 · 본문 전체 · 해시태그 · 날짜
class _StorySide extends StatelessWidget {
  const _StorySide({required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final tags =
        content.hashTags.where((tag) => tag.trim().isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l + 2),
      decoration:
          BoxDecoration(color: c.surface, borderRadius: AppRadius.borderXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SideLabel('SIDE A · 이야기', color: c.textTertiary),
          const SizedBox(height: AppSpacing.m),
          Text(content.title, style: t.headlineSmall),
          if (content.body.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            SelectableText(content.body,
                style: t.bodyMedium?.copyWith(height: 1.75)),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in tags)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: c.background,
                        borderRadius: AppRadius.borderFull),
                    child: Text('#$tag',
                        style: t.labelMedium?.copyWith(color: c.accentText)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Text(
            DateFormat('yyyy년 M월 d일').format(content.createdAt),
            style: t.labelMedium?.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _SideLabel extends StatelessWidget {
  const _SideLabel(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTypography.display(
            size: 12, weight: FontWeight.w700, color: color));
  }
}
