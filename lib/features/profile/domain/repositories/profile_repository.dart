import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 프로필 Repository
abstract interface class ProfileRepository {
  /// 프로필이 바뀔 때마다 내보낸다. 문서가 없으면 null.
  Stream<UserProfile?> watchProfile(String uid);

  /// 여러 사용자의 프로필을 한 번에 불러온다. 순서는 [uids]를 따르고, 없는 사용자는 빠진다.
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids);

  /// 모든 사용자의 프로필 (친구 추천·검색용)
  Future<Result<List<UserProfile>>> fetchAllProfiles();

  /// 프로필 소개를 바꾼다.
  Future<Result<void>> updateIntroduction(String uid, String introduction);

  /// 프로필 대표곡을 바꾼다.
  Future<Result<void>> updateTrack(String uid, ProfileTrack track);
}
