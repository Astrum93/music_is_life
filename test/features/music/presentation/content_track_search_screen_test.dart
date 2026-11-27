import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/content_track_search_screen.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

const _city =
    Track(id: 't1', name: '도시의 불빛', artistsName: '네온 라디오', imageUrl: '');
const _wave =
    Track(id: 't2', name: '파도 소리', artistsName: '해변의 오후', imageUrl: '');

class _FakeSpotify implements SpotifyAccountRepository, TrackSearchRepository {
  _FakeSpotify({this.connected = true});

  bool connected;
  Result<List<Track>> searchResult = const Success([_city, _wave]);
  String? lastQuery;

  @override
  Future<bool> isConnected() async => connected;

  @override
  Future<Result<void>> connect() async {
    connected = true;
    return const Success(null);
  }

  @override
  Future<Result<void>> disconnect() async => const Success(null);

  @override
  Future<Result<List<Track>>> search(String query) async {
    lastQuery = query;
    return searchResult;
  }
}

class _FakePlaylist implements PlaylistRepository {
  @override
  Stream<List<PlaylistEntry>> watch(String uid) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Unused
    implements PlaybackRepository, YoutubeRepository, ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(MusicController, _FakeSpotify)> _pump(WidgetTester tester,
    {bool connected = true}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final spotify = _FakeSpotify(connected: connected);
  final music = Get.put(MusicController(
    account: spotify,
    search: spotify,
    playlist: _FakePlaylist(),
    playback: _Unused(),
    youtube: _Unused(),
    profile: _Unused(),
    uid: 'me',
  ));
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ContentTrackSearchScreen())),
          child: const Text('OPEN'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('OPEN'));
  await tester.pumpAndSettle();
  return (music, spotify);
}

void main() {
  tearDown(Get.reset);

  testWidgets('Spotify가 연결되지 않았으면 연결 안내를 보여준다', (tester) async {
    await _pump(tester, connected: false);

    expect(find.text('Spotify를 연결해 주세요'), findsOneWidget);
    expect(find.text('Spotify 연결하기'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('검색하면 결과를 보여주고, 고르면 곡을 정하고 돌아간다', (tester) async {
    final (music, spotify) = await _pump(tester);

    expect(find.text('이 이야기에 어울리는 곡을 찾아보세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  city lights ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(spotify.lastQuery, 'city lights');
    expect(find.text('도시의 불빛'), findsOneWidget);
    expect(find.text('파도 소리'), findsOneWidget);

    await tester.tap(find.text('고르기').last);
    await tester.pumpAndSettle();

    expect(music.pickedTrack.value, _wave);
    expect(find.text('OPEN'), findsOneWidget);
    expect(music.searchResults, isEmpty);
  });

  testWidgets('결과가 없으면 다른 이름으로 찾아보라고 안내한다', (tester) async {
    final (_, spotify) = await _pump(tester);
    spotify.searchResult = const Success([]);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('찾는 곡이 없어요.'), findsOneWidget);
  });
}
