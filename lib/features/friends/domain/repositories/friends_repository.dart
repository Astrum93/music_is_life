import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';

/// 친구·팔로우 Repository
abstract interface class FriendsRepository {
  /// 관계가 바뀔 때마다 내보낸다. 문서가 없으면 [FriendRelations.empty].
  Stream<FriendRelations> watchRelations(String uid);

  /// [me]가 [target]을 팔로우한다. (내 following, 상대 follower를 함께 갱신)
  Future<Result<void>> follow({required String me, required String target});

  /// [me]가 [target]을 언팔로우한다.
  Future<Result<void>> unfollow({required String me, required String target});

  /// [friend]를 [me]의 친구 목록에 추가한다.
  ///
  /// 나 자신이거나 이미 친구면 `InvalidRequestFailure`를 돌려준다.
  Future<Result<void>> addFriend({required String me, required String friend});
}
