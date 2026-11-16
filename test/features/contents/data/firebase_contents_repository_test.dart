import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/features/contents/data/models/content_mapper.dart';
import 'package:music_is_life/features/contents/data/repositories/firebase_contents_repository.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';

void main() {
  group('contentFromFirestore', () {
    test('예전 게시물 필드(name, contents, time 등)를 Content로 읽는다', () {
      final content = contentFromFirestore('c1', {
        'authorUid': 'u1',
        'name': 'NA',
        'title': '딸기 빙수',
        'contents': '본문',
        'contentsImage': 'https://img/c.png',
        'time': Timestamp.fromDate(DateTime(2024, 6, 1)),
        'hashTags': ['여름', '', ''],
        'likedMember': ['u2'],
        'trackName': '곡',
        'trackImage': 'https://img/t.png',
        'artistsName': '가수',
        'id': 'u1', // 예전에 함께 저장하던 필드 (무시)
      });

      expect(content.title, '딸기 빙수');
      expect(content.body, '본문');
      expect(content.createdAt, DateTime(2024, 6, 1));
      expect(content.likeCount, 1);
      expect(content.isLikedBy('u2'), isTrue);
      expect(content.track?.artistsName, '가수');
    });

    test('필드가 빠진 문서도 에러 없이 기본값으로 읽는다', () {
      final content = contentFromFirestore('c2', {'title': '제목만'});

      expect(content.authorUid, '');
      expect(content.hashTags, isEmpty);
      expect(content.likedBy, isEmpty);
      expect(content.track, isNull);
    });
  });

  group('FirebaseContentsRepository', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseStorage storage;
    late FirebaseContentsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      storage = MockFirebaseStorage();
      repository = FirebaseContentsRepository(
        firestore,
        storage,
        now: () => DateTime(2026, 11, 17, 12),
      );
    });

    Future<void> seed(String id, String author, DateTime time, {List<String> liked = const []}) =>
        firestore.collection('UserContents').doc(id).set({
          'authorUid': author,
          'name': author,
          'title': id,
          'contentsImage': 'img',
          'time': Timestamp.fromDate(time),
          'likedMember': liked,
        });

    test('watchAll은 최신순으로 내보낸다', () async {
      await seed('old', 'u1', DateTime(2024));
      await seed('new', 'u2', DateTime(2025));

      final contents = await repository.watchAll().first;

      expect(contents.map((c) => c.id), ['new', 'old']);
    });

    test('watchByAuthor는 해당 작성자의 게시물만 최신순으로 내보낸다', () async {
      await seed('a1', 'u1', DateTime(2024));
      await seed('b1', 'u2', DateTime(2024, 5));
      await seed('a2', 'u1', DateTime(2025));

      final contents = await repository.watchByAuthor('u1').first;

      expect(contents.map((c) => c.id), ['a2', 'a1']);
    });

    test('create는 자동 ID로 저장하고 이미지를 userContents/{uid}/{id}.png에 올린다', () async {
      final image = File('${Directory.systemTemp.path}/content_test.png')..writeAsBytesSync([1, 2]);

      final result = await repository.create(
        authorUid: 'u1',
        authorName: 'NA',
        content: NewContent(
          title: '  같은 제목  ',
          body: '본문',
          image: image,
          hashTags: const [' 태그 ', '', ''],
          track: const ContentTrack(name: '곡', artistsName: '가수', imageUrl: 'ti'),
        ),
      );

      final created = result.valueOrNull!;
      expect(created.title, '같은 제목');
      expect(created.hashTags.first, '태그');
      expect(storage.storedSettableMetadataMap.keys, contains('userContents/u1/${created.id}.png'));
      expect(storage.storedSettableMetadataMap['userContents/u1/${created.id}.png']!['contentType'], 'image/png');

      final doc = await firestore.collection('UserContents').doc(created.id).get();
      expect(doc.data()!['authorUid'], 'u1');
      expect(doc.data()!['name'], 'NA');
      expect(doc.data()!['likedMember'], isEmpty);
      expect(doc.data()!['trackName'], '곡');
      expect((doc.data()!['time'] as Timestamp).toDate(), DateTime(2026, 11, 17, 12));
    });

    test('같은 제목으로 두 번 써도 서로 덮어쓰지 않는다', () async {
      final image = File('${Directory.systemTemp.path}/content_test2.png')..writeAsBytesSync([1]);
      final input = NewContent(
        title: '같은 제목',
        body: '',
        image: image,
        track: const ContentTrack(name: '곡', artistsName: '', imageUrl: ''),
      );

      await repository.create(authorUid: 'u1', authorName: 'NA', content: input);
      await repository.create(authorUid: 'u1', authorName: 'NA', content: input);

      final all = await firestore.collection('UserContents').get();
      expect(all.docs, hasLength(2));
    });

    test('setLiked는 내 uid를 넣고 빼고, 다른 사람 좋아요는 유지한다', () async {
      await seed('c1', 'u1', DateTime(2024), liked: ['u3']);

      await repository.setLiked(contentId: 'c1', uid: 'u2', liked: true);
      var doc = await firestore.collection('UserContents').doc('c1').get();
      expect(doc.data()!['likedMember'], ['u3', 'u2']);

      await repository.setLiked(contentId: 'c1', uid: 'u2', liked: false);
      doc = await firestore.collection('UserContents').doc('c1').get();
      expect(doc.data()!['likedMember'], ['u3']);
    });

    test('없는 게시물에 좋아요를 누르면 실패를 돌려준다', () async {
      final result = await repository.setLiked(contentId: 'nope', uid: 'u2', liked: true);

      expect(result.isFailed, isTrue);
    });
  });
}
