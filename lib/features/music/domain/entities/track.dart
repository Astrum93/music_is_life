import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';

/// Spotify 곡
@freezed
abstract class Track with _$Track {
  const factory Track({
    /// Spotify 곡 ID (spotify:track:{id})
    required String id,
    required String name,
    required String artistsName,
    required String imageUrl,
  }) = _Track;
}

/// 내 플레이리스트에 담긴 곡 (UserInfo/{uid}/UserPlayList/{docId})
@freezed
abstract class PlaylistEntry with _$PlaylistEntry {
  const factory PlaylistEntry({
    /// 문서 ID. 예전에 담은 곡은 곡 제목, 새로 담은 곡은 Spotify 곡 ID다.
    required String docId,
    required Track track,
    required DateTime addedAt,
  }) = _PlaylistEntry;
}
