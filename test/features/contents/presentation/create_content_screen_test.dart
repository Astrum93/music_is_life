import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/create_content_screen.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeContentsRepository implements ContentsRepository {
  final created = <NewContent>[];

  @override
  Stream<List<Content>> watchAll() => Stream.value(const []);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) =>
      Stream.value(const []);

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
      required NewContent content}) async {
    created.add(content);
    return Success(Content(
      id: 'new',
      authorUid: authorUid,
      authorName: authorName,
      title: content.title,
      body: content.body,
      imageUrl: '',
      createdAt: DateTime(2026, 11, 24),
      track: content.track,
    ));
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => const Stream.empty();

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      const Success([]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      const Success([]);

  @override
  Future<Result<void>> updateIntroduction(String uid, String introduction) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) =>
      throw UnimplementedError();
}

class _FakeSpotify implements SpotifyAccountRepository, TrackSearchRepository {
  @override
  Future<bool> isConnected() async => false;

  @override
  Future<Result<void>> connect() async => const Success(null);

  @override
  Future<Result<void>> disconnect() async => const Success(null);

  @override
  Future<Result<List<Track>>> search(String query) async => const Success([]);
}

class _FakePlaylist implements PlaylistRepository {
  @override
  Stream<List<PlaylistEntry>> watch(String uid) => const Stream.empty();

  @override
  Future<Result<void>> add(String uid, Track track) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String uid, String docId) async =>
      const Success(null);
}

class _FakePlayback implements PlaybackRepository {
  @override
  Future<Result<void>> play(String trackId) async => const Success(null);
}

class _FakeYoutube implements YoutubeRepository {
  @override
  Future<Result<String>> findVideoId(
          {required String title, required String singer}) async =>
      const Success('v');
}

const _track = Track(
    id: 't1',
    name: '도시의 불빛',
    artistsName: '네온 라디오',
    imageUrl: 'https://example.com/a.jpg');

Future<({_FakeContentsRepository contents, MusicController music})> _pump(
    WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final contents = _FakeContentsRepository();
  final profiles = _FakeProfileRepository();
  final spotify = _FakeSpotify();
  Get.put(ContentsController(contents, profiles, uid: 'me', userName: '나'));
  final music = Get.put(MusicController(
    account: spotify,
    search: spotify,
    playlist: _FakePlaylist(),
    playback: _FakePlayback(),
    youtube: _FakeYoutube(),
    profile: profiles,
    uid: 'me',
  ));

  // 작성 화면은 다른 화면 위에 열려서, 올리면 이전 화면으로 돌아간다.
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateContentScreen()),
          ),
          child: const Text('열기'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
  return (contents: contents, music: music);
}

void main() {
  tearDown(Get.reset);

  group('parseHashTags', () {
    test('띄어쓰기·쉼표로 나누고 #과 중복을 지우며 최대 3개', () {
      expect(parseHashTags('#새벽 #위로'), ['새벽', '위로']);
      expect(parseHashTags('새벽, 위로,  드라이브 여름'), ['새벽', '위로', '드라이브']);
      expect(parseHashTags('#새벽 새벽 ##'), ['새벽']);
      expect(parseHashTags('   '), isEmpty);
    });
  });

  testWidgets('곡을 고르기 전에는 안내를 보여주고, 올리기를 누르면 곡을 고르라고 알린다', (tester) async {
    final r = await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('1번째 이야기'), findsOneWidget);
    expect(find.text('이 이야기에 어울리는 곡을 골라주세요'), findsOneWidget);

    await tester.tap(find.text('올리기'));
    await tester.pump();
    expect(find.text('이 이야기에 어울리는 곡을 골라주세요.'), findsOneWidget);
    expect(r.contents.created, isEmpty);
  });

  testWidgets('곡·제목·이야기를 채우면 사진 없이 올리고 이전 화면으로 돌아간다', (tester) async {
    final r = await _pump(tester);
    r.music.pickForContent(_track);
    await tester.pump();
    expect(find.text('도시의 불빛'), findsOneWidget);
    expect(find.text('SIDE B · 노래'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '잠이 오지 않던 새벽');
    await tester.enterText(fields.at(1), '창문을 조금 내리고 이 노래를 틀었다.');
    await tester.enterText(fields.at(2), '#새벽 #위로');
    await tester.tap(find.text('올리기'));
    await tester.pumpAndSettle();

    expect(r.contents.created, hasLength(1));
    final posted = r.contents.created.single;
    expect(posted.title, '잠이 오지 않던 새벽');
    expect(posted.hashTags, ['새벽', '위로']);
    expect(
        posted.track,
        const ContentTrack(
            name: '도시의 불빛',
            artistsName: '네온 라디오',
            imageUrl: 'https://example.com/a.jpg'));
    expect(r.music.pickedTrack.value, isNull);
    expect(find.text('열기'), findsOneWidget);
  });
}
