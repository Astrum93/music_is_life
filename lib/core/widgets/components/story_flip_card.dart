import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 이야기 카드: SIDE A(이야기)를 누르면 뒤집혀 SIDE B(노래)가 나온다.
///
/// 앞면은 같은 앨범 아트를 흐리게 깔고 그 위에 글을 올린다. 사진 없이 글만 있어도
/// 곡의 색이 묻어나게 하기 위해서다. 뒷면은 선명한 앨범 아트가 카드를 채운다.
class StoryFlipCard extends StatefulWidget {
  const StoryFlipCard({
    super.key,
    required this.title,
    required this.body,
    required this.albumImage,
    required this.trackName,
    required this.artistName,
    this.onPlay,
    this.onFlipChanged,
    this.height = 306,
  });

  final String title;
  final String body;
  final ImageProvider albumImage;
  final String trackName;
  final String artistName;

  /// 뒷면 재생 버튼. null이면 버튼을 그리지 않는다.
  final VoidCallback? onPlay;

  /// 뒤집힐 때 호출된다. true면 뒷면(노래)이 보이는 중이다.
  final ValueChanged<bool>? onFlipChanged;

  final double height;

  @override
  State<StoryFlipCard> createState() => _StoryFlipCardState();
}

class _StoryFlipCardState extends State<StoryFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _turn =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  bool _showBack = false;

  void _flip() {
    setState(() => _showBack = !_showBack);
    _showBack ? _controller.forward() : _controller.reverse();
    widget.onFlipChanged?.call(_showBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _showBack
          ? '${widget.title}, A면 이야기 보기'
          : '${widget.title}, B면 노래 보기',
      child: GestureDetector(
        onTap: _flip,
        child: SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _turn,
            builder: (context, _) {
              final angle = _turn.value * math.pi;
              final isBack = angle > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angle),
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _Back(card: widget),
                      )
                    : _Front(card: widget),
              );
            },
          ),
        ),
      ),
    );
  }
}

const _cardBase = Color(0xFF222222);

class _Front extends StatelessWidget {
  const _Front({required this.card});

  final StoryFlipCard card;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return ClipRRect(
      borderRadius: AppRadius.borderL,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _cardBase),
          Transform.scale(
            scale: 1.3,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Image(
                image: card.albumImage,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          const ColoredBox(color: Color(0x5C000000)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SideLabel('SIDE A · 이야기'),
                const SizedBox(height: 14),
                Text(
                  card.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  card.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      '눌러서 B면 듣기',
                      style: t.labelLarge
                          ?.copyWith(fontSize: 13, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.autorenew_rounded,
                        size: 16, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.card});

  final StoryFlipCard card;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return ClipRRect(
      borderRadius: AppRadius.borderL,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _cardBase),
          Image(
            image: card.albumImage,
            fit: BoxFit.cover,
            semanticLabel: '${card.trackName} 앨범 커버',
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const Positioned(
              top: 14, left: 14, child: _SideLabel('SIDE B · 노래', dark: true)),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 62,
                  color: const Color(0x9E111111),
                  padding: const EdgeInsets.fromLTRB(14, 0, 9, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.trackName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              card.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (card.onPlay != null)
                        Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: card.onPlay,
                            child: Semantics(
                              button: true,
                              label: '${card.trackName} 재생',
                              child: const SizedBox.square(
                                dimension: 44,
                                child: Icon(Icons.play_arrow_rounded,
                                    color: Color(0xFF111111)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 왼쪽 위의 "SIDE A · 이야기" 표시
class _SideLabel extends StatelessWidget {
  const _SideLabel(this.text, {this.dark = false});

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    // Container에 alignment를 주면 부모 폭만큼 늘어나므로, 글자 폭에 맞추도록 widthFactor를 쓴다.
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0x73000000) : const Color(0x33FFFFFF),
        borderRadius: AppRadius.borderFull,
      ),
      child: Align(
        widthFactor: 1,
        child: Text(
          text,
          style: AppTypography.display(
              size: 12, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
