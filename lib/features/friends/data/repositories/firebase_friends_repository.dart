import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';

class FirebaseFriendsRepository implements FriendsRepository {
  FirebaseFriendsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('UserFriends').doc(uid);

  @override
  Stream<FriendRelations> watchRelations(String uid) =>
      _doc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return FriendRelations.empty;
        List<String> list(String key) => data[key] is List
            ? (data[key] as List).whereType<String>().toList()
            : const <String>[];
        return FriendRelations(
          friends: list('friends'),
          followers: list('follower'),
          following: list('following'),
        );
      });

  @override
  Future<Result<void>> follow({required String me, required String target}) =>
      _toggleFollow(me: me, target: target, follow: true);

  @override
  Future<Result<void>> unfollow({required String me, required String target}) =>
      _toggleFollow(me: me, target: target, follow: false);

  Future<Result<void>> _toggleFollow({
    required String me,
    required String target,
    required bool follow,
  }) async {
    if (me == target) {
      return const Failed(
          InvalidRequestFailure('나 자신은 팔로우할 수 없습니다.', code: 'self'));
    }
    FieldValue op(String uid) =>
        follow ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]);
    try {
      // 예전에는 두 문서를 따로 update해서, 중간에 실패하면 한쪽만 바뀌었다.
      // 보안 규칙: 상대 문서는 follower에 내 uid만 넣고 뺄 수 있다.
      await (_firestore.batch()
            ..update(_doc(target), {'follower': op(me)})
            ..update(_doc(me), {'following': op(target)}))
          .commit();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure(
        follow ? '팔로우하지 못했습니다.' : '팔로우를 취소하지 못했습니다.',
        code: e.code,
      ));
    } catch (e) {
      return Failed(UnknownFailure('팔로우 상태를 바꾸지 못했습니다.', e));
    }
  }

  @override
  Future<Result<void>> addFriend(
      {required String me, required String friend}) async {
    if (me == friend) {
      return const Failed(
          InvalidRequestFailure('나 자신은 친구로 추가할 수 없습니다.', code: 'self'));
    }
    try {
      final snap = await _doc(me).get();
      final friends =
          (snap.data()?['friends'] as List?)?.whereType<String>() ?? [];
      if (friends.contains(friend)) {
        return const Failed(
            InvalidRequestFailure('이미 등록된 사용자입니다.', code: 'already-friend'));
      }
      // 예전에는 set으로 문서를 통째로 덮어써서 follower/following이 지워졌다.
      await _doc(me).update({
        'friends': FieldValue.arrayUnion([friend])
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failed(ServerFailure('친구를 추가하지 못했습니다.', code: e.code));
    } catch (e) {
      return Failed(UnknownFailure('친구를 추가하지 못했습니다.', e));
    }
  }
}
