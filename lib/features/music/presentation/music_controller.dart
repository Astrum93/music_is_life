import 'dart:async';

import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// Spotify 연결·곡 검색·마이 뮤직·대표곡·게시물 곡 선택·재생·유튜브 검색 상태
class MusicController extends GetxController {
  MusicController({
    required SpotifyAccountRepository account,
    required TrackSearchRepository search,
    required PlaylistRepository playlist,
    required PlaybackRepository playback,
    required YoutubeRepository youtube,
    required ProfileRepository profile,
    required this.uid,
  })  : _account = account,
        _search = search,
        _playlist = playlist,
        _playback = playback,
        _youtube = youtube,
        _profile = profile;

  final SpotifyAccountRepository _account;
  final TrackSearchRepository _search;
  final PlaylistRepository _playlist;
  final PlaybackRepository _playback;
  final YoutubeRepository _youtube;
  final ProfileRepository _profile;

  /// 로그인한 나
  final String uid;

  final isSpotifyConnected = false.obs;
  final searchResults = <Track>[].obs;
  final isSearching = false.obs;
  final playlist = <PlaylistEntry>[].obs;

  /// 게시물에 붙일 곡 (게시물당 한 곡)
  final pickedTrack = Rxn<Track>();

  StreamSubscription<List<PlaylistEntry>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _playlist.watch(uid).listen(playlist.assignAll);
    refreshConnection();
  }

  Future<void> refreshConnection() async {
    isSpotifyConnected.value = await _account.isConnected();
  }

  Future<Result<void>> connectSpotify() async {
    final result = await _account.connect();
    await refreshConnection();
    return result;
  }

  Future<Result<void>> disconnectSpotify() async {
    final result = await _account.disconnect();
    await refreshConnection();
    return result;
  }

  Future<Result<List<Track>>> searchTracks(String query) async {
    isSearching.value = true;
    try {
      final result = await _search.search(query);
      switch (result) {
        case Success(:final value):
          searchResults.assignAll(value);
        case Failed(failure: AuthFailure(code: 'spotify-not-connected')):
          searchResults.clear();
          isSpotifyConnected.value = false;
        case Failed():
          searchResults.clear();
      }
      return result;
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() => searchResults.clear();

  Future<Result<void>> addToPlaylist(Track track) => _playlist.add(uid, track);

  Future<Result<void>> removeFromPlaylist(PlaylistEntry entry) =>
      _playlist.remove(uid, entry.docId);

  /// 마이페이지 대표곡으로 설정한다.
  Future<Result<void>> setProfileTrack(Track track) => _profile.updateTrack(
        uid,
        ProfileTrack(
          id: track.id,
          name: track.name,
          artistsName: track.artistsName,
          imageUrl: track.imageUrl,
        ),
      );

  /// 게시물에 붙일 곡을 고른다. 이미 골랐으면 실패를 돌려준다.
  Result<void> pickForContent(Track track) {
    if (pickedTrack.value != null) {
      return const Failed(InvalidRequestFailure('게시물당 한 곡만 가능합니다.', code: 'already-picked'));
    }
    pickedTrack.value = track;
    return const Success(null);
  }

  void clearPickedTrack() => pickedTrack.value = null;

  Future<Result<void>> play(String trackId) => _playback.play(trackId);

  Future<Result<String>> findYoutubeVideo({required String title, required String singer}) =>
      _youtube.findVideoId(title: title, singer: singer);

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
