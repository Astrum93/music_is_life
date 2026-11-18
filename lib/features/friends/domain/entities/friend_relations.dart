import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_relations.freezed.dart';

/// 한 사용자의 친구·팔로우 관계 (UserFriends/{uid}). 모두 uid 목록이다.
@freezed
abstract class FriendRelations with _$FriendRelations {
  const FriendRelations._();

  const factory FriendRelations({
    /// 내가 친구로 추가한 사용자 (채팅방 초대 대상)
    @Default(<String>[]) List<String> friends,

    /// 나를 팔로우하는 사용자
    @Default(<String>[]) List<String> followers,

    /// 내가 팔로우하는 사용자
    @Default(<String>[]) List<String> following,
  }) = _FriendRelations;

  static const empty = FriendRelations();

  bool isFollowing(String uid) => following.contains(uid);

  bool isFriend(String uid) => friends.contains(uid);
}
