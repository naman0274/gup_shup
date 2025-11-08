import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gup_shup/data/models/chat_message.dart';
import 'package:gup_shup/data/services/service_locator.dart';
import 'package:gup_shup/logic/cubits/chat/chat_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:gup_shup/logic/cubits/chat/chat_state.dart';
import 'package:intl/intl.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatMessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
late final ChatCubit _chatCubit;
  @override
  void initState() {
   _chatCubit = getIt<ChatCubit>();
   _chatCubit.enterChat(widget.receiverId);
    super.initState();
  }
  Future<void> _handleSendMessage() async {
    final messageText = messageController.text.trim();
    messageController.clear();
    await _chatCubit.sendMessage(
        content: messageText, receiverId: widget.receiverId);
  }

  @override
  void dispose() {
    messageController.dispose();
    // _scrollController.dispose();
    _chatCubit.leaveChat();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              child: Text(widget.receiverName[0].toUpperCase()),
            ),
            SizedBox(width: 20),
            Column(
              children: [
                Text(widget.receiverName),
                Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        bloc: _chatCubit,
        builder: (context, state) {
          if (state.status== ChatStatus.loading){
            return Center(child: CircularProgressIndicator());
          }
          if (state.status == ChatStatus.error){
            return Center(child: Text(state.error??"something went wrong"));
          }
          return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  final isMe = message.senderId == _chatCubit.currentUserId;                 return MessageBubble(
                    message:message,
                    isMe: isMe,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [Icon(Icons.emoji_emotions),
                      SizedBox(width: 8,),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: "Type a message",
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: _handleSendMessage,
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          );
        },
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  // final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    // required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 4,
          right: isMe ? 8 : 64,
          bottom: 4,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat('h:mm a').format(message.timestamp.toDate() ) ,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
             if (isMe)  Icon(
                  Icons.done_all,
                  size: 14,
                  color: message.status == MessageStatus.read
                      ? Colors.red
                      : Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
