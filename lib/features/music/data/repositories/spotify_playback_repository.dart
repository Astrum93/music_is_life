import 'package:flutter/services.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

/// Spotify 앱 원격 제어로 곡 재생 (secret 불필요)
class SpotifyPlaybackRepository implements PlaybackRepository {
  SpotifyPlaybackRepository({required this.clientId, required this.redirectUri});

  final String clientId;
  final String redirectUri;

  @override
  Future<Result<void>> play(String trackId) async {
    if (trackId.isEmpty) {
      return const Failed(InvalidRequestFailure('재생할 곡 정보가 없습니다.', code: 'no-track'));
    }
    try {
      final connected = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUri,
      );
      if (!connected) {
        return const Failed(ServerFailure('Spotify 앱에 연결하지 못했습니다.'));
      }
      await SpotifySdk.play(spotifyUri: 'spotify:track:$trackId');
      return const Success(null);
    } on PlatformException catch (e) {
      return Failed(ServerFailure(
        'Spotify 앱으로 재생하지 못했습니다. Spotify 앱이 설치되어 있는지 확인해 주세요.',
        code: e.code,
      ));
    } on MissingPluginException {
      return const Failed(ServerFailure('이 기기에서는 Spotify 재생을 지원하지 않습니다.'));
    } catch (e) {
      return Failed(UnknownFailure('재생하지 못했습니다.', e));
    }
  }
}
