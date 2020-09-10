import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:rxdart/rxdart.dart';
import '../../models.dart';
import 'messages_bloc.dart';

class ChatGroupsRepository {
  List<ChatGroup> chatGroupList = List<ChatGroup>();
  List<MyChatGroup> myChatList = List<MyChatGroup>();
  PublishSubject<List<ChatGroup>> chatList = PublishSubject<List<ChatGroup>>();
  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(String userId) {
    final ref = Firestore.instance
        .collection(
            "${UsersProps.collectionName}/$userId/${MyChatGroupProps.collectionName}")
        // .where(ChatGroupProps.userIds, arrayContains: userId)
        .orderBy(ChatGroupProps.updated);

    return ref.snapshots();
  }

  PublishSubject<List<ChatGroup>> get(String userId) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(userId).listen((QuerySnapshot allGroups) {
      List<MyChatGroup> myChatGroups = allGroups.documents
          .map((DocumentSnapshot doc) => _buildChatGroupFromDoc(userId, doc))
          .toList();

      List<ChatGroup> chatGroups =
          myChatGroups.map((MyChatGroup mcg) => mcg.copyWith()).toList();

      myChatList.addAll(myChatGroups);
      this.chatGroupList.addAll(chatGroups);
      chatList.add(chatGroups);

      // myChatList.forEach((element) {
      //   final colRef =
      //       Firestore.instance.collection(MyChatGroupProps.collectionName);
      //   // .document().documentID;
      //   var docId = colRef.document().documentID;
      //   colRef.document(docId).setData(element.toMap());
      // });
    });

    return this.chatList;
  }

  bool isRead(String userId, String creatorId, List<String> readBy) {
    if (userId.compareTo(creatorId) == 0) {
      return true;
    }

    return readBy.contains(userId);
  }

  MyChatGroup _buildChatGroupFromDoc(String userId, DocumentSnapshot doc) {
    Map data = doc.data;

    List<String> readBy = getStrListParam<List<String>>(
        ChatGroupProps.readBy, data, new List<String>());

    String creatorId = getParam<String>(ChatGroupProps.creatorId, data, '');
    bool read = isRead(userId, creatorId, readBy);

    return MyChatGroup(
        id: doc.documentID,
        muted: getParam<bool>(ChatGroupProps.muted, data, false),
        pinned: getParam<bool>(ChatGroupProps.pinned, data, false),
        archived: getParam<bool>(ChatGroupProps.archived, data, false),
        selected: false,
        photoUrl: getParam<String>(ChatGroupProps.photoUrl, data, ''),
        lastMessage: getParam<String>(ChatGroupProps.lastMessage, data, ''),
        created: getTimeFromMap(ChatGroupProps.created, data),
        name: getParam<String>(ChatGroupProps.name, data, ''),
        creatorId: creatorId,
        updated: getTimeFromMap(ChatGroupProps.updated, data),
        read: read,
        userIds: getStrListParam<List<String>>(
            ChatGroupProps.userIds, data, new List<String>()),
        readBy: readBy);
  }

  void updateChatGroups(List<ChatGroupUpdateData> allUpdateData) {
    //Create a batch
    WriteBatch fsBatch = Firestore.instance.batch();

    CollectionReference collectionRef =
        Firestore.instance.collection(MyChatGroupProps.collectionName);

    for (ChatGroupUpdateData updateData in allUpdateData) {
      fsBatch.updateData(
          collectionRef.document(updateData.documentId), updateData.mappedData);
    }

    fsBatch.commit();
  }

  void setChatGroupsData(List<ChatGroupUpdateData> allUpdateData,
      {bool marge: false}) {
    //Create a batch
    WriteBatch fsBatch = Firestore.instance.batch();

    CollectionReference collectionRef =
        Firestore.instance.collection(MyChatGroupProps.collectionName);

    for (ChatGroupUpdateData updateData in allUpdateData) {
      fsBatch.setData(
          collectionRef.document(updateData.documentId), updateData.mappedData,
          merge: marge);
    }

    fsBatch.commit();
  }

  void close() {
    _firebaseSubscription?.cancel();
  }
}
