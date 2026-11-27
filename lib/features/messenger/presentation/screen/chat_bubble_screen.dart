import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// 2026-11-27 → "2026년 11월 27일 금요일" (intl 한국어 데이터를 초기화하지 않아서 직접 만든다)
String formatChatDate(DateTime d) =>
    '${d.year}년 ${d.month}월 ${d.day}일 ${_weekdays[d.weekday - 1]}요일';

/// 21:05 → "오후 9:05", 00:30 → "오전 12:30"
String formatChatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${d.hour < 12 ? '오전' : '오후'} $hour:${d.minute.toString().padLeft(2, '0')}';
}

/// 채팅방: 머리말(방 이름 · 인원) · 날짜별 메시지 · 입력창
class ChatBubbleScreen extends StatefulWidget {
  const ChatBubbleScreen({required this.room, super.key});

  final ChatRoom room;

  @override
  State<ChatBubbleScreen> createState() => _ChatBubbleScreenState();
}

class _ChatBubbleScreenState extends State<ChatBubbleScreen> {
  final _input = TextEditingController();
  var _sending = false;

  MessengerController get _messenger => Get.find<MessengerController>();

  // 메시지 스트림을 build마다 새로 만들지 않도록 한 번만 만든다.
  late final Stream<List<ChatMessage>> _messages =
      _messenger.watchMessages(widget.room.id);

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    final result = await _messenger.send(widget.room.id, text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (result case Failed(:final failure)) {
      showErrorSnackBar(context, failure.message);
      return;
    }
    _input.clear();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _Header(room: widget.room),
                  Expanded(
                    child: StreamBuilder<List<ChatMessage>>(
                      stream: _messages,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const _Notice(
                            icon: Icons.error_outline_rounded,
                            title: '메시지를 불러오지 못했어요.',
                            body: '잠시 후 다시 열어 주세요.',
                          );
                        }
                        final messages = snapshot.data;
                        if (messages == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (messages.isEmpty) {
                          return const _Notice(
                            icon: Icons.waving_hand_outlined,
                            title: '아직 나눈 이야기가 없어요.',
                            body: '첫 메시지를 보내 대화를 시작해 보세요.',
                          );
                        }
                        return _MessageList(
                          messages: messages,
                          isMine: _messenger.isMine,
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _input,
                    builder: (context, value, _) => _Composer(
                      controller: _input,
                      canSend: value.text.trim().isNotEmpty && !_sending,
                      onSend: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: '뒤로 가기',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: c.textPrimary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name.isEmpty ? '이름 없는 채팅방' : room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleMedium?.copyWith(fontSize: 16),
                ),
                Text(
                  '${room.memberUids.length}명 · ${room.memberDisplayNames.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(color: c.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 최신 메시지가 아래에 오도록 뒤집어서 그린다. ([messages]는 최신순)
///
/// 같은 사람이 같은 날 이어서 보낸 메시지는 한 묶음으로 보고,
/// 이름과 앨범은 묶음의 첫 메시지에, 시각은 같은 분의 마지막 메시지에만 붙인다.
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isMine,
  });

  final List<ChatMessage> messages;
  final bool Function(ChatMessage) isMine;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _sameMinute(DateTime a, DateTime b) =>
      _sameDay(a, b) && a.hour == b.hour && a.minute == b.minute;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final older = index + 1 < messages.length ? messages[index + 1] : null;
        final newer = index > 0 ? messages[index - 1] : null;

        final newDay = older == null || !_sameDay(older.sentAt, message.sentAt);
        final startsGroup = newDay || older.senderUid != message.senderUid;
        final showTime = newer == null ||
            newer.senderUid != message.senderUid ||
            !_sameMinute(newer.sentAt, message.sentAt);

        return Column(
          key: ValueKey(message.id),
          children: [
            if (newDay) _DateDivider(message.sentAt),
            Padding(
              padding: EdgeInsets.only(top: startsGroup && !newDay ? 14 : 4),
              child: _MessageRow(
                message: message,
                mine: isMine(message),
                startsGroup: startsGroup,
                showTime: showTime,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: c.surfaceMuted, borderRadius: AppRadius.borderFull),
          child: Text(
            formatChatDate(date),
            style: context.textStyles.labelMedium
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// 메시지 한 줄. 상대 메시지는 왼쪽에 그 사람의 인생곡 앨범을 둔다. (개인 사진은 쓰지 않는다)
class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.mine,
    required this.startsGroup,
    required this.showTime,
  });

  static const _avatar = 36.0;

  final ChatMessage message;
  final bool mine;
  final bool startsGroup;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textStyles;
    final time = Text(
      formatChatTime(message.sentAt),
      style: t.labelSmall?.copyWith(
          fontSize: 10, fontWeight: FontWeight.w400, color: c.textTertiary),
    );
    final bubble = Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? c.accent : c.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(!mine && startsGroup ? 6 : AppRadius.l),
            topRight: Radius.circular(mine && startsGroup ? 6 : AppRadius.l),
            bottomLeft: const Radius.circular(AppRadius.l),
            bottomRight: const Radius.circular(AppRadius.l),
          ),
        ),
        child: SelectableText(
          message.text,
          style: t.bodyMedium?.copyWith(
            height: 1.45,
            color: mine ? Colors.white : c.textPrimary,
          ),
        ),
      ),
    );
    // 말풍선 폭은 화면의 72%까지. 남는 쪽에 시각을 둔다.
    final maxBubble = MediaQuery.sizeOf(context).width * 0.72;

    if (mine) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showTime) ...[time, const SizedBox(width: 6)],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubble),
            child: Row(mainAxisSize: MainAxisSize.min, children: [bubble]),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _avatar,
          child: startsGroup
              ? _SenderAlbum(
                  key: ValueKey(message.senderUid),
                  uid: message.senderUid,
                  size: _avatar)
              : null,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (startsGroup)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(message.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600, color: c.textSecondary)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubble - 44),
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: [bubble]),
                  ),
                  if (showTime) ...[const SizedBox(width: 6), time],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 보낸 사람의 인생곡 앨범. 프로필 스트림은 위젯마다 한 번만 만든다.
class _SenderAlbum extends StatefulWidget {
  const _SenderAlbum({super.key, required this.uid, required this.size});

  final String uid;
  final double size;

  @override
  State<_SenderAlbum> createState() => _SenderAlbumState();
}

class _SenderAlbumState extends State<_SenderAlbum> {
  late final Stream<UserProfile?> _profile =
      Get.find<MessengerController>().watchSender(widget.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _profile,
      builder: (context, snapshot) => AlbumArt(
        image: networkImageOrNull(snapshot.data?.track?.imageUrl),
        size: widget.size,
        radius: AppRadius.s,
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (canSend) onSend();
              },
              style: context.textStyles.bodyMedium?.copyWith(height: 1.4),
              decoration: InputDecoration(
                hintText: '메시지 보내기',
                hintStyle: context.textStyles.bodyMedium
                    ?.copyWith(color: c.textTertiary),
                filled: true,
                fillColor: c.surface,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: const OutlineInputBorder(
                    borderRadius: AppRadius.borderXxl,
                    borderSide: BorderSide.none),
                enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.borderXxl,
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderXxl,
                    borderSide: BorderSide(color: c.accent, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton.filled(
            tooltip: '보내기',
            onPressed: canSend ? onSend : null,
            style: IconButton.styleFrom(
              backgroundColor: c.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: c.surfaceMuted,
              disabledForegroundColor: c.textTertiary,
              fixedSize: const Size(46, 46),
            ),
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: context.colors.textTertiary),
            const SizedBox(height: AppSpacing.s),
            Text(title, style: context.textStyles.titleMedium),
            const SizedBox(height: 2),
            Text(body,
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
