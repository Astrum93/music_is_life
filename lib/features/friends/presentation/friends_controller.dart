import 'dart:async';

import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 내 친구·팔로우 관계와 친구 찾기 상태
class FriendsController extends GetxController {
  FriendsController(this._repository, this._profileRepository,
      {required this.uid});

  final FriendsRepository _repository;
  final ProfileRepository _profileRepository;

  /// 로그인한 나
  final String uid;

  final relations = FriendRelations.empty.obs;

  /// 화면에 보여줄 프로필 목록 (relations가 바뀌면 다시 불러온다)
  final friendProfiles = <UserProfile>[].obs;
  final followerProfiles = <UserProfile>[].obs;
  final followingProfiles = <UserProfile>[].obs;

  /// 친구 찾기: 추천 목록과 검색 결과
  final recommendations = <UserProfile>[].obs;
  final searchResults = <UserProfile>[].obs;

  final _allProfiles = <UserProfile>[];
  StreamSubscription<FriendRelations>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _repository.watchRelations(uid).listen((r) {
      relations.value = r;
      _load(friendProfiles, r.friends);
      _load(followerProfiles, r.followers);
      _load(followingProfiles, r.following);
    });
  }

  Future<void> _load(RxList<UserProfile> target, List<String> uids) async {
    final result = await _profileRepository.fetchProfiles(uids);
    if (result case Success(:final value)) target.assignAll(value);
  }

  /// 다른 사용자의 관계 (미니 프로필의 팔로워·팔로잉 수)
  Stream<FriendRelations> watchRelationsOf(String otherUid) =>
      _repository.watchRelations(otherUid);

  bool isFollowing(String target) => relations.value.isFollowing(target);

  Future<Result<void>> toggleFollow(String target) => isFollowing(target)
      ? _repository.unfollow(me: uid, target: target)
      : _repository.follow(me: uid, target: target);

  Future<Result<void>> addFriend(String friend) =>
      _repository.addFriend(me: uid, friend: friend);

  /// 친구 추천: 나와 이미 친구인 사용자를 뺀 모든 사용자
  Future<void> loadRecommendations() async {
    final result = await _profileRepository.fetchAllProfiles();
    if (result case Success(:final value)) {
      _allProfiles
        ..clear()
        ..addAll(value);
      recommendations.assignAll(
        value.where((p) => p.uid != uid && !relations.value.isFriend(p.uid)),
      );
    }
  }

  /// 이름으로 사용자 검색 (나 제외). 빈 검색어면 결과를 비운다.
  Future<void> search(String keyword) async {
    final k = keyword.trim().toLowerCase();
    if (k.isEmpty) {
      searchResults.clear();
      return;
    }
    if (_allProfiles.isEmpty) await loadRecommendations();
    searchResults.assignAll(
      _allProfiles
          .where((p) => p.uid != uid && p.userName.toLowerCase().contains(k)),
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
