import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';

/// 내 Spotify 계정 연결 (PKCE 로그인)
///
/// 앱에 client secret을 넣지 않기 위해, 사용자가 자기 Spotify 계정으로 로그인해서 받은
/// 토큰으로 Web API를 호출한다. 토큰은 기기의 보안 저장소에 보관되고 자동으로 갱신된다.
abstract interface class SpotifyAccountRepository {
  Future<bool> isConnected();

  /// Spotify 로그인 화면을 띄워 계정을 연결한다.
  Future<Result<void>> connect();

  /// 저장된 토큰을 지운다.
  Future<Result<void>> disconnect();
}

/// Spotify 곡 검색
abstract interface class TrackSearchRepository {
  /// 계정이 연결되지 않았으면 `AuthFailure(code: 'spotify-not-connected')`를 돌려준다.
  Future<Result<List<Track>>> search(String query);
}

/// 내 플레이리스트 (마이 뮤직)
abstract interface class PlaylistRepository {
  /// 최근에 담은 순
  Stream<List<PlaylistEntry>> watch(String uid);

  Future<Result<void>> add(String uid, Track track);

  Future<Result<void>> remove(String uid, String docId);
}

/// Spotify 앱으로 곡 재생 (기기에 Spotify 앱이 있어야 한다)
abstract interface class PlaybackRepository {
  Future<Result<void>> play(String trackId);
}

/// 곡 제목·가수로 유튜브 영상 찾기
abstract interface class YoutubeRepository {
  Future<Result<String>> findVideoId({required String title, required String singer});
}
