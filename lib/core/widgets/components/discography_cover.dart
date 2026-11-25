import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/album_art.dart';

/// 디스코그래피: 한 해의 기록을 묶은 "Vol.N" 커버 (그해 앨범 4장을 모자이크)
class DiscographyCover extends StatelessWidget {
  const DiscographyCover({
    super.key,
    required this.volume,
    required this.covers,
    this.recording = false,
    this.size = 150,
  });

  /// 몇 번째 해인지 (가입한 해가 Vol.1)
  final int volume;

  /// 모자이크에 쓸 앨범 (앞의 4장만 쓴다. 모자라면 회색 칸)
  final List<ImageProvider?> covers;

  /// 올해처럼 아직 기록이 쌓이는 중인지
  final bool recording;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tile = size / 2;
    final four = List<ImageProvider?>.generate(
        4, (i) => i < covers.length ? covers[i] : null);
    return Semantics(
      label: 'Vol.$volume${recording ? ', 기록 중' : ''}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: const [
            BoxShadow(
                color: Color(0x2E111111), blurRadius: 22, offset: Offset(0, 10))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.m),
          child: Stack(
            children: [
              Wrap(
                children: [
                  for (final cover in four)
                    AlbumArt(image: cover, size: tile, radius: 0)
                ],
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: const BoxDecoration(
                      color: Color(0xB8111111),
                      borderRadius: AppRadius.borderXs),
                  child: Text('Vol.$volume',
                      style:
                          AppTypography.display(size: 13, color: Colors.white)),
                ),
              ),
              if (recording)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: c.live, borderRadius: AppRadius.borderXs),
                    child: Text(
                      '기록 중',
                      style: context.textStyles.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
