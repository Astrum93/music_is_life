import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';

class FirebasePlaylistRepository implements PlaylistRepository {
  FirebasePlaylistRepository(this._firestore, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> _playlist(String uid) =>
      _firestore.collection('UserInfo').doc(uid).collection('UserPlayList');

  @override
  Stream<List<PlaylistEntry>> watch(String uid) => _playlist(uid).snapshots().map((snap) {
        final entries = [
          for (final d in snap.docs) _entryFromFirestore(d.id, d.data()),
        ]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
        return entries;
      });

  @override
  Future<Result<void>> add(String uid, Track track) async {
    try {
      // 예전에는 곡 제목이 문서 ID라 제목이 같은 다른 곡끼리 덮어썼다. 이제 Spotify 곡 ID를 쓴다.
      await _playlist(uid).doc(track.id).set({
        'trackId': track.id,
        'trackName': track.name,
        'artistsName': track.artistsName,
        'trackImage': track.imageUrl,
        'time': Timestamp.fromDate(_now()),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('플레이리스트에 담지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('플레이리스트에 담지 못했습니다.', e));
    }
  }

  @override
  Future<Result<void>> remove(String uid, String docId) async {
    try {
      await _playlist(uid).doc(docId).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('플레이리스트에서 지우지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('플레이리스트에서 지우지 못했습니다.', e));
    }
  }
}

PlaylistEntry _entryFromFirestore(String docId, Map<String, dynamic> data) {
  String str(String key) => data[key] is String ? data[key] as String : '';
  final time = data['time'];
  return PlaylistEntry(
    docId: docId,
    track: Track(
      id: str('trackId'),
      name: str('trackName'),
      artistsName: str('artistsName'),
      imageUrl: str('trackImage'),
    ),
    addedAt: time is Timestamp ? time.toDate() : DateTime.fromMillisecondsSinceEpoch(0),
  );
}
