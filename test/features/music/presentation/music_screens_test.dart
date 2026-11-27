import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_screen.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_search_screen.dart';
import 'package:music_is_life/features/music/presentation/screens/youtube_search_screen.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

const _city =
    Track(id: 't1', name: '도시의 불빛', artistsName: '네온 라디오', imageUrl: '');
const _wave =
    Track(id: 't2', name: '파도 소리', artistsName: '해변의 오후', imageUrl: '');

class _FakeSpotify implements SpotifyAccountRepository, TrackSearchRepository {
  @override
  Future<bool> isConnected() async => true;

  @override
  Future<Result<List<Track>>> search(String query) async =>
      const Success([_city, _wave]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaylist implements PlaylistRepository {
  _FakePlaylist(List<Track> tracks)
      : _entries = [
          for (final t in tracks)
            PlaylistEntry(docId: t.id, track: t, addedAt: DateTime(2026)),
        ];

  List<PlaylistEntry> _entries;
  final _changes = StreamController<List<PlaylistEntry>>.broadcast();
  final removed = <String>[];

  @override
  Stream<List<PlaylistEntry>> watch(String uid) async* {
    yield _entries;
    yield* _changes.stream;
  }

  @override
  Future<Result<void>> add(String uid, Track track) async {
    _entries = [
      ..._entries,
      PlaylistEntry(docId: track.id, track: track, addedAt: DateTime(2026))
    ];
    _changes.add(_entries);
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String uid, String docId) async {
    removed.add(docId);
    _entries = _entries.where((e) => e.docId != docId).toList();
    _changes.add(_entries);
    return const Success(null);
  }
}

class _FakeProfile implements ProfileRepository {
  ProfileTrack? updated;

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(UserProfile(
        uid: uid,
        userName: '정민',
        profileImageUrl: '',
        backgroundImageUrl: '',
        track: const ProfileTrack(
            id: 't1', name: '도시의 불빛', artistsName: '네온 라디오', imageUrl: ''),
      ));

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) async {
    updated = track;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Unused implements PlaybackRepository, YoutubeRepository {
  String? lastTitle;

  @override
  Future<Result<String>> findVideoId(
      {required String title, required String singer}) async {
    lastTitle = '$title/$singer';
    return const Failed(NotFoundFailure('영상을 찾지 못했어요.'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<({_FakePlaylist playlist, _FakeProfile profile, _Unused youtube})> _pump(
    WidgetTester tester, Widget screen,
    {List<Track> saved = const []}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final spotify = _FakeSpotify();
  final playlist = _FakePlaylist(saved);
  final profile = _FakeProfile();
  final youtube = _Unused();
  Get.put(MusicController(
    account: spotify,
    search: spotify,
    playlist: playlist,
    playback: youtube,
    youtube: youtube,
    profile: profile,
    uid: 'me',
  ));
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pumpAndSettle();
  return (playlist: playlist, profile: profile, youtube: youtube);
}

void main() {
  tearDown(Get.reset);

  group('음악 컬렉션', () {
    testWidgets('나의 인생곡과 담아 둔 곡을 보여주고, 인생곡인 곡에 표시를 붙인다', (tester) async {
      await _pump(tester, const MusicCollectionScreen(), saved: [_city, _wave]);

      expect(tester.takeException(), isNull);
      expect(find.text('LIFE SONG · 나의 인생곡'), findsOneWidget);
      expect(find.text('도시의 불빛'), findsNWidgets(2));
      expect(find.text('인생곡'), findsOneWidget);
      expect(find.text('파도 소리'), findsOneWidget);
    });

    testWidgets('길게 눌러 확인하면 인생곡으로 정한다', (tester) async {
      final fakes = await _pump(tester, const MusicCollectionScreen(),
          saved: [_city, _wave]);

      await tester.longPress(find.text('파도 소리'));
      await tester.pumpAndSettle();
      expect(find.text('인생곡으로 정할까요?'), findsOneWidget);

      await tester.tap(find.text('정하기'));
      await tester.pumpAndSettle();

      expect(fakes.profile.updated?.id, 't2');
      expect(find.text('인생곡을 「파도 소리」으로 바꿨어요.'), findsOneWidget);
    });

    testWidgets('왼쪽으로 밀면 지운다', (tester) async {
      final fakes = await _pump(tester, const MusicCollectionScreen(),
          saved: [_city, _wave]);

      await tester.drag(find.text('파도 소리'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(fakes.playlist.removed, ['t2']);
      expect(find.text('파도 소리'), findsNothing);
    });

    testWidgets('담아 둔 곡이 없으면 담으러 가기를 보여준다', (tester) async {
      await _pump(tester, const MusicCollectionScreen());

      expect(find.text('담아 둔 곡이 없어요.'), findsOneWidget);
      expect(find.text('곡 담으러 가기'), findsOneWidget);
    });
  });

  testWidgets('곡 담기: 이미 담은 곡은 [담음], 새 곡은 담으면 [담음]으로 바뀐다', (tester) async {
    await _pump(tester, const PlaylistSearchScreen(), saved: [_city]);

    await tester.enterText(find.byType(TextField), 'city');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('담음'), findsOneWidget);
    expect(find.text('담기'), findsOneWidget);

    await tester.tap(find.text('담기'));
    await tester.pumpAndSettle();

    expect(find.text('담음'), findsNWidgets(2));
  });

  testWidgets('YouTube: 비어 있으면 찾지 않고, 적으면 제목과 가수로 찾는다', (tester) async {
    final fakes = await _pump(tester, const YoutubeSearchScreen());

    expect(find.text('찾은 영상이 여기서 바로 재생돼요'), findsOneWidget);

    await tester.tap(find.text('찾기'));
    await tester.pump();
    expect(find.text('곡 제목을 적어 주세요.'), findsOneWidget);
    expect(fakes.youtube.lastTitle, isNull);

    await tester.enterText(find.byType(TextFormField).at(0), ' 도시의 불빛 ');
    await tester.enterText(find.byType(TextFormField).at(1), '네온 라디오');
    await tester.tap(find.text('찾기'));
    await tester.pumpAndSettle();

    expect(fakes.youtube.lastTitle, '도시의 불빛/네온 라디오');
  });
}
