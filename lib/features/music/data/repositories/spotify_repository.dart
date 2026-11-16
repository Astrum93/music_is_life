import 'dart:convert';

import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';

/// Spotify 계정 연결(PKCE)과 Web API 검색
///
/// 예전에는 앱 안의 CLIENT_SECRET으로 client_credentials 토큰을 받았다.
/// 앱 파일에서 secret을 꺼낼 수 있어서, secret이 필요 없는 PKCE 로그인으로 바꿨다.
class SpotifyRepository implements SpotifyAccountRepository, TrackSearchRepository {
  SpotifyRepository({
    required String clientId,
    required String redirectUri,
    required String customUriScheme,
    OAuth2Helper? helper,
  }) : _helper = helper ??
            OAuth2Helper(
              SpotifyOAuth2Client(
                redirectUri: redirectUri,
                customUriScheme: customUriScheme,
              ),
              clientId: clientId,
              // 곡 검색에는 별도 권한(scope)이 필요 없다.
              scopes: const [],
              enablePKCE: true,
            );

  final OAuth2Helper _helper;

  @override
  Future<bool> isConnected() async {
    try {
      return await _helper.getTokenFromStorage() != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Result<void>> connect() async {
    try {
      await _helper.getToken();
      return const Success(null);
    } catch (_) {
      // 사용자가 로그인 화면을 닫은 경우도 여기로 온다.
      return const Failed(
        AuthFailure('Spotify 계정을 연결하지 못했습니다.', code: 'spotify-connect-failed'),
      );
    }
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      await _helper.removeAllTokens();
      return const Success(null);
    } catch (e) {
      return Failed(UnknownFailure('Spotify 연결을 해제하지 못했습니다.', e));
    }
  }

  @override
  Future<Result<List<Track>>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const Success([]);
    // 연결되지 않은 상태에서 get을 부르면 검색 중에 갑자기 로그인 화면이 뜨므로 먼저 확인한다.
    if (!await isConnected()) {
      return const Failed(
        AuthFailure('Spotify 계정을 먼저 연결해 주세요.', code: 'spotify-not-connected'),
      );
    }
    try {
      // 예전에는 검색어를 인코딩하지 않아 공백·특수문자가 들어가면 검색이 깨질 수 있었다.
      final uri = Uri.https('api.spotify.com', '/v1/search', {
        'q': q,
        'type': 'track',
        'limit': '20',
      });
      final response = await _helper.get(uri.toString());
      if (response.statusCode == 401) {
        return const Failed(
          AuthFailure('Spotify 연결이 만료되었습니다. 다시 연결해 주세요.', code: 'spotify-not-connected'),
        );
      }
      if (response.statusCode != 200) {
        return Failed(ServerFailure('곡을 검색하지 못했습니다.', code: '${response.statusCode}'));
      }
      // 응답 헤더에 charset이 없으면 response.body가 latin1로 해석되어 한글이 깨지므로 UTF-8로 직접 읽는다.
      return Success(parseSearchResponse(utf8.decode(response.bodyBytes)));
    } catch (e) {
      return Failed(UnknownFailure('곡을 검색하지 못했습니다.', e));
    }
  }
}

/// Spotify 검색 응답(JSON)을 [Track] 목록으로 바꾼다.
///
/// 예전 코드는 곡 ID 자리에 가수 ID(artists[0].id)를 저장했다.
List<Track> parseSearchResponse(String body) {
  final json = jsonDecode(body) as Map<String, dynamic>;
  final items = (json['tracks']?['items'] as List?) ?? const [];
  return [
    for (final item in items.whereType<Map<String, dynamic>>())
      Track(
        id: item['id'] as String? ?? '',
        name: item['name'] as String? ?? '',
        artistsName: [
          for (final a in (item['artists'] as List? ?? const []).whereType<Map<String, dynamic>>())
            a['name'] as String? ?? '',
        ].where((n) => n.isNotEmpty).join(', '),
        imageUrl: ((item['album']?['images'] as List?)?.firstOrNull as Map?)?['url'] as String? ?? '',
      ),
  ];
}
