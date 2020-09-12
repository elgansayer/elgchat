import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:rxdart/rxdart.dart';
import '../../models.dart';
import 'chat_room_bloc.dart';

class ChatRoomsRepository {
  List<ChatRoom> chatRoomList = List<ChatRoom>();
  List<MyChatRoom> myChatList = List<MyChatRoom>();
  PublishSubject<List<ChatRoom>> chatList = PublishSubject<List<ChatRoom>>();
  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(String userId) {
    final ref = Firestore.instance
        .collection(
            "${UsersProps.collectionName}/$userId/${MyChatRoomProps.collectionName}")
        // .where(ChatRoomProps.userIds, arrayContains: userId)
        .orderBy(ChatRoomProps.updated);

    return ref.snapshots();
  }

  PublishSubject<List<ChatRoom>> get(String userId) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(userId).listen((QuerySnapshot allRooms) {
      List<MyChatRoom> myChatRooms = allRooms.documents
          .map((DocumentSnapshot doc) => _buildChatRoomFromDoc(userId, doc))
          .toList();

      List<ChatRoom> chatRooms =
          myChatRooms.map((MyChatRoom mcg) => mcg.copyWith()).toList();

      myChatList.addAll(myChatRooms);
      this.chatRoomList.addAll(chatRooms);
      chatList.add(chatRooms);

      // myChatList.forEach((element) {
      //   final colRef =
      //       Firestore.instance.collection(MyChatRoomProps.collectionName);
      //   // .document().documentID;
      //   var docId = colRef.document().documentID;
      //   colRef.document(docId).setData(element.toMap());
      // });
    });

    return this.chatList;
  }

  // bool isRead(String userId, String creatorId, List<String> readBy) {
  //   if (userId.compareTo(creatorId) == 0) {
  //     return true;
  //   }

  //   return readBy.contains(userId);
  // }

  MyChatRoom _buildChatRoomFromDoc(String userId, DocumentSnapshot doc) {
    Map data = doc.data;

    // List<String> readBy = getStrListParam<List<String>>(
    //     ChatRoomProps.readBy, data, new List<String>());

    String creatorId = getParam<String>(ChatRoomProps.creatorId, data, '');
    // bool read = isRead(userId, creatorId, readBy);

    return MyChatRoom(
      id: doc.documentID,
      muted: getParam<bool>(ChatRoomProps.muted, data, false),
      pinned: getParam<bool>(ChatRoomProps.pinned, data, false),
      archived: getParam<bool>(ChatRoomProps.archived, data, false),
      selected: false,
      photoUrl: getParam<String>(ChatRoomProps.photoUrl, data, ''),
      lastMessage: getParam<String>(ChatRoomProps.lastMessage, data, ''),
      created: getTimeFromMap(ChatRoomProps.created, data),
      name: getParam<String>(ChatRoomProps.name, data, ''),
      creatorId: creatorId,
      updated: getTimeFromMap(ChatRoomProps.updated, data),
      // read: read,
      read: getParam<bool>(ChatRoomProps.read, data, false),
      receiverIds: getStrListParam<List<String>>(
          ChatRoomProps.receiverIds, data, new List<String>()),
      // readBy: readBy
    );
  }

  void updateChatRooms(List<ChatRoomUpdateData> allUpdateData) {
    //Create a batch
    WriteBatch fsBatch = Firestore.instance.batch();

    CollectionReference collectionRef =
        Firestore.instance.collection(MyChatRoomProps.collectionName);

    for (ChatRoomUpdateData updateData in allUpdateData) {
      fsBatch.updateData(
          collectionRef.document(updateData.documentId), updateData.mappedData);
    }

    fsBatch.commit();
  }

  void setChatRoomsData(List<ChatRoomUpdateData> allUpdateData,
      {bool marge: false}) {
    //Create a batch
    WriteBatch fsBatch = Firestore.instance.batch();

    CollectionReference collectionRef =
        Firestore.instance.collection(MyChatRoomProps.collectionName);

    for (ChatRoomUpdateData updateData in allUpdateData) {
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
