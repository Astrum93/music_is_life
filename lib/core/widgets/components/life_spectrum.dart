import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 인생 스펙트럼: 이야기 하나가 앨범 대표색의 세로줄 하나가 된다.
///
/// [colors]는 가입일부터 오늘까지 시간순으로 넘긴다. 줄은 항상 띠 전체 폭을
/// 나눠 쓰기 때문에, 기록이 많을수록 촘촘해지고 적을수록 굵은 블록이 된다.
class LifeSpectrum extends StatelessWidget {
  const LifeSpectrum({
    super.key,
    required this.colors,
    this.height = 112,
    this.radius = AppRadius.m,
    this.semanticLabel,
  });

  final List<Color> colors;
  final double height;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel ?? '기록 ${colors.length}개로 그린 인생 스펙트럼',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: LifeSpectrumPainter(
              colors: colors,
              emptyColor: context.colors.surfaceMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class LifeSpectrumPainter extends CustomPainter {
  LifeSpectrumPainter({required this.colors, required this.emptyColor});

  final List<Color> colors;

  /// 기록이 하나도 없을 때 칠하는 색
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;
    if (colors.isEmpty) {
      canvas.drawRect(Offset.zero & size, paint..color = emptyColor);
      return;
    }
    final stripe = size.width / colors.length;
    for (var i = 0; i < colors.length; i++) {
      // 줄 사이에 머리카락 같은 틈이 보이지 않게 살짝 겹쳐 그린다.
      final width = i == colors.length - 1 ? stripe : stripe + 0.5;
      canvas.drawRect(
        Rect.fromLTWH(i * stripe, 0, width, size.height),
        paint..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(LifeSpectrumPainter oldDelegate) =>
      oldDelegate.emptyColor != emptyColor ||
      !listEquals(oldDelegate.colors, colors);
}
