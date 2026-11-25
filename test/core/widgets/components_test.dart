import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/widgets/components/components.dart';

/// 1x1 투명 PNG: 네트워크 없이 이미지 위젯을 그리기 위한 테스트용 이미지
final _image = MemoryImage(Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]));

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: SizedBox(width: 360, child: child))),
    );

void main() {
  group('Tier', () {
    test('기록 수에 맞는 칭호를 고른다', () {
      expect(Tier.fromCount(0), isNull);
      expect(Tier.fromCount(29), isNull);
      expect(Tier.fromCount(30), Tier.collector);
      expect(Tier.fromCount(287), Tier.recorder);
      expect(Tier.fromCount(365), Tier.archivist);
      expect(Tier.fromCount(1042), Tier.chronicler);
    });

    test('다음 칭호를 알려준다', () {
      expect(Tier.nextAfter(10), Tier.collector);
      expect(Tier.nextAfter(287), Tier.archivist);
      expect(Tier.nextAfter(1000), isNull);
    });
  });

  group('숫자 표시', () {
    test('천 단위 쉼표와 D+일수', () {
      expect(formatCount(1284), '1,284');
      expect(formatDayCount(412), 'D+412');
    });

    test('반응 수는 1만부터 "만" 단위로 줄인다', () {
      expect(formatReactionCount(942), '942');
      expect(formatReactionCount(9999), '9,999');
      expect(formatReactionCount(10000), '1만');
      expect(formatReactionCount(12000), '1.2만');
      expect(formatReactionCount(153000), '15만');
    });
  });

  group('LifeSpectrumPainter', () {
    test('색 목록이 같으면 다시 그리지 않고, 바뀌면 다시 그린다', () {
      final a = LifeSpectrumPainter(
          colors: const [Colors.red, Colors.blue], emptyColor: Colors.grey);
      final same = LifeSpectrumPainter(
          colors: const [Colors.red, Colors.blue], emptyColor: Colors.grey);
      final more = LifeSpectrumPainter(
          colors: const [Colors.red, Colors.blue, Colors.green],
          emptyColor: Colors.grey);
      expect(same.shouldRepaint(a), isFalse);
      expect(more.shouldRepaint(a), isTrue);
    });

    testWidgets('기록 수를 화면 읽기용 설명으로 알려준다', (tester) async {
      await tester.pumpWidget(_wrap(
          const LifeSpectrum(colors: [Colors.red, Colors.blue, Colors.green])));
      expect(find.bySemanticsLabel('기록 3개로 그린 인생 스펙트럼'), findsOneWidget);
    });
  });

  testWidgets('TierBadge는 칭호 이름을 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(const TierBadge(Tier.archivist)));
    expect(find.text('아카이비스트'), findsOneWidget);
  });

  testWidgets('AuthorHeader는 이름·칭호·순번·D+를 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(AuthorHeader(
      name: 'night_neon',
      avatar: _image,
      storyIndex: 1042,
      dayCount: 1180,
      tier: Tier.chronicler,
    )));
    expect(find.text('night_neon'), findsOneWidget);
    expect(find.text('연대기 작가'), findsOneWidget);
    expect(find.textContaining('1,042번째 이야기'), findsOneWidget);
    expect(find.textContaining('D+1,180'), findsOneWidget);
  });

  testWidgets('StoryFlipCard는 누르면 SIDE B(노래)로 뒤집히고 다시 돌아온다', (tester) async {
    final flips = <bool>[];
    var played = 0;
    await tester.pumpWidget(_wrap(StoryFlipCard(
      title: '처음 혼자 떠난 바다',
      body: '모래 묻은 이어폰에서 흘러나오던 노래.',
      albumImage: _image,
      trackName: '파도 소리',
      artistName: '해변의 오후',
      onPlay: () => played++,
      onFlipChanged: flips.add,
    )));

    expect(find.text('SIDE A · 이야기'), findsOneWidget);
    expect(find.text('파도 소리'), findsNothing);
    // SIDE 표시는 카드 폭으로 늘어나지 않고 글자 폭에 맞춘 알약이다.
    final label = tester.getSize(find
        .ancestor(
            of: find.text('SIDE A · 이야기'), matching: find.byType(Container))
        .first);
    expect(label.width,
        lessThan(tester.getSize(find.byType(StoryFlipCard)).width / 1.2));

    await tester.tap(find.byType(StoryFlipCard));
    await tester.pumpAndSettle();
    expect(find.text('SIDE B · 노래'), findsOneWidget);
    expect(find.text('파도 소리'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    expect(played, 1);

    await tester.tap(find.text('SIDE B · 노래'));
    await tester.pumpAndSettle();
    expect(find.text('SIDE A · 이야기'), findsOneWidget);
    expect(flips, [true, false]);
  });

  testWidgets('ReactionBar는 공감·방명록·담기를 각각 알린다', (tester) async {
    final taps = <String>[];
    await tester.pumpWidget(_wrap(ReactionBar(
      resonanceCount: 1284,
      resonated: false,
      onResonance: () => taps.add('공감'),
      guestbookCount: 86,
      onGuestbook: () => taps.add('방명록'),
      saved: false,
      onSave: () => taps.add('담기'),
    )));

    expect(find.text('나도 이 노래로 버텼어 1,284'), findsOneWidget);
    await tester.tap(find.text('나도 이 노래로 버텼어 1,284'));
    await tester.tap(find.text('86'));
    await tester.tap(find.byTooltip('내 일기장에 담기'));
    expect(taps, ['공감', '방명록', '담기']);
  });

  testWidgets('ReactionBar는 좁은 폭에서도 넘치지 않고 담기 버튼이 보인다', (tester) async {
    var saved = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 260,
            child: ReactionBar(
              resonanceCount: 12840,
              resonated: true,
              onResonance: () {},
              guestbookCount: 1086,
              onGuestbook: () {},
              saved: false,
              onSave: () => saved++,
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('내 일기장에 담기'));
    expect(saved, 1);
  });

  testWidgets('TimelineEntryTile은 날짜·요일·순번을 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(TimelineEntryTile(
      date: DateTime(2026, 11, 24),
      storyIndex: 287,
      title: '오늘 아침 버스에서 들은 노래',
      trackLabel: '빈 방 · 늦은 봄',
      cover: _image,
      dotColor: Colors.green,
    )));
    expect(find.text('24'), findsOneWidget);
    expect(find.text('화'), findsOneWidget);
    expect(find.text('#287'), findsOneWidget);
    expect(find.text('♪ 빈 방 · 늦은 봄'), findsOneWidget);
  });

  testWidgets('DiscographyCover는 Vol.N과 기록 중 표시를 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(DiscographyCover(
        volume: 2, covers: [_image, _image], recording: true)));
    expect(find.text('Vol.2'), findsOneWidget);
    expect(find.text('기록 중'), findsOneWidget);

    await tester
        .pumpWidget(_wrap(DiscographyCover(volume: 1, covers: [_image])));
    expect(find.text('기록 중'), findsNothing);
  });

  testWidgets('PillSegmentedControl은 누른 칸의 번호를 알린다', (tester) async {
    int? picked;
    await tester.pumpWidget(_wrap(PillSegmentedControl(
      labels: const ['전체', '내 게시물'],
      selectedIndex: 0,
      onChanged: (i) => picked = i,
    )));
    await tester.tap(find.text('내 게시물'));
    expect(picked, 1);
  });

  testWidgets('AppTabBar는 탭 4개를 보여주고 누른 탭 번호를 알린다', (tester) async {
    int? picked;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          bottomNavigationBar:
              AppTabBar(currentIndex: 0, onTap: (i) => picked = i)),
    ));
    for (final label in ['홈', '검색', '라운지', '메신저']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    await tester.tap(find.text('라운지'));
    expect(picked, 2);
  });
}
