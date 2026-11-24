import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/widgets/follow_button.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_player_sheet.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 라운지 몰입형 카드 한 장: 흐린 앨범 배경 · 작성자 · 앨범과 LP · 이야기 · B면 듣기 · 반응
class LoungeStoryPage extends StatelessWidget {
  const LoungeStoryPage({
    super.key,
    required this.content,
    required this.stats,
    required this.now,
  });

  final Content content;
  final StoryStats stats;
  final DateTime now;

  ContentsController get _contents => Get.find<ContentsController>();

  Future<void> _toggleResonance(BuildContext context) async {
    final result = await _contents.toggleLike(content);
    if (result case Failed(:final failure) when context.mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    // 라운지 피드는 곡이 붙은 이야기만 넘겨준다.
    final track = content.track!;
    final cover = networkImageOrNull(track.imageUrl);
    final isMine = content.authorUid == _contents.uid;

    return ClipRRect(
      borderRadius: AppRadius.borderXxl,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF222222)),
          if (cover != null)
            Transform.scale(
              scale: 1.4,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 34, sigmaY: 34),
                child: Image(
                  image: cover,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          const ColoredBox(color: Color(0x4D000000)),
          const Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              widthFactor: 1,
              child: ColoredBox(color: Color(0x4D000000)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 작성자 줄·제목·본문·B면 듣기·반응 줄이 쓰는 높이를 빼고 남는 만큼
                // 앨범을 키운다. 세로가 짧은 화면에서도 카드가 넘치지 않게 하기 위해서다.
                const reserved = 300.0;
                final albumSize = (constraints.maxHeight - reserved)
                    .clamp(96.0, 236.0)
                    .floorToDouble();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<UserProfile?>(
                      stream: _contents.watchAuthor(content.authorUid),
                      builder: (context, snapshot) => AuthorHeader(
                        name: content.authorName,
                        avatar:
                            networkImageOrNull(snapshot.data?.track?.imageUrl),
                        storyIndex: stats.indexOf(content),
                        dayCount: stats.dayCountOf(content.authorUid, now),
                        tier: stats.tierOf(content.authorUid),
                        onImage: true,
                        trailing: isMine
                            ? null
                            : FollowButton(
                                uid: content.authorUid, onImage: true),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AlbumWithRecord(
                      cover: cover,
                      size: albumSize,
                      semanticLabel: '${track.name} 앨범 커버',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      content.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const Spacer(),
                    _ListenBar(
                      trackName: track.name,
                      artistName: track.artistsName,
                      onTap: () => showTrackPlayerSheet(
                        context,
                        title: track.name,
                        artist: track.artistsName,
                        cover: cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    ReactionBar(
                      resonanceCount: content.likeCount,
                      resonated: _contents.isLikedByMe(content),
                      onResonance: () => _toggleResonance(context),
                      onImage: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 앨범 재킷 뒤로 LP판이 반쯤 빠져나온 모양
class AlbumWithRecord extends StatelessWidget {
  const AlbumWithRecord({
    super.key,
    required this.cover,
    required this.size,
    this.semanticLabel,
  });

  final ImageProvider? cover;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final record = size * 0.93;
    return SizedBox(
      width: size * 0.47 + record,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.47,
            top: (size - record) / 2,
            child: Container(
              width: record,
              height: record,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // 반복되는 원형 그라디언트로 LP 홈을 그린다.
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF1C1C1C),
                    Color(0xFF1C1C1C),
                    Color(0xFF101010),
                    Color(0xFF101010),
                  ],
                  stops: [0, 0.5, 0.5, 1],
                  radius: 0.02,
                  tileMode: TileMode.repeated,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 30,
                      offset: Offset(0, 10)),
                ],
              ),
              child: ClipOval(
                child: AlbumArt(image: cover, size: record * 0.35, radius: 0),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x73000000),
                    blurRadius: 40,
                    offset: Offset(0, 18)),
              ],
            ),
            child: AlbumArt(
              image: cover,
              size: size,
              radius: 16,
              semanticLabel: semanticLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// "B면 듣기 · 곡 — 가수": 누르면 재생 시트가 열린다.
class _ListenBar extends StatelessWidget {
  const _ListenBar({
    required this.trackName,
    required this.artistName,
    required this.onTap,
  });

  final String trackName;
  final String artistName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderFull,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: const Color(0x29FFFFFF),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 46,
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 20, color: Color(0xFF111111)),
                  ),
                  const SizedBox(width: AppSpacing.s + 2),
                  Expanded(
                    child: Text(
                      'B면 듣기 · $trackName — $artistName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelLarge?.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
