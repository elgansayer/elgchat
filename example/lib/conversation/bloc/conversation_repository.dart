import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:rxdart/rxdart.dart';
import '../../models.dart';

abstract class MyChatMessageProps extends ChatMessageProps {
  static const String collectionName = "chat_messages";
  static const String groupIds = "groupIds";
}

class  ConversationRepository {
  // List<MyChatMessage> myChatList = List<MyChatMessage>();
  PublishSubject<List<ChatMessage>> chatList =
      PublishSubject<List<ChatMessage>>();
  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(String groupId) {
    final ref = Firestore.instance
        .collection(MyChatMessageProps.collectionName)
        .where(MyChatMessageProps.groupIds, arrayContains: groupId)
        .orderBy(ChatMessageProps.created);

    return ref.snapshots();
  }

  PublishSubject<List<ChatMessage>> get(String userId) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(userId).listen((QuerySnapshot allGroups) {
      List<ChatMessage> myConversation = allGroups.documents
          .map((DocumentSnapshot doc) => _buildChatMessageFromDoc(userId, doc))
          .toList();

      List<ChatMessage> conversation =
          myConversation.map((ChatMessage mcg) => mcg.copyWith()).toList();

      chatList.add(conversation);
    });

    return this.chatList;
  }

  ChatMessage _buildChatMessageFromDoc(String userId, DocumentSnapshot doc) {
    Map data = doc.data;

    return ChatMessage(
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
