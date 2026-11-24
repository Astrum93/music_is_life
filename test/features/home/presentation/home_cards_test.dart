import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/friends/domain/entities/friend_relations.dart';
import 'package:music_is_life/features/friends/domain/repositories/friends_repository.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/home/presentation/screen/widget/home_cards.dart';
import 'package:music_is_life/features/home/presentation/story_stats.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeContentsRepository implements ContentsRepository {
  final likes = <({String id, bool liked})>[];

  @override
  Stream<List<Content>> watchAll() => const Stream.empty();

  @override
  Stream<List<Content>> watchByAuthor(String authorUid) => const Stream.empty();

  @override
  Future<Result<void>> setLiked(
      {required String contentId,
      required String uid,
      required bool liked}) async {
    likes.add((id: contentId, liked: liked));
    return const Success(null);
  }

  @override
  Future<Result<Content>> create(
          {required String authorUid,
          required String authorName,
          required NewContent content}) =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(
        UserProfile(
            uid: uid,
            userName: uid,
            profileImageUrl: '',
            backgroundImageUrl: ''),
      );

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async =>
      const Success([]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async =>
      const Success([]);

  @override
  Future<Result<void>> updateProfileImage(String uid, File image) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateBackgroundImage(String uid, File image) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateIntroduction(String uid, String introduction) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) =>
      throw UnimplementedError();
}

class _FakeFriendsRepository implements FriendsRepository {
  final followed = <String>[];

  @override
  Stream<FriendRelations> watchRelations(String uid) =>
      Stream.value(FriendRelations.empty);

  @override
  Future<Result<void>> follow(
      {required String me, required String target}) async {
    followed.add(target);
    return const Success(null);
  }

  @override
  Future<Result<void>> unfollow(
          {required String me, required String target}) async =>
      const Success(null);

  @override
  Future<Result<void>> addFriend(
          {required String me, required String friend}) async =>
      const Success(null);
}

Content _story(String id, String author, DateTime at, {int likes = 0}) =>
    Content(
      id: id,
      authorUid: author,
      authorName: author,
      title: '잠이 오지 않던 새벽, 무작정 강변을 달렸다',
      body: '창문을 조금 내리고 이 노래를 틀었을 때 그제야 숨이 쉬어졌어.',
      imageUrl: '',
      createdAt: at,
      likedBy: List.generate(likes, (i) => 'u$i'),
      track: const ContentTrack(
          name: '도시의 불빛',
          artistsName: '네온 라디오',
          imageUrl: 'https://example.com/a.jpg'),
    );

Widget _wrap(Widget child, {double width = 360}) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(child: SizedBox(width: width, child: child)),
        ),
      ),
    );

void main() {
  late _FakeContentsRepository contents;
  late _FakeFriendsRepository friends;

  setUp(() {
    contents = _FakeContentsRepository();
    friends = _FakeFriendsRepository();
    Get.put(ContentsController(contents, _FakeProfileRepository(),
        uid: 'me', userName: '나'));
    Get.put(FriendsController(friends, _FakeProfileRepository(), uid: 'me'));
  });

  tearDown(Get.reset);

  testWidgets('HomeStoryCard: 넘치지 않고 순번·공감을 보여주며 팔로우·공감이 동작한다', (tester) async {
    final now = DateTime(2026, 11, 24);
    final stories = [
      _story('first', 'night_neon', DateTime(2026, 11, 1)),
      _story('second', 'night_neon', DateTime(2026, 11, 20), likes: 1284),
    ];
    final stats = StoryStats(stories);

    await tester.pumpWidget(_wrap(SizedBox(
      height: 470,
      child: HomeStoryCard(content: stories[1], stats: stats, now: now),
    )));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('night_neon'), findsOneWidget);
    expect(find.textContaining('2번째 이야기'), findsOneWidget);
    expect(find.textContaining('D+24'), findsOneWidget);
    expect(find.text('SIDE A · 이야기'), findsOneWidget);
    expect(find.text('나도 이 노래로 버텼어 1,284'), findsOneWidget);

    await tester.tap(find.text('팔로우'));
    await tester.pump();
    expect(friends.followed, ['night_neon']);

    await tester.tap(find.text('나도 이 노래로 버텼어 1,284'));
    await tester.pump();
    expect(contents.likes, [(id: 'second', liked: true)]);
  });

  testWidgets('내 이야기에는 팔로우 버튼이 없다', (tester) async {
    final mine = _story('m', 'me', DateTime(2026, 11, 20));
    await tester.pumpWidget(_wrap(SizedBox(
      height: 470,
      child: HomeStoryCard(
          content: mine,
          stats: StoryStats([mine]),
          now: DateTime(2026, 11, 24)),
    )));
    await tester.pump();
    expect(find.text('팔로우'), findsNothing);
  });

  testWidgets('MyDiaryCard: 첫 기록 전과 후의 문구', (tester) async {
    await tester.pumpWidget(
        _wrap(MyDiaryCard(storyCount: 0, dayCount: 0, onWrite: () {})));
    expect(find.text('DAY 1'), findsOneWidget);
    expect(find.text('첫 번째 이야기를 남겨볼까요?'), findsOneWidget);

    await tester.pumpWidget(
        _wrap(MyDiaryCard(storyCount: 287, dayCount: 412, onWrite: () {})));
    expect(find.text('D+412'), findsOneWidget);
    expect(find.text('오늘은 288번째 이야기를 남겨볼까요?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MilestoneCard: 칭호 달성 표시가 넘치지 않는다', (tester) async {
    final now = DateTime(2026, 11, 24);
    final stories = List.generate(
        365,
        (i) => _story(
            's$i', 'haneul.forest', now.subtract(Duration(days: 364 - i))));
    final stats = StoryStats(stories);
    final milestone = pickRecentMilestone(stories, stats, now)!;

    await tester.pumpWidget(_wrap(
        MilestoneCard(milestone: milestone, stats: stats, author: null),
        width: 358));
    expect(tester.takeException(), isNull);
    expect(find.text('아카이비스트 달성'), findsOneWidget);
    expect(find.textContaining('365번째 이야기를 남겼어요'), findsOneWidget);
  });
}
