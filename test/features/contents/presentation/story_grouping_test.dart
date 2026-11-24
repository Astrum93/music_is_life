import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';

Content _story(String id, DateTime at) => Content(
      id: id,
      authorUid: 'me',
      authorName: 'me',
      title: id,
      body: '',
      imageUrl: '',
      createdAt: at,
    );

void main() {
  test('기록한 날은 같은 날 여러 번 써도 하루로 센다', () {
    expect(
      recordedDayCount([
        _story('a', DateTime(2026, 11, 24, 8)),
        _story('b', DateTime(2026, 11, 24, 23)),
        _story('c', DateTime(2026, 11, 25)),
      ]),
      2,
    );
    expect(recordedDayCount([]), 0);
  });

  test('디스코그래피: 첫 해가 Vol.1, 최신 해가 앞, 빈 해가 있어도 번호는 해마다 센다', () {
    final volumes = discographyOf([
      _story('2026b', DateTime(2026, 5, 1)),
      _story('2024', DateTime(2024, 10, 8)),
      _story('2026a', DateTime(2026, 1, 1)),
    ]);
    expect(volumes.map((v) => (v.volume, v.year)), [(3, 2026), (1, 2024)]);
    expect(volumes.first.stories.map((s) => s.id), ['2026a', '2026b']);
    expect(discographyOf([]), isEmpty);
  });

  test('타임라인: 달마다 묶고 최신 달·최신 이야기가 앞에 온다', () {
    final groups = groupByMonth([
      _story('oct', DateTime(2026, 10, 30)),
      _story('nov1', DateTime(2026, 11, 1)),
      _story('nov24', DateTime(2026, 11, 24)),
      _story('lastYearNov', DateTime(2025, 11, 24)),
    ]);
    expect(groups.map((g) => (g.year, g.month)),
        [(2026, 11), (2026, 10), (2025, 11)]);
    expect(groups.first.stories.map((s) => s.id), ['nov24', 'nov1']);
  });
}
