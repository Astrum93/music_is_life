import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeFriendsRepository implements FriendsRepository {
  final relations = StreamController<FriendRelations>.broadcast();
  final calls = <String>[];

  @override
  Stream<FriendRelations> watchRelations(String uid) => relations.stream;

  @override
  Future<Result<void>> follow({required String me, required String target}) async {
    calls.add('follow:$me->$target');
    return const Success(null);
  }

  @override
  Future<Result<void>> unfollow({required String me, required String target}) async {
    calls.add('unfollow:$me->$target');
    return const Success(null);
  }

  @override
  Future<Result<void>> addFriend({required String me, required String friend}) async {
    calls.add('add:$me->$friend');
    return const Success(null);
  }
}

UserProfile _p(String uid, String name) =>
    UserProfile(uid: uid, userName: name, profileImageUrl: '', backgroundImageUrl: '');

class _FakeProfileRepository implements ProfileRepository {
  final all = [_p('me', '나'), _p('a', '뮤직러버'), _p('b', '음악광'), _p('c', '러버')];

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async => Success(all);

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      Success([for (final uid in uids) ...all.where((p) => p.uid == uid)]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeFriendsRepository repository;
  late FriendsController controller;

  setUp(() {
    repository = _FakeFriendsRepository();
    controller = FriendsController(repository, _FakeProfileRepository(), uid: 'me')..onInit();
  });

  tearDown(() => controller.onClose());

  Future<void> emit(FriendRelations r) async {
    repository.relations.add(r);
    await Future<void>.delayed(Duration.zero);
  }

  test('관계가 바뀌면 팔로워·팔로잉·친구 프로필 목록을 다시 불러온다', () async {
    await emit(const FriendRelations(friends: ['a'], followers: ['b', 'c'], following: ['a']));

    expect(controller.friendProfiles.map((p) => p.uid), ['a']);
    expect(controller.followerProfiles.map((p) => p.uid), ['b', 'c']);
    expect(controller.followingProfiles.map((p) => p.userName), ['뮤직러버']);
  });

  test('팔로우 중이면 언팔로우, 아니면 팔로우한다', () async {
    await emit(const FriendRelations(following: ['a']));

    await controller.toggleFollow('a');
    await controller.toggleFollow('b');

    expect(repository.calls, ['unfollow:me->a', 'follow:me->b']);
  });

  test('추천 친구에서는 나와 이미 친구인 사용자를 뺀다', () async {
    await emit(const FriendRelations(friends: ['a']));

    await controller.loadRecommendations();

    expect(controller.recommendations.map((p) => p.uid), ['b', 'c']);
  });

  test('검색은 이름(userName)으로 찾고 나는 빼며, 빈 검색어면 결과를 비운다', () async {
    await controller.search('러버');
    expect(controller.searchResults.map((p) => p.uid), ['a', 'c']);

    await controller.search('나');
    expect(controller.searchResults, isEmpty);

    await controller.search('  ');
    expect(controller.searchResults, isEmpty);
  });
}
