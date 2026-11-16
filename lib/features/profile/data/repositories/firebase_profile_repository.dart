import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/utils/image_upload_metadata.dart';
import 'package:music_is_life/features/profile/data/models/user_profile_mapper.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository(this._firestore, this._storage, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final DateTime Function() _now;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('UserInfo').doc(uid);

  @override
  Stream<UserProfile?> watchProfile(String uid) => _doc(uid).snapshots().map(
        (snap) => snap.exists ? userProfileFromFirestore(uid, snap.data()!) : null,
      );

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async {
    if (uids.isEmpty) return const Success([]);
    try {
      final byUid = <String, UserProfile>{};
      // whereIn은 한 번에 30개까지만 받으므로 나눠서 조회한다.
      for (var i = 0; i < uids.length; i += 30) {
        final chunk = uids.sublist(i, (i + 30).clamp(0, uids.length));
        final snap = await _firestore
            .collection('UserInfo')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final d in snap.docs) {
          byUid[d.id] = userProfileFromFirestore(d.id, d.data());
        }
      }
      return Success([
        for (final uid in uids)
          if (byUid[uid] case final profile?) profile,
      ]);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('사용자 정보를 불러오지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('사용자 정보를 불러오지 못했습니다.', e));
    }
  }

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async {
    try {
      final snap = await _firestore.collection('UserInfo').get();
      return Success([
        for (final d in snap.docs) userProfileFromFirestore(d.id, d.data()),
      ]);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('사용자 목록을 불러오지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('사용자 목록을 불러오지 못했습니다.', e));
    }
  }

  @override
  Future<Result<void>> updateProfileImage(String uid, File image) =>
      _uploadAndSet(
        uid: uid,
        image: image,
        // Storage 규칙: userProfileImage/{uid}_profile_* 만 업로드 가능
        path: 'userProfileImage/${uid}_profile_${_now().millisecondsSinceEpoch}.png',
        field: UserInfoFields.profileImage,
      );

  @override
  Future<Result<void>> updateBackgroundImage(String uid, File image) =>
      _uploadAndSet(
        uid: uid,
        image: image,
        // Storage 규칙: userProfileBG/{uid}_profileBG_* 만 업로드 가능
        path: 'userProfileBG/${uid}_profileBG_${_now().millisecondsSinceEpoch}.png',
        field: UserInfoFields.backgroundImage,
      );

  @override
  Future<Result<void>> updateIntroduction(String uid, String introduction) =>
      _guard('프로필 소개를 저장하지 못했습니다.', () =>
          _doc(uid).update({UserInfoFields.introduction: introduction.trim()}));

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) =>
      _guard('대표곡을 저장하지 못했습니다.', () =>
          _doc(uid).update(profileTrackToFirestore(track)));

  Future<Result<void>> _uploadAndSet({
    required String uid,
    required File image,
    required String path,
    required String field,
  }) =>
      _guard('사진을 저장하지 못했습니다.', () async {
        final ref = _storage.ref(path);
        await ref.putFile(image, imageUploadMetadata(image));
        final url = await ref.getDownloadURL();
        await _doc(uid).update({field: url});
      });

  Future<Result<void>> _guard(String message, Future<void> Function() body) async {
    try {
      await body();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure(message, code: e.code));
    } catch (e) {
      return Failed(UnknownFailure(message, e));
    }
  }
}
