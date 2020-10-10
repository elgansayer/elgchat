import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:rxdart/rxdart.dart';
import '../../models.dart';

abstract class MyChatMessageProps extends ChatMessageProps {
  static const String collectionName = "chat_messages";
  static const String roomId = "roomId";
}

class ConversationRepository {
  // List<MyChatMessage> myChatList = List<MyChatMessage>();
  PublishSubject<List<ElgChatMessage>> chatList =
      PublishSubject<List<ElgChatMessage>>();
  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(String roomId) {
    final ref = Firestore.instance
        .collection(MyChatMessageProps.collectionName)
        .where(MyChatMessageProps.roomId, isEqualTo: roomId)
        .orderBy(ChatMessageProps.created);

    return ref.snapshots();
  }

  PublishSubject<List<ElgChatMessage>> get(String userId) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(userId).listen((QuerySnapshot allRooms) {
      List<ElgChatMessage> myConversation = allRooms.documents
          .map((DocumentSnapshot doc) => _buildChatMessageFromDoc(userId, doc))
          .toList();

      List<ElgChatMessage> conversation =
          myConversation.map((ElgChatMessage mcg) => mcg.copyWith()).toList();

      chatList.add(conversation);
    });

    return this.chatList;
  }

  ElgChatMessage _buildChatMessageFromDoc(String userId, DocumentSnapshot doc) {
    Map data = doc.data;

    return ElgChatMessage(
      id: doc.documentID,
      reactions: getStrListParam<List<String>>(
          ChatMessageProps.reactions, data, new List<String>()),
      starred: getParam<bool>(ChatMessageProps.starred, data, false),
      deleted: getParam<bool>(ChatMessageProps.deleted, data, false),
      mediaUrls: getStrListParam<List<String>>(
          ChatMessageProps.mediaUrls, data, new List<String>()),
      message: getParam<String>(
          ChatMessageProps.message, data, 'Unable to download message'),
      created: getTimeFromMap(ChatMessageProps.created, data),
      senderId: getParam<String>(ChatMessageProps.message, data, ''),
    );
  }

  void close() {
    _firebaseSubscription?.cancel();
  }
}
