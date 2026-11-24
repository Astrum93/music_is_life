import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/widgets/components/tier_badge.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';

Content _story(
  String id, {
  required String author,
  required DateTime at,
  int likes = 0,
  bool withTrack = true,
}) =>
    Content(
      id: id,
      authorUid: author,
      authorName: author,
      title: '이야기 $id',
      body: '본문',
      imageUrl: '',
      createdAt: at,
      likedBy: List.generate(likes, (i) => 'u$i'),
      track: withTrack
          ? ContentTrack(
              name: '곡 $id', artistsName: '가수', imageUrl: 'https://img/$id')
          : null,
    );

void main() {
  group('StoryStats', () {
    final stories = [
      _story('b2', author: 'b', at: DateTime(2026, 3, 1)),
      _story('a1', author: 'a', at: DateTime(2025, 10, 8, 23, 50)),
      _story('a3', author: 'a', at: DateTime(2026, 11, 24)),
      _story('a2', author: 'a', at: DateTime(2026, 1, 2)),
      _story('b1', author: 'b', at: DateTime(2026, 2, 1)),
    ];
    final stats = StoryStats(stories);

    test('작성자별로 오래된 순서대로 몇 번째 이야기인지 센다', () {
      expect(stats.indexOf(stories[1]), 1); // a1
      expect(stats.indexOf(stories[3]), 2); // a2
      expect(stats.indexOf(stories[2]), 3); // a3
      expect(stats.indexOf(stories[4]), 1); // b1
      expect(stats.indexOf(stories[0]), 2); // b2
    });

    test('작성자별 기록 수와 칭호', () {
      expect(stats.countOf('a'), 3);
      expect(stats.countOf('nobody'), 0);
      expect(stats.tierOf('a'), isNull);
    });

    test('첫 이야기를 남긴 날이 DAY 1(D+1)이다', () {
      // 시각은 무시하고 날짜만 센다: 2025-10-08 → 2025-10-08 = D+1
      expect(stats.dayCountOf('a', DateTime(2025, 10, 8, 0, 5)), 1);
      expect(stats.dayCountOf('a', DateTime(2025, 10, 9)), 2);
      expect(stats.dayCountOf('nobody', DateTime(2026)), 0);
    });

    test('기록 30개면 수집가 칭호', () {
      final many = List.generate(
          30, (i) => _story('c$i', author: 'c', at: DateTime(2026, 1, 1 + i)));
      expect(StoryStats(many).tierOf('c'), Tier.collector);
    });
  });

  test('공감받는 이야기는 곡이 있는 이야기만, 공감 많은 순(같으면 최신순)으로 고른다', () {
    final hot = pickHotStories([
      _story('old', author: 'a', at: DateTime(2026, 1, 1), likes: 5),
      _story('new', author: 'a', at: DateTime(2026, 2, 1), likes: 5),
      _story('top', author: 'b', at: DateTime(2025, 1, 1), likes: 9),
      _story('noTrack',
          author: 'b', at: DateTime(2026, 3, 1), likes: 99, withTrack: false),
    ], limit: 2);
    expect(hot.map((c) => c.id), ['top', 'new']);
  });

  test('N년 전 오늘은 예전 해의 같은 날짜 중 가장 최근 이야기', () {
    final now = DateTime(2026, 11, 24, 9);
    final memory = pickMemory([
      _story('2024', author: 'me', at: DateTime(2024, 11, 24)),
      _story('2025', author: 'me', at: DateTime(2025, 11, 24, 22)),
      _story('today', author: 'me', at: DateTime(2026, 11, 24, 8)),
      _story('otherDay', author: 'me', at: DateTime(2025, 11, 23)),
    ], now);
    expect(memory?.id, '2025');
    expect(pickMemory([], now), isNull);
  });

  test('기념 순번: 칭호 기준이거나 100 단위', () {
    expect(isMilestoneIndex(30), isTrue);
    expect(isMilestoneIndex(365), isTrue);
    expect(isMilestoneIndex(200), isTrue);
    expect(isMilestoneIndex(1000), isTrue);
    expect(isMilestoneIndex(31), isFalse);
    expect(isMilestoneIndex(50), isFalse);
  });

  test('최근 7일 안의 기념 이야기만 고르고, 칭호를 알려준다', () {
    final now = DateTime(2026, 11, 24);
    final stories = List.generate(
      30,
      (i) =>
          _story('s$i', author: 'x', at: now.subtract(Duration(days: 29 - i))),
    );
    final stats = StoryStats(stories);
    final milestone = pickRecentMilestone(stories, stats, now);
    expect(milestone?.index, 30);
    expect(milestone?.reachedTier, Tier.collector);

    final later = now.add(const Duration(days: 8));
    expect(pickRecentMilestone(stories, stats, later), isNull);
  });

  test('같은 곡이면 스펙트럼 색이 늘 같다', () {
    final a = _story('1', author: 'a', at: DateTime(2026));
    final sameTrack = a.copyWith(id: '2');
    expect(spectrumColorOf(a), spectrumColorOf(sameTrack));
  });
}
