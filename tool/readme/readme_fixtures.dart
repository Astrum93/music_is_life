// README 이미지 생성기용 예시 데이터와 가짜 저장소.
//
// 실제 서버(Firebase)에 연결하지 않고, 앱 화면을 예시 데이터로 그리기 위해 쓴다.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 예시 앨범 커버 (tool/readme/covers/*.jpg). 주소는 가짜 HTTP 클라이언트가 파일로 돌려준다.
abstract final class Covers {
  static const dawn = 'https://readme.local/dawn_drive.jpg';
  static const forest = 'https://readme.local/forest_room.jpg';
  static const morning = 'https://readme.local/morning.jpg';
  static const neon = 'https://readme.local/neon_night.jpg';
  static const ocean = 'https://readme.local/ocean.jpg';
  static const plum = 'https://readme.local/plum.jpg';
  static const radio = 'https://readme.local/radio.jpg';
  static const rose = 'https://readme.local/rose.jpg';
  static const sage = 'https://readme.local/sage.jpg';
  static const terra = 'https://readme.local/terracotta.jpg';

  static const all = [
    dawn,
    ocean,
    radio,
    neon,
    plum,
    forest,
    terra,
    sage,
    morning,
    rose
  ];

  static String file(String url) =>
      'tool/readme/covers/${Uri.parse(url).pathSegments.last}';

  static MemoryImage image(String url) =>
      MemoryImage(File(file(url)).readAsBytesSync());
}

const me = 'jungmin';

ProfileTrack _track(String id, String name, String artist, String cover) =>
    ProfileTrack(id: id, name: name, artistsName: artist, imageUrl: cover);

final profiles = <String, UserProfile>{
  me: UserProfile(
    uid: me,
    userName: '정민',
    profileImageUrl: '',
    backgroundImageUrl: '',
    introduction: '새벽엔 조용한 노래, 낮에는 재즈. 같은 노래로 위로받은 사람 찾는 중',
    track: _track('t-me', '빈 방', '늦은 봄', Covers.forest),
  ),
  'night_neon': UserProfile(
      uid: 'night_neon',
      userName: 'night_neon',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: _track('t1', '밤의 거리', '시그널', Covers.neon)),
  'morae_al': UserProfile(
      uid: 'morae_al',
      userName: 'morae_al',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: _track('t2', '수평선', '바다 편지', Covers.sage)),
  'haneul.forest': UserProfile(
      uid: 'haneul.forest',
      userName: 'haneul.forest',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: _track('t3', '괜찮은 척', '보라색 오후', Covers.plum)),
  'slow.afternoon': UserProfile(
      uid: 'slow.afternoon',
      userName: 'slow.afternoon',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: _track('t4', '마지막 인사', '졸업 앨범', Covers.rose)),
  'yeoreum_jam': UserProfile(
      uid: 'yeoreum_jam',
      userName: 'yeoreum_jam',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: _track('t5', '맑음', '구름 한 점', Covers.terra)),
  'banjjak': UserProfile(
      uid: 'banjjak',
      userName: 'banjjak',
      profileImageUrl: '',
      backgroundImageUrl: '',
      track: _track('t6', '새 신발', '첫 출근', Covers.morning)),
};

const _songs = [
  ('도시의 불빛', '네온 라디오', Covers.dawn),
  ('파도 소리', '해변의 오후', Covers.ocean),
  ('오래된 주파수', '라디오 정원', Covers.radio),
  ('밤의 거리', '시그널', Covers.neon),
  ('괜찮은 척', '보라색 오후', Covers.plum),
  ('빈 방', '늦은 봄', Covers.forest),
  ('맑음', '구름 한 점', Covers.terra),
  ('수평선', '바다 편지', Covers.sage),
  ('새 신발', '첫 출근', Covers.morning),
  ('마지막 인사', '졸업 앨범', Covers.rose),
];

const _titles = [
  '퇴근길 버스 맨 뒷자리',
  '비가 그친 오후',
  '오래 연락 못 한 친구에게',
  '가을이 오는 소리',
  '네온사인 아래에서',
  '주말 아침 늦잠',
  '첫눈 오던 밤',
  '혼자 걷던 한강',
  '여름의 끝',
  '할머니 댁 가는 길',
];

DateTime _day(DateTime now, int daysAgo, {int hour = 21}) {
  final d = now.subtract(Duration(days: daysAgo));
  return DateTime(d.year, d.month, d.day, hour);
}

Content _story(String author, int n, DateTime at,
    {String? title, String? body, int song = -1, int likes = 0}) {
  final s =
      _songs[(song >= 0 ? song : (n * 7 + author.length)) % _songs.length];
  return Content(
    id: '$author-$n',
    authorUid: author,
    authorName: author == me ? '정민' : author,
    title: title ?? _titles[(n + author.length) % _titles.length],
    body: body ?? '그날 들었던 이 노래가 아직도 귀에 남아 있다. 다시 들어도 그때의 공기가 느껴진다.',
    imageUrl: '',
    createdAt: at,
    likedBy: List.generate(likes, (i) => 'u$i'),
    track: ContentTrack(name: s.$1, artistsName: s.$2, imageUrl: song >= 0 ? s.$3 : '${s.$3}?n=$author-$n'),
  );
}

/// 작성자의 이야기를 [count]개 만든다. 첫 이야기는 [firstDaysAgo]일 전, 마지막은 [lastDaysAgo]일 전.
List<Content> _diary(String author, DateTime now,
    {required int count, required int firstDaysAgo, int lastDaysAgo = 1}) {
  return [
    for (var i = 0; i < count; i++)
      _story(
        author,
        i + 1,
        _day(
            now,
            firstDaysAgo -
                ((firstDaysAgo - lastDaysAgo) * i / (count - 1)).round(),
            hour: 8 + i % 14),
      ),
  ];
}

/// 예시 이야기 전체 (최신순)
List<Content> buildStories(DateTime now) {
  final stories = <Content>[
    // 오래 기록한 사람들
    ..._diary('night_neon', now,
        count: 1041, firstDaysAgo: 1179, lastDaysAgo: 1),
    _story('night_neon', 1042, _day(now, 0, hour: 9),
        title: '잠이 오지 않던 새벽, 무작정 강변을 달렸다',
        body:
            '창문을 조금 내리고 이 노래를 틀었을 때 그제야 숨이 쉬어졌어. 요즘 잠 못 드는 사람들한테 꼭 들려주고 싶은 곡.',
        song: 0,
        likes: 1284),
    ..._diary('haneul.forest', now,
        count: 364, firstDaysAgo: 364, lastDaysAgo: 2),
    _story('haneul.forest', 365, _day(now, 1, hour: 23),
        title: '1년 동안 매일 한 곡씩', song: 4, likes: 214),
    ..._diary('slow.afternoon', now,
        count: 370, firstDaysAgo: 401, lastDaysAgo: 3),
    _story('slow.afternoon', 371, _day(now, 2),
        title: '할머니 집 마루의 낡은 라디오',
        body: '지지직거리던 소리 사이로 흘러나오던 이 노래를 할머니는 늘 따라 불렀다.',
        song: 2,
        likes: 611),
    ..._diary('morae_al', now, count: 141, firstDaysAgo: 529, lastDaysAgo: 4),
    _story('morae_al', 142, _day(now, 3),
        title: '스무 살, 처음 혼자 떠난 바다',
        body: '모래 묻은 이어폰에서 흘러나오던 노래. 지금 들어도 그날의 바람 냄새가 난다.',
        song: 1,
        likes: 942),
    ..._diary('yeoreum_jam', now,
        count: 210, firstDaysAgo: 387, lastDaysAgo: 5),
    ..._diary('banjjak', now, count: 46, firstDaysAgo: 60, lastDaysAgo: 6),
    _story('banjjak', 47, _day(now, 4),
        title: '헤어진 다음 날 아침',
        body: '아무렇지 않은 척 출근했는데 버스에서 이 노래가 나와서 결국 울었다.',
        song: 4,
        likes: 488),
    // 나: 412일 전 첫 페이지, 1년 전 오늘의 기록 포함
    ..._myDiary(now),
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return stories;
}

List<Content> _myDiary(DateTime now) {
  final days = <int>{411, 365, 0};
  for (var i = 0; days.length < 287; i++) {
    days.add((411 - i * 1.44).round().clamp(1, 411));
  }
  final ordered = days.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (var i = 0; i < ordered.length; i++)
      _story(
        me,
        i + 1,
        _day(now, ordered[i], hour: ordered[i] == 0 ? 8 : 22),
        title: switch (ordered[i]) {
          411 => '첫 출근 날 아침 지하철',
          365 => '할머니 집 낡은 라디오에서',
          0 => '오늘 아침 버스에서 들은 노래',
          _ => null,
        },
        song: switch (ordered[i]) { 411 => 8, 365 => 2, 0 => 5, _ => -1 },
      ),
  ];
}

class FakeContentsRepository implements ContentsRepository {
  FakeContentsRepository(this.stories);

  final List<Content> stories;

  @override
  Stream<List<Content>> watchAll() => Stream.value(stories);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) =>
      Stream.value(stories.where((c) => c.authorUid == authorUid).toList());

  @override
  Future<Result<void>> setLiked(
          {required String contentId,
          required String uid,
          required bool liked}) async =>
      const Success(null);

  @override
  Future<Result<Content>> create(
          {required String authorUid,
          required String authorName,
          required NewContent content}) =>
      throw UnimplementedError();
}

class FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(profiles[uid]);

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      Success([
        for (final uid in uids)
          if (profiles[uid] != null) profiles[uid]!
      ]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      Success(profiles.values.toList());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFriendsRepository implements FriendsRepository {
  @override
  Stream<FriendRelations> watchRelations(String uid) =>
      Stream.value(const FriendRelations(
        friends: [],
        followers: [
          'night_neon',
          'morae_al',
          'haneul.forest',
          'slow.afternoon',
          'banjjak'
        ],
        following: [
          'night_neon',
          'morae_al',
          'haneul.forest',
          'slow.afternoon',
          'yeoreum_jam'
        ],
      ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMessengerRepository implements MessengerRepository {
  @override
  Stream<List<ChatRoom>> watchRooms(String uid) => Stream.value(const [
        ChatRoom(id: 'r1', name: '새벽 감성 모임', memberUids: [
          me,
          'night_neon',
          'haneul.forest',
          'morae_al'
        ], memberNames: {
          me: '정민',
          'night_neon': 'night_neon',
          'haneul.forest': 'haneul.forest',
          'morae_al': 'morae_al'
        }),
        ChatRoom(
            id: 'r2',
            name: 'night_neon',
            memberUids: [me, 'night_neon'],
            memberNames: {me: '정민', 'night_neon': 'night_neon'},
            likedBy: [me]),
        ChatRoom(id: 'r3', name: '재즈 듣는 밤', memberUids: [
          me,
          'slow.afternoon',
          'yeoreum_jam'
        ], memberNames: {
          me: '정민',
          'slow.afternoon': 'slow.afternoon',
          'yeoreum_jam': 'yeoreum_jam'
        }),
        ChatRoom(
            id: 'r4',
            name: 'morae_al',
            memberUids: [me, 'morae_al'],
            memberNames: {me: '정민', 'morae_al': 'morae_al'}),
        ChatRoom(id: 'r5', name: '출근길 메이트', memberUids: [
          me,
          'banjjak',
          'yeoreum_jam'
        ], memberNames: {
          me: '정민',
          'banjjak': 'banjjak',
          'yeoreum_jam': 'yeoreum_jam'
        }),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// NetworkImage가 readme.local 주소를 요청하면 tool/readme/covers의 파일을 돌려준다.
class CoverHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _CoverRequest(File(Covers.file(url.toString())).readAsBytesSync());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CoverRequest implements HttpClientRequest {
  _CoverRequest(this.bytes);

  final Uint8List bytes;

  @override
  HttpHeaders get headers => _NoHeaders();

  @override
  Future<HttpClientResponse> close() async => _CoverResponse(bytes);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CoverResponse extends Stream<List<int>> implements HttpClientResponse {
  _CoverResponse(this.bytes);

  final Uint8List bytes;

  @override
  int get statusCode => 200;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream<List<int>>.value(bytes).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
