import 'package:flutter/painting.dart';
import 'package:music_is_life/core/widgets/components/tier_badge.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';

/// 게시물 목록에서 작성자별 기록(몇 번째 이야기, 기록 수, DAY 1)을 계산한다.
///
/// 사용자 데이터에 가입일이 없어서, 지금은 첫 이야기를 남긴 날을 DAY 1로 본다.
/// TODO(redesign): 프로필에 가입일(joinedAt)을 저장하면 그 날짜로 바꾼다.
class StoryStats {
  StoryStats(List<Content> contents) {
    for (final content in contents) {
      (_byAuthor[content.authorUid] ??= []).add(content);
    }
    for (final stories in _byAuthor.values) {
      stories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (var i = 0; i < stories.length; i++) {
        _indexById[stories[i].id] = i + 1;
      }
    }
  }

  final _byAuthor = <String, List<Content>>{};
  final _indexById = <String, int>{};

  /// 작성자의 몇 번째 이야기인지 (1부터)
  int indexOf(Content content) => _indexById[content.id] ?? 1;

  /// 작성자가 남긴 이야기 수
  int countOf(String authorUid) => _byAuthor[authorUid]?.length ?? 0;

  Tier? tierOf(String authorUid) => Tier.fromCount(countOf(authorUid));

  /// 작성자의 이야기 (오래된 순)
  List<Content> storiesOf(String authorUid) =>
      List.unmodifiable(_byAuthor[authorUid] ?? const <Content>[]);

  /// DAY 1부터 오늘까지의 날 수. DAY 1 당일이 D+1이다. 기록이 없으면 0.
  int dayCountOf(String authorUid, DateTime now) {
    final stories = _byAuthor[authorUid];
    if (stories == null || stories.isEmpty) return 0;
    return _dateOnly(now)
            .difference(_dateOnly(stories.first.createdAt))
            .inDays +
        1;
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 홈 "지금 공감받는 이야기": 곡이 붙은 이야기 중 공감이 많은 순 (같으면 최신순)
List<Content> pickHotStories(List<Content> contents, {int limit = 10}) {
  final withTrack = contents.where((c) => c.track != null).toList()
    ..sort((a, b) {
      final byResonance = b.likeCount.compareTo(a.likeCount);
      return byResonance != 0
          ? byResonance
          : b.createdAt.compareTo(a.createdAt);
    });
  return withTrack.take(limit).toList();
}

/// "N년 전 오늘": 예전 해의 오늘과 같은 날짜에 남긴 내 이야기 중 가장 최근 것
Content? pickMemory(List<Content> mine, DateTime now) {
  Content? best;
  for (final c in mine) {
    final d = c.createdAt;
    if (d.year < now.year && d.month == now.month && d.day == now.day) {
      if (best == null || d.isAfter(best.createdAt)) best = c;
    }
  }
  return best;
}

/// 기념할 만한 순번: 칭호 기준(30·100·365·1,000)이거나 100 단위
bool isMilestoneIndex(int index) =>
    Tier.values.any((t) => t.threshold == index) ||
    (index >= 100 && index % 100 == 0);

class Milestone {
  const Milestone({required this.content, required this.index});

  final Content content;

  /// 몇 번째 이야기인지
  final int index;

  /// 이 이야기로 새로 받은 칭호 (칭호 기준이 아닌 기념이면 null)
  Tier? get reachedTier {
    for (final tier in Tier.values) {
      if (tier.threshold == index) return tier;
    }
    return null;
  }
}

/// 최근 [within] 안에 나온 기념 이야기 중 가장 최근 것
Milestone? pickRecentMilestone(
  List<Content> contents,
  StoryStats stats,
  DateTime now, {
  Duration within = const Duration(days: 7),
}) {
  Milestone? best;
  for (final c in contents) {
    if (now.difference(c.createdAt) > within) continue;
    final index = stats.indexOf(c);
    if (!isMilestoneIndex(index)) continue;
    if (best == null || c.createdAt.isAfter(best.content.createdAt)) {
      best = Milestone(content: c, index: index);
    }
  }
  return best;
}

const _spectrumPalette = <Color>[
  Color(0xFFE76F51), Color(0xFF264653), Color(0xFF2A9D8F), Color(0xFFE9C46A), //
  Color(0xFFF4A261), Color(0xFF6D597A), Color(0xFF1D3557), Color(0xFFA8DADC),
  Color(0xFFC8553D), Color(0xFF84A59D), Color(0xFF355E3B), Color(0xFFB5838D),
  Color(0xFFFF5C8A), Color(0xFF3FD0E0), Color(0xFF9B7BFF), Color(0xFFF2CC8F),
];

/// 스펙트럼에 쓸 이야기의 색.
///
/// 앨범 대표색이 아직 저장돼 있지 않아서, 같은 곡이면 늘 같은 색이 나오도록
/// 곡 정보로 팔레트에서 고른다.
/// TODO(redesign): 게시물을 저장할 때 앨범 대표색을 함께 저장하고 그 값을 쓴다.
Color spectrumColorOf(Content content) {
  final key = content.track?.imageUrl ?? content.track?.name ?? content.id;
  final hash = key.codeUnits.fold<int>(0, (h, u) => (h * 31 + u) & 0x7fffffff);
  return _spectrumPalette[hash % _spectrumPalette.length];
}

/// 이야기를 남긴 서로 다른 날의 수 ("기록한 날 241일")
int recordedDayCount(List<Content> stories) =>
    stories.map((c) => _dateOnly(c.createdAt)).toSet().length;

/// 디스코그래피의 한 장: 한 해의 이야기를 묶은 "Vol.N"
class DiscographyVolume {
  const DiscographyVolume({
    required this.volume,
    required this.year,
    required this.stories,
  });

  /// 첫 이야기를 남긴 해가 Vol.1
  final int volume;
  final int year;

  /// 그해 이야기 (오래된 순)
  final List<Content> stories;
}

/// 내 이야기를 해마다 묶는다. 최신 해가 앞에 온다.
///
/// 이야기가 없는 해가 있어도 Vol 번호는 첫 해부터 해마다 하나씩 센다.
List<DiscographyVolume> discographyOf(List<Content> stories) {
  if (stories.isEmpty) return const [];
  final byYear = <int, List<Content>>{};
  for (final c in stories) {
    (byYear[c.createdAt.year] ??= []).add(c);
  }
  final firstYear = byYear.keys.reduce((a, b) => a < b ? a : b);
  final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final year in years)
      DiscographyVolume(
        volume: year - firstYear + 1,
        year: year,
        stories: byYear[year]!
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      ),
  ];
}

/// 타임라인의 한 달 묶음
class MonthGroup {
  const MonthGroup({
    required this.year,
    required this.month,
    required this.stories,
  });

  final int year;
  final int month;

  /// 그달 이야기 (최신순)
  final List<Content> stories;
}

/// 이야기를 달마다 묶는다. 최신 달이 앞에 오고, 달 안에서도 최신순이다.
List<MonthGroup> groupByMonth(List<Content> stories) {
  final sorted = [...stories]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final groups = <MonthGroup>[];
  for (final c in sorted) {
    final last = groups.isEmpty ? null : groups.last;
    if (last != null &&
        last.year == c.createdAt.year &&
        last.month == c.createdAt.month) {
      last.stories.add(c);
    } else {
      groups.add(MonthGroup(
        year: c.createdAt.year,
        month: c.createdAt.month,
        stories: [c],
      ));
    }
  }
  return groups;
}
