import 'dart:io';

import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 프로필 Repository
abstract interface class ProfileRepository {
  /// 프로필이 바뀔 때마다 내보낸다. 문서가 없으면 null.
  Stream<UserProfile?> watchProfile(String uid);

  /// 프로필 사진을 올리고 UserInfo에 반영한다.
  Future<Result<void>> updateProfileImage(String uid, File image);

  /// 프로필 배경 사진을 올리고 UserInfo에 반영한다.
  Future<Result<void>> updateBackgroundImage(String uid, File image);

  /// 프로필 소개를 바꾼다.
  Future<Result<void>> updateIntroduction(String uid, String introduction);

  /// 프로필 대표곡을 바꾼다.
  Future<Result<void>> updateTrack(String uid, ProfileTrack track);
}
