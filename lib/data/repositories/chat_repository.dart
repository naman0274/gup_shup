import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gup_shup/data/models/chat_message.dart';
import 'package:gup_shup/data/services/base_repository.dart';

import '../models/chat_room_model.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection("chatRooms");

  CollectionReference getChatRoomMessages(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).collection("messages");
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    // Prevent creating a chat room with yourself
    if (currentUserId == otherUserId) {
      throw Exception("Cannot create a chat room with yourself");
    }

    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join("_");

    final roomDoc = await _chatRooms.doc(roomId).get();

    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }

    final currentUserData =
        (await firestore.collection("users").doc(currentUserId).get()).data()
            as Map<String, dynamic>;
    final otherUserData =
        (await firestore.collection("users").doc(otherUserId).get()).data()
            as Map<String, dynamic>;
    final participantsName = {
      currentUserId: currentUserData['fullName']?.toString() ?? "",
      otherUserId: otherUserData['fullName']?.toString() ?? "",
    };

    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantsName: participantsName,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
      typingUserId: '',
    );

    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    // batch
    final batch = firestore.batch();

    //   message sub collection
    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = messageRef.doc();
    //   chat message

    final message = ChatMessage(
      id: messageDoc.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
    );
    //   add message to sub collection

    batch.set(messageDoc, message.toMap());

    //   update chatroom

    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage": content,
      "lastMessageSenderId": senderId,
      "lastMessageTime": message.timestamp,
    });
    await batch.commit();
  }

  Stream<List<ChatMessage>> getMessages(
    String chatRoomId, {
    DocumentSnapshot? lastDocument,
  }) {
    var query = getChatRoomMessages(
      chatRoomId,
    ).orderBy('timestamp', descending: true).limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList(),
    );
  }

  Future<List<ChatMessage>> getMoreMessages(
    String chatRoomId, {
    required DocumentSnapshot lastDocument,
  }) async {
    final query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);
    print("comingg");
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _chatRooms
        .where("participants", arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatRoomModel.fromFirestore(doc))
        .toList());
  }

  Stream<int> getUnreadCount(String chatRoomId, String userId) {
    return getChatRoomMessages(chatRoomId)
        .where("receiverId", isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final batch = firestore.batch();

      //get all unread messages where user is receviver

      final unreadMessages = await getChatRoomMessages(chatRoomId)
          .where(
        "receiverId",
        isEqualTo: userId,
      )
          .where('status', isEqualTo: MessageStatus.sent.toString())
          .get();
      print("found ${unreadMessages.docs.length} unread messages");

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
          'status': MessageStatus.read.toString(),
        });

        await batch.commit();

        print("Marked messaegs as read for user $userId");
      }
    } catch (e) {}
  }
}
