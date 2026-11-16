import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// UserInfo/{uid} 문서 필드 이름
abstract final class UserInfoFields {
  static const uid = 'uid';
  static const userName = 'userName';
  static const profileImage = 'userProfileImage';
  static const backgroundImage = 'userProfileBgImage';
  static const introduction = 'userProfileInfo';
  static const trackId = 'userProfileTrackId';
  static const trackName = 'userProfileTrackName';
  static const trackArtistsName = 'userProfileTrackArtistsName';
  static const trackImage = 'userProfileTrackImage';
}

/// Firestore 문서를 [UserProfile]로 바꾼다.
///
/// 예전 코드는 `doc['필드']`로 바로 읽어서, 대표곡을 설정하지 않은 사용자처럼
/// 필드가 없는 문서에서 에러가 났다. 여기서는 없는 필드를 기본값으로 채운다.
UserProfile userProfileFromFirestore(String uid, Map<String, dynamic> data) {
  String? str(String key) {
    final v = data[key];
    return v is String && v.isNotEmpty ? v : null;
  }

  final trackId = str(UserInfoFields.trackId);
  final trackName = str(UserInfoFields.trackName);

  return UserProfile(
    uid: uid,
    userName: str(UserInfoFields.userName) ?? '',
    profileImageUrl: str(UserInfoFields.profileImage) ?? baseProfileImage,
    backgroundImageUrl: str(UserInfoFields.backgroundImage) ?? baseProfileBgImage,
    introduction: str(UserInfoFields.introduction) ?? '',
    track: trackId != null && trackName != null
        ? ProfileTrack(
            id: trackId,
            name: trackName,
            artistsName: str(UserInfoFields.trackArtistsName) ?? '',
            imageUrl: str(UserInfoFields.trackImage) ?? '',
          )
        : null,
  );
}

Map<String, dynamic> profileTrackToFirestore(ProfileTrack track) => {
      UserInfoFields.trackId: track.id,
      UserInfoFields.trackName: track.name,
      UserInfoFields.trackArtistsName: track.artistsName,
      UserInfoFields.trackImage: track.imageUrl,
    };
