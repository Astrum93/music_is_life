import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/friends/data/repositories/firebase_friends_repository.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseFriendsRepository repository;

  Future<Map<String, dynamic>?> doc(String uid) async =>
      (await firestore.collection('UserFriends').doc(uid).get()).data();

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirebaseFriendsRepository(firestore);
    for (final uid in ['me', 'you']) {
      await firestore.collection('UserFriends').doc(uid).set({
        'friends': <String>[],
        'follower': <String>[],
        'following': <String>[],
      });
    }
  });

  test('watchRelations는 follower/following 필드를 followers/following으로 읽는다', () async {
    await firestore.collection('UserFriends').doc('me').set({
      'friends': ['a'],
      'follower': ['b'],
      'following': ['c'],
    });

    final relations = await repository.watchRelations('me').first;

    expect(relations, const FriendRelations(friends: ['a'], followers: ['b'], following: ['c']));
  });

  test('watchRelations는 문서·필드가 없어도 빈 관계를 내보낸다', () async {
    await firestore.collection('UserFriends').doc('old').set({'friends': ['a']});

    expect(await repository.watchRelations('nobody').first, FriendRelations.empty);
    expect((await repository.watchRelations('old').first).followers, isEmpty);
  });

  test('follow는 상대 follower와 내 following을 함께 갱신한다', () async {
    final result = await repository.follow(me: 'me', target: 'you');

    expect(result.isSuccess, isTrue);
    expect((await doc('you'))!['follower'], ['me']);
    expect((await doc('me'))!['following'], ['you']);
  });

  test('unfollow는 양쪽에서 제거한다', () async {
    await repository.follow(me: 'me', target: 'you');
    await repository.unfollow(me: 'me', target: 'you');

    expect((await doc('you'))!['follower'], isEmpty);
    expect((await doc('me'))!['following'], isEmpty);
  });

  test('나 자신은 팔로우할 수 없다', () async {
    final result = await repository.follow(me: 'me', target: 'me');

    expect((result as Failed).failure, isA<InvalidRequestFailure>());
  });

  test('addFriend는 friends에만 추가하고 follower/following을 지우지 않는다', () async {
    await repository.follow(me: 'you', target: 'me'); // me의 follower에 you

    await repository.addFriend(me: 'me', friend: 'you');

    final me = (await doc('me'))!;
    expect(me['friends'], ['you']);
    expect(me['follower'], ['you']); // 예전에는 set으로 덮어써서 지워졌다
  });

  test('이미 친구거나 나 자신이면 InvalidRequestFailure를 돌려준다', () async {
    await repository.addFriend(me: 'me', friend: 'you');

    final again = await repository.addFriend(me: 'me', friend: 'you');
    final self = await repository.addFriend(me: 'me', friend: 'me');

    expect(((again as Failed).failure as InvalidRequestFailure).code, 'already-friend');
    expect(((self as Failed).failure as InvalidRequestFailure).code, 'self');
  });
}
