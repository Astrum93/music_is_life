import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';

/// 웰컴: "당신의 인생곡은 무엇인가요?"
///
/// 로그인 전이라 실제 사용자 데이터가 없으므로, 기록이 오래 쌓이면 어떤 모습이 되는지
/// 예시 스펙트럼으로 보여준다. (특정 사용자처럼 보이지 않게 이름은 쓰지 않는다)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// 예시 카드의 기록 수와 날 수
  static const _exampleStories = 1042;
  static const _exampleDays = 1180;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Theme(
        data: AppTheme.light,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Builder(
            builder: (context) {
              final c = context.colors;
              final t = context.textStyles;
              return Scaffold(
                body: SafeArea(
                  child: LayoutBuilder(
                    // 세로가 짧은 화면에서는 스크롤되고, 긴 화면에서는 버튼이 맨 아래에 붙는다.
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 52),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text.rich(
                                TextSpan(children: [
                                  const TextSpan(text: 'music is life'),
                                  TextSpan(
                                      text: '.',
                                      style: TextStyle(color: c.accent)),
                                ]),
                                style: AppTypography.display(
                                    size: 26, color: c.textPrimary),
                              ),
                              const SizedBox(height: 22),
                              const _ExampleSpectrumCard(
                                stories: _exampleStories,
                                days: _exampleDays,
                              ),
                              const SizedBox(height: 26),
                              Text('당신의 인생곡은\n무엇인가요?',
                                  style: t.headlineMedium
                                      ?.copyWith(fontSize: 28, height: 1.32)),
                              const SizedBox(height: 10),
                              Text(
                                '당신의 인생곡을 다른 사람들과 나누고, 한 곡씩 쌓아 나만의 스펙트럼을 만들어보세요.',
                                style: t.bodyMedium
                                    ?.copyWith(color: c.textSecondary),
                              ),
                              const Spacer(),
                              const SizedBox(height: AppSpacing.xl),
                              FilledButton(
                                onPressed: () => Get.toNamed(Routes.join),
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(54)),
                                child: const Text('시작하기'),
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: () => Get.toNamed(Routes.login),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  backgroundColor: c.surface,
                                  foregroundColor: c.textPrimary,
                                ),
                                child: const Text('이미 계정이 있어요 · 로그인'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 검은 예시 카드: 연대기 작가 칭호 · "1,180일 동안 1,042곡을 기록하면" · 스펙트럼 · Vol.1~4
class _ExampleSpectrumCard extends StatelessWidget {
  const _ExampleSpectrumCard({required this.stories, required this.days});

  final int stories;
  final int days;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final muted = t.labelSmall
        ?.copyWith(color: c.onInverseSurfaceMuted, fontWeight: FontWeight.w400);
    final colors = List.generate(
        stories, (i) => spectrumColorForKey('welcome-example-$i'));

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
          color: c.inverseSurface, borderRadius: AppRadius.borderXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TierBadge(Tier.chronicler),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  '${formatCount(days)}일 동안 ${formatCount(stories)}곡을 기록하면',
                  style: t.bodySmall?.copyWith(color: c.onInverseSurfaceMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LifeSpectrum(
            colors: colors,
            height: 100,
            semanticLabel: '기록 ${formatCount(stories)}개로 그린 인생 스펙트럼 예시',
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DAY 1', style: muted),
              Text('DAY ${formatCount(days)}', style: muted),
            ],
          ),
          const SizedBox(height: 14),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var vol = 1; vol <= 4; vol++) ...[
                  _VolumeBlock(
                      volume: vol, color: colors[(vol * 211) % colors.length]),
                  if (vol < 4) const SizedBox(width: AppSpacing.s),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 디스코그래피 예시 블록 (앨범 이미지 대신 스펙트럼 색)
class _VolumeBlock extends StatelessWidget {
  const _VolumeBlock({required this.volume, required this.color});

  final int volume;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.borderS),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
            color: const Color(0xBF111111),
            borderRadius: BorderRadius.circular(4)),
        child: Text('Vol.$volume',
            style: AppTypography.display(size: 10, color: Colors.white)),
      ),
    );
  }
}
