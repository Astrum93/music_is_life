import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';
import 'package:music_is_life/features/profile/presentation/widgets/edit_introduction_dialog.dart';

class _FakeProfiles implements ProfileRepository {
  String? saved;

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(UserProfile(
      uid: uid,
      userName: '정민',
      profileImageUrl: '',
      backgroundImageUrl: '',
      introduction: '새벽엔 조용한 노래'));

  @override
  Future<Result<void>> updateIntroduction(
      String uid, String introduction) async {
    saved = introduction;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);

  testWidgets('지금 소개를 채워서 열고, 저장하면 앞뒤 공백을 지워 저장한 뒤 닫는다', (tester) async {
    final profiles = _FakeProfiles();
    Get.put(ProfileController(profiles, 'me'));
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => EditIntroductionDialog.show(context),
            child: const Text('OPEN'),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('소개 수정'), findsOneWidget);
    expect(find.text('새벽엔 조용한 노래'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  낮에는 재즈  ');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(profiles.saved, '낮에는 재즈');
    expect(find.text('소개 수정'), findsNothing);
  });

  testWidgets('취소하면 저장하지 않고 닫는다', (tester) async {
    final profiles = _FakeProfiles();
    Get.put(ProfileController(profiles, 'me'));
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => EditIntroductionDialog.show(context),
            child: const Text('OPEN'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(profiles.saved, isNull);
    expect(find.text('소개 수정'), findsNothing);
  });
}
