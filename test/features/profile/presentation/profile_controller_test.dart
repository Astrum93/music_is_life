import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';

class _FakeProfileRepository implements ProfileRepository {
  final profiles = StreamController<UserProfile?>.broadcast();
  final calls = <String>[];
  Completer<Result<void>>? pending;

  Future<Result<void>> _record(String call) {
    calls.add(call);
    pending = Completer();
    return pending!.future;
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => profiles.stream;

  @override
  Future<Result<List<UserProfile>>> fetchProfiles(List<String> uids) async => const Success([]);

  @override
  Future<Result<List<UserProfile>>> fetchAllProfiles() async => const Success([]);

  @override
  Future<Result<void>> updateIntroduction(String uid, String introduction) =>
      _record('intro:$uid:$introduction');

  @override
  Future<Result<void>> updateTrack(String uid, ProfileTrack track) => _record('track:$uid');
}

void main() {
  late _FakeProfileRepository repository;
  late ProfileController controller;

  setUp(() {
    repository = _FakeProfileRepository();
    controller = ProfileController(repository, 'u1')..onInit();
  });

  tearDown(() => controller.onClose());

  test('Repository가 내보낸 프로필을 profile에 반영한다', () async {
    const profile = UserProfile(
      uid: 'u1',
      userName: 'test',
      profileImageUrl: 'p',
      backgroundImageUrl: 'bg',
    );
    repository.profiles.add(profile);
    await Future<void>.delayed(Duration.zero);

    expect(controller.profile.value, profile);
  });

  test('저장 중에는 isSaving이 true이고, 실패해도 끝나면 false다', () async {
    final future = controller.updateIntroduction('새 소개');
    expect(controller.isSaving.value, isTrue);

    repository.pending!.complete(const Failed(ServerFailure('실패')));
    final result = await future;

    expect(controller.isSaving.value, isFalse);
    expect(result.isFailed, isTrue);
    expect(repository.calls, ['intro:u1:새 소개']);
  });
}
