import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
import 'package:music_is_life/features/music/data/repositories/firebase_playlist_repository.dart';
import 'package:music_is_life/features/music/data/repositories/naver_youtube_repository.dart';
import 'package:music_is_life/features/music/data/repositories/spotify_playback_repository.dart';
import 'package:music_is_life/features/music/data/repositories/spotify_repository.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 홈(유튜브 검색)과 마이페이지(마이 뮤직, 대표곡, 게시물 곡 선택)에서 쓰는 음악 의존성
///
/// .env에는 CLIENT_ID와 REDIRECT_URI만 있으면 된다. (CLIENT_SECRET은 더 이상 쓰지 않는다)
class MusicBinding extends Bindings {
  // Spotify 대시보드와 AndroidManifest·Info.plist에 등록한 앱 scheme
  static const _customUriScheme = 'com.naspace.musicislife';

  @override
  void dependencies() {
    final clientId = dotenv.env['CLIENT_ID'] ?? '';
    final redirectUri = dotenv.env['REDIRECT_URI'] ?? '$_customUriScheme://callback';
    final uid = Get.find<SessionController>().currentUser.value!.uid;

    Get.lazyPut(() {
      final spotify = SpotifyRepository(
        clientId: clientId,
        redirectUri: redirectUri,
        customUriScheme: _customUriScheme,
      );
      return MusicController(
        account: spotify,
        search: spotify,
        playlist: FirebasePlaylistRepository(Get.find<FirebaseFirestore>()),
        playback: SpotifyPlaybackRepository(clientId: clientId, redirectUri: redirectUri),
        youtube: NaverYoutubeRepository(),
        profile: Get.find<ProfileRepository>(),
        uid: uid,
      );
    });
  }
}
