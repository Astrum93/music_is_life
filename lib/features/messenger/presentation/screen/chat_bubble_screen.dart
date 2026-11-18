import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/presentation/chat_widget/chat_bubble_widget.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';

/// 채팅방
class ChatBubbleScreen extends StatefulWidget {
  const ChatBubbleScreen({required this.room, super.key});

  final ChatRoom room;

  @override
  State<ChatBubbleScreen> createState() => _ChatBubbleScreenState();
}

class _ChatBubbleScreenState extends State<ChatBubbleScreen> {
  var _userMessage = '';
  final _controller = TextEditingController();

  MessengerController get _messenger => Get.find<MessengerController>();

  // 메시지 스트림을 build마다 새로 만들지 않도록 한 번만 만든다.
  late final Stream<List<ChatMessage>> _messages =
      _messenger.watchMessages(widget.room.id);

  Future<void> _send() async {
    final result = await _messenger.send(widget.room.id, _userMessage);
    if (!mounted) return;
    if (result case Failed(:final failure)) {
      showErrorSnackBar(context, failure.message);
      return;
    }
    setState(() => _userMessage = '');
    _controller.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatName = widget.room.name;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(chatName),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _messages,
                  builder: (context, snapshot) {
                    /// error가 발생한 경우
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    /// connectionState가 waiting인 경우
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    /// snapshot에 데이터가 없는 경우
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text('작성된 메세지가 없습니다.'),
                      );
                    }

                    final messagesDocs = snapshot.data!;
                    return ListView.builder(
                      itemCount: messagesDocs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        /// 각 메세지 문서
                        var message = messagesDocs[index];

                        // DateTime을 포맷팅
                        String formattedDateTime =
                            DateFormat.Hm().format(message.sentAt).toString();
                        return Column(
                          children: [
                            ChatBubbleWidget(
                              message.text,
                              _messenger.isMine(message),
                              message.senderUid,
                              message.senderName,
                              formattedDateTime,
                            ),
                            height10,
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      cursorColor: Colors.grey,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber)),
                        hintText: '메세지를 입력 해주세요.',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        contentPadding: EdgeInsets.all(4),
                      ),
                      onSubmitted: (_) {
                        if (_userMessage.trim().isNotEmpty) _send();
                      },
                      onChanged: (value) {
                        setState(() {
                          _userMessage = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _userMessage.trim().isEmpty ? null : _send,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
