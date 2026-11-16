import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

const _track = Track(id: 't1', name: '곡', artistsName: '가수', imageUrl: 'img');

class _FakeSpotify implements SpotifyAccountRepository, TrackSearchRepository {
  bool connected = false;
  Result<List<Track>> searchResult = const Success([_track]);

  @override
  Future<bool> isConnected() async => connected;

  @override
  Future<Result<void>> connect() async {
    connected = true;
    return const Success(null);
  }

  @override
  Future<Result<void>> disconnect() async {
    connected = false;
    return const Success(null);
  }

  @override
  Future<Result<List<Track>>> search(String query) async => searchResult;
}

class _FakePlaylist implements PlaylistRepository {
  final entries = StreamController<List<PlaylistEntry>>.broadcast();
  final calls = <String>[];

  @override
  Stream<List<PlaylistEntry>> watch(String uid) => entries.stream;

  @override
  Future<Result<void>> add(String uid, Track track) async {
    calls.add('add:$uid:${track.id}');
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String uid, String docId) async {
    calls.add('remove:$uid:$docId');
    return const Success(null);
  }
}

class _FakePlayback implements PlaybackRepository {
  String? played;

  @override
  Future<Result<void>> play(String trackId) async {
    played = trackId;
    return const Success(null);
  }
}

class _FakeYoutube implements YoutubeRepository {
  @override
  Future<Result<String>> findVideoId({required String title, required String singer}) async =>
      Success('$title-$singer');
}

class _FakeProfile implements ProfileRepository {
  ProfileTrack? updated;

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) async {
    updated = track;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeSpotify spotify;
  late _FakePlaylist playlist;
  late _FakePlayback playback;
  late _FakeProfile profile;
  late MusicController controller;

  setUp(() async {
    spotify = _FakeSpotify();
    playlist = _FakePlaylist();
    playback = _FakePlayback();
    profile = _FakeProfile();
    controller = MusicController(
      account: spotify,
      search: spotify,
      playlist: playlist,
      playback: playback,
      youtube: _FakeYoutube(),
      profile: profile,
      uid: 'me',
    )..onInit();
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => controller.onClose());

  test('처음에는 연결 상태를 확인하고, 연결하면 true가 된다', () async {
    expect(controller.isSpotifyConnected.value, isFalse);

    await controller.connectSpotify();

    expect(controller.isSpotifyConnected.value, isTrue);
  });

  test('검색 성공 시 결과를 채우고, not-connected 실패면 결과를 비우고 연결 상태를 끈다', () async {
    spotify.connected = true;
    await controller.refreshConnection();
    await controller.searchTracks('곡');
    expect(controller.searchResults, [_track]);

    spotify.searchResult = const Failed(AuthFailure('연결 필요', code: 'spotify-not-connected'));
    await controller.searchTracks('곡');

    expect(controller.searchResults, isEmpty);
    expect(controller.isSpotifyConnected.value, isFalse);
  });

  test('게시물 곡은 한 곡만 고를 수 있고, 비우면 다시 고를 수 있다', () {
    expect(controller.pickForContent(_track).isSuccess, isTrue);
    expect(controller.pickForContent(_track).isFailed, isTrue);

    controller.clearPickedTrack();

    expect(controller.pickForContent(_track).isSuccess, isTrue);
  });

  test('플레이리스트 추가·삭제는 내 uid로 한다', () async {
    await controller.addToPlaylist(_track);
    await controller.removeFromPlaylist(
      PlaylistEntry(docId: 'doc', track: _track, addedAt: DateTime(2024)),
    );

    expect(playlist.calls, ['add:me:t1', 'remove:me:doc']);
  });

  test('대표곡 설정은 곡 정보를 ProfileTrack으로 넘긴다', () async {
    await controller.setProfileTrack(_track);

    expect(profile.updated, const ProfileTrack(id: 't1', name: '곡', artistsName: '가수', imageUrl: 'img'));
  });

  test('재생과 유튜브 검색을 각 Repository에 위임한다', () async {
    await controller.play('t1');
    final video = await controller.findYoutubeVideo(title: '곡', singer: '가수');

    expect(playback.played, 't1');
    expect(video.valueOrNull, '곡-가수');
  });
}
