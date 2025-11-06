import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/chat_repository.dart';
import 'chat_state.dart';
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  // bool _isInChat = false;
  // StreamSubscription? _messageSubscription;
  // StreamSubscription? _onlineStatusSubscription;
  // StreamSubscription? _typingSubscription;
  // StreamSubscription? _blockStatusSubscription;
  // StreamSubscription? _amIBlockStatusSubscription;
  // Timer? typingTimer;

  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  })  : _chatRepository = chatRepository,
        super(const ChatState());

  void enterChat(String receiverId) async {
    // _isInChat = true;
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final chatRoom =
      await _chatRepository.getOrCreateChatRoom(currentUserId, receiverId);
      emit(state.copyWith(
        chatRoomId: chatRoom.id,
        receiverId: receiverId,
        status: ChatStatus.loaded,
      ));

      // //subscribe to all updates
      // _subscribeToMessages(chatRoom.id);
      // _subscribeToOnlineStatus(receiverId);
      // _subscribeToTypingStatus(chatRoom.id);
      // _subscribeToBlockStatus(receiverId);
      //
      // await _chatRepository.updateOnlineStatus(currentUserId, true);
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.error, error: "Failed to create chat room $e"));
    }
  }
  Future<void> sendMessage(
      {required String content, required String receiverId}) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.sendMessage(
        chatRoomId: state.chatRoomId!,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(error: "Failed to send message"));
    }
  }
  }
