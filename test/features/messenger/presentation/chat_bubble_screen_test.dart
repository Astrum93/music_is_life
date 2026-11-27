import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/messenger/presentation/screen/chat_bubble_screen.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

class _FakeMessengerRepository implements MessengerRepository {
  final messages = StreamController<List<ChatMessage>>.broadcast();
  final sent = <String>[];
  Result<void> sendResult = const Success(null);

  @override
  Stream<List<ChatRoom>> watchRooms(String uid) => const Stream.empty();

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId) => messages.stream;

  @override
  Future<Result<void>> sendMessage(
      {required String roomId,
      required String senderUid,
      required String senderName,
      required String text}) async {
    sent.add(text);
    return sendResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoProfiles implements ProfileRepository {
  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _room = ChatRoom(
  id: 'r1',
  name: '새벽 드라이브',
  memberUids: ['me', 'you'],
  memberNames: {'me': '나', 'you': '너'},
);

ChatMessage _msg(String id, String sender, String text, DateTime at) =>
    ChatMessage(
        id: id,
        senderUid: sender,
        senderName: sender == 'me' ? '나' : '너',
        text: text,
        sentAt: at);

Future<_FakeMessengerRepository> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _FakeMessengerRepository();
  Get.put(
      MessengerController(repository, _NoProfiles(), uid: 'me', userName: '나'));
  await tester
      .pumpWidget(const MaterialApp(home: ChatBubbleScreen(room: _room)));
  return repository;
}

void main() {
  tearDown(Get.reset);

  test('날짜와 시각은 한국어로 직접 만든다', () {
    expect(formatChatDate(DateTime(2026, 11, 27)), '2026년 11월 27일 금요일');
    expect(formatChatTime(DateTime(2026, 11, 27, 21, 5)), '오후 9:05');
    expect(formatChatTime(DateTime(2026, 11, 27, 0, 30)), '오전 12:30');
    expect(formatChatTime(DateTime(2026, 11, 27, 12, 0)), '오후 12:00');
  });

  testWidgets('머리말에 방 이름과 인원, 메시지가 없으면 안내를 보여준다', (tester) async {
    final repository = await _pump(tester);
    repository.messages.add([]);
    await tester.pump();

    expect(find.text('새벽 드라이브'), findsOneWidget);
    expect(find.text('2명 · 나, 너'), findsOneWidget);
    expect(find.text('아직 나눈 이야기가 없어요.'), findsOneWidget);
  });

  testWidgets('같은 사람의 연속 메시지는 이름 한 번, 같은 분의 시각 한 번, 날짜는 바뀔 때마다',
      (tester) async {
    final repository = await _pump(tester);
    // 최신순
    repository.messages.add([
      _msg('4', 'me', '나도 그 노래 좋아해', DateTime(2026, 11, 27, 21, 6)),
      _msg('3', 'you', '진짜 위로돼', DateTime(2026, 11, 27, 21, 5)),
      _msg('2', 'you', '이 노래 들어봤어?', DateTime(2026, 11, 27, 21, 5)),
      _msg('1', 'you', '어제 얘기', DateTime(2026, 11, 26, 23, 0)),
    ]);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('2026년 11월 26일 목요일'), findsOneWidget);
    expect(find.text('2026년 11월 27일 금요일'), findsOneWidget);
    // 상대 이름: 26일 묶음 1번, 27일 묶음 1번 (내 메시지에는 이름이 없다)
    expect(find.text('너'), findsNWidgets(2));
    expect(find.text('나'), findsNothing);
    // 21:05에 보낸 두 메시지는 시각을 한 번만
    expect(find.text('오후 9:05'), findsOneWidget);
    expect(find.text('오후 9:06'), findsOneWidget);
  });

  testWidgets('빈 입력은 보낼 수 없고, 보내면 입력창을 비운다', (tester) async {
    final repository = await _pump(tester);
    repository.messages.add([]);
    await tester.pump();

    final send = find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded);
    expect(tester.widget<IconButton>(send).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(tester.widget<IconButton>(send).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '안녕');
    await tester.pump();
    await tester.tap(send);
    await tester.pump();

    expect(repository.sent, ['안녕']);
    expect(find.text('안녕'), findsNothing);
  });

  testWidgets('보내기에 실패하면 입력한 글을 남겨 둔다', (tester) async {
    final repository = await _pump(tester);
    repository
      ..sendResult = const Failed(NetworkFailure())
      ..messages.add([]);
    await tester.pump();

    await tester.enterText(find.byType(TextField), '안녕');
    await tester.pump();
    await tester
        .tap(find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded));
    await tester.pump();

    expect(find.widgetWithText(TextField, '안녕'), findsOneWidget);
  });
}
