import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/features/profile/data/models/user_profile_mapper.dart';
import 'package:music_is_life/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

void main() {
  const uid = 'u1';

  group('userProfileFromFirestore', () {
    test('대표곡 필드가 없는 문서도 에러 없이 track=null로 읽는다', () {
      final profile = userProfileFromFirestore(uid, {
        'userName': 'test',
        'userProfileImage': 'https://img/p.png',
        'userProfileBgImage': 'https://img/bg.png',
        'userProfileInfo': '',
      });

      expect(profile.userName, 'test');
      expect(profile.track, isNull);
    });

    test('대표곡 필드가 있으면 ProfileTrack으로 읽는다', () {
      final profile = userProfileFromFirestore(uid, {
        'userName': 'NA',
        'userProfileTrackId': 't1',
        'userProfileTrackName': 'Love wins all',
        'userProfileTrackArtistsName': 'IU',
        'userProfileTrackImage': 'https://img/t.png',
      });

      expect(
        profile.track,
        const ProfileTrack(
          id: 't1',
          name: 'Love wins all',
          artistsName: 'IU',
          imageUrl: 'https://img/t.png',
        ),
      );
    });

    test('사진 필드가 비어 있으면 기본 이미지를 쓴다', () {
      final profile = userProfileFromFirestore(uid, {'userName': 'x', 'userProfileImage': ''});

      expect(profile.profileImageUrl, baseProfileImage);
      expect(profile.backgroundImageUrl, baseProfileBgImage);
    });
  });

  group('FirebaseProfileRepository', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseStorage storage;
    late FirebaseProfileRepository repository;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      storage = MockFirebaseStorage();
      repository = FirebaseProfileRepository(
        firestore,
        storage,
        now: () => DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
      await firestore.collection('UserInfo').doc(uid).set({
        'uid': uid,
        'userName': 'test',
        'userProfileImage': 'old.png',
        'userProfileBgImage': 'old-bg.png',
        'userProfileInfo': '안녕하세요',
      });
    });

    test('watchProfile은 문서를 UserProfile로 내보낸다', () async {
      final profile = await repository.watchProfile(uid).first;

      expect(profile?.userName, 'test');
      expect(profile?.introduction, '안녕하세요');
    });

    test('watchProfile은 문서가 없으면 null을 내보낸다', () async {
      expect(await repository.watchProfile('nobody').first, isNull);
    });

    test('updateIntroduction은 소개를 바꾸고 앞뒤 공백을 지운다', () async {
      final result = await repository.updateIntroduction(uid, '  새 소개  ');

      expect(result.isSuccess, isTrue);
      final doc = await firestore.collection('UserInfo').doc(uid).get();
      expect(doc.data()!['userProfileInfo'], '새 소개');
    });

    test('updateProfileImage는 규칙에 맞는 경로에 image 형식으로 올리고 URL을 저장한다', () async {
      final file = File('${Directory.systemTemp.path}/profile_test.jpg')..writeAsBytesSync([1, 2, 3]);

      final result = await repository.updateProfileImage(uid, file);

      expect(result.isSuccess, isTrue);
      const path = 'userProfileImage/u1_profile_1700000000000.png';
      expect(storage.storedSettableMetadataMap.keys, contains(path));
      expect(storage.storedSettableMetadataMap[path]!['contentType'], 'image/jpeg');
      final doc = await firestore.collection('UserInfo').doc(uid).get();
      expect(doc.data()!['userProfileImage'], endsWith('/$path'));
    });

    test('updateBackgroundImage는 userProfileBG/{uid}_profileBG_* 경로를 쓴다', () async {
      final file = File('${Directory.systemTemp.path}/bg_test.png')..writeAsBytesSync([1]);

      await repository.updateBackgroundImage(uid, file);

      final doc = await firestore.collection('UserInfo').doc(uid).get();
      expect(doc.data()!['userProfileBgImage'], endsWith('/userProfileBG/u1_profileBG_1700000000000.png'));
    });

    test('updateTrack은 대표곡 필드 4개를 저장한다', () async {
      await repository.updateTrack(
        uid,
        const ProfileTrack(id: 't1', name: '곡', artistsName: '가수', imageUrl: 'img'),
      );

      final profile = await repository.watchProfile(uid).first;
      expect(profile?.track?.name, '곡');
    });

    test('문서가 없으면 실패를 돌려준다 (예외를 던지지 않음)', () async {
      final result = await repository.updateIntroduction('nobody', '소개');

      expect(result.isFailed, isTrue);
    });
  });
}
