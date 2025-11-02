import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gup_shup/data/services/base_repository.dart';

import '../models/chat_room_model.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection("chatRooms");

  Future<ChatRoomModel> getOrCreateChatRoom(
      String currentUserId, String otherUserId) async {
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
        }, typingUserId: '');

    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }}
