import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/utils/image_upload_metadata.dart';
import 'package:music_is_life/features/contents/data/models/content_mapper.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';

class FirebaseContentsRepository implements ContentsRepository {
  FirebaseContentsRepository(this._firestore, this._storage, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('UserContents');

  List<Content> _toContents(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map((d) => contentFromFirestore(d.id, d.data())).toList()
      // authorUid + time 정렬은 복합 인덱스가 필요하므로 클라이언트에서 정렬한다.
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<Content>> watchAll() => _collection.snapshots().map(_toContents);

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) => _collection
      .where(ContentFields.authorUid, isEqualTo: authorUid)
      .snapshots()
      .map(_toContents);

  @override
  Future<Result<Content>> create({
    required String authorUid,
    required String authorName,
    required NewContent content,
  }) async {
    try {
      // 제목이 같아도 덮어쓰지 않도록 자동 ID를 쓰고, 이미지 경로도 문서 ID로 만든다.
      // Storage 규칙: userContents/{내 uid}/ 아래에만 업로드 가능
      final doc = _collection.doc();
      final ref = _storage.ref('userContents/$authorUid/${doc.id}.png');
      await ref.putFile(content.image, imageUploadMetadata(content.image));
      final imageUrl = await ref.getDownloadURL();

      final created = Content(
        id: doc.id,
        authorUid: authorUid,
        authorName: authorName,
        title: content.title.trim(),
        body: content.body.trim(),
        imageUrl: imageUrl,
        createdAt: _now(),
        hashTags: content.hashTags.map((t) => t.trim()).toList(),
        track: content.track,
      );
      await doc.set(contentToFirestore(created));
      return Success(created);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('게시물을 올리지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('게시물을 올리지 못했습니다.', e));
    }
  }

  @override
  Future<Result<void>> setLiked({
    required String contentId,
    required String uid,
    required bool liked,
  }) async {
    try {
      // 보안 규칙: 다른 사람 게시물은 likedMember에 내 uid만 넣고 뺄 수 있다.
      await _collection.doc(contentId).update({
        ContentFields.likedBy:
            liked ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('좋아요를 반영하지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('좋아요를 반영하지 못했습니다.', e));
    }
  }
}
