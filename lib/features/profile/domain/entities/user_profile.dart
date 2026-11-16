import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// 공개 프로필 (UserInfo/{uid})
///
/// 메일·전화번호 같은 비공개 정보는 담지 않는다. (UserPrivate/{uid})
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String userName,
    required String profileImageUrl,
    required String backgroundImageUrl,
    @Default('') String introduction,

    /// 프로필 대표곡. 설정하지 않았으면 null.
    ProfileTrack? track,
  }) = _UserProfile;
}

/// 프로필 대표곡
@freezed
abstract class ProfileTrack with _$ProfileTrack {
  const factory ProfileTrack({
    required String id,
    required String name,
    required String artistsName,
    required String imageUrl,
  }) = _ProfileTrack;
}
