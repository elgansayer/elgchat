import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:rxdart/rxdart.dart';
import '../../models.dart';
import 'chat_room_bloc.dart';

class ChatRoomsRepository {
  List<ElgChatRoom> chatRoomList = List<ElgChatRoom>();
  List<UserChatRoomInfo> myChatList = List<UserChatRoomInfo>();
  PublishSubject<List<ElgChatRoom>> chatList =
      PublishSubject<List<ElgChatRoom>>();
  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(String userId) {
    final ref = Firestore.instance
        .collection(
            "${UsersProps.collectionName}/$userId/${UserChatRoomInfoProps.collectionName}")
        // .where(ChatRoomProps.userIds, arrayContains: userId)
        .orderBy(ChatRoomProps.updated);

    return ref.snapshots();
  }

  PublishSubject<List<ElgChatRoom>> get(String userId) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(userId).listen((QuerySnapshot allRooms) {
      List<UserChatRoomInfo> myChatRooms = allRooms.documents
          .map((DocumentSnapshot doc) => _buildChatRoomFromDoc(userId, doc))
          .toList();

      List<ElgChatRoom> chatRooms =
          myChatRooms.map((UserChatRoomInfo mcg) => mcg.copyWith()).toList();

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

  UserChatRoomInfo _buildChatRoomFromDoc(String userId, DocumentSnapshot doc) {
    Map data = doc.data;

    // List<String> readBy = getStrListParam<List<String>>(
    //     ChatRoomProps.readBy, data, new List<String>());

    String creatorId = getParam<String>(ChatRoomProps.creatorId, data, '');
    // bool read = isRead(userId, creatorId, readBy);

    return UserChatRoomInfo(
      // id: doc.documentID,
      id: getParam<String>(UserChatRoomInfoProps.roomId, data, "-1"),
      roomId: getParam<String>(UserChatRoomInfoProps.roomId, data, "-1"),
      muted: getParam<bool>(ChatRoomProps.muted, data, false),
      pinned: getParam<bool>(ChatRoomProps.pinned, data, false),
      archived: getParam<bool>(ChatRoomProps.archived, data, false),
      selected: false,
      photoUrl: getParam<String>(UserChatRoomInfoProps.roomPhotoUrl, data, ''),
      lastMessage: getParam<String>(ChatRoomProps.lastMessage, data, ''),
      created: getTimeFromMap(ChatRoomProps.created, data),
      name: getParam<String>(UserChatRoomInfoProps.roomName, data, ''),
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

    for (ChatRoomUpdateData updateData in allUpdateData) {
      //TODO: Should be user/docid:/collectionName
      var str =
          "users/${updateData.documentId}/${UserChatRoomInfoProps.collectionName}";
//UserChatRoomInfoProps.collectionName
      CollectionReference collectionRef =
          Firestore.instance.collection(str);

      fsBatch.setData(
          collectionRef.document(updateData.documentId), updateData.mappedData);
    }

    fsBatch.commit();
  }

  void setChatRoomsData(List<ChatRoomUpdateData> allUpdateData,
      {bool marge: false}) {
    //Create a batch
    WriteBatch fsBatch = Firestore.instance.batch();

    CollectionReference collectionRef =
        Firestore.instance.collection(UserChatRoomInfoProps.collectionName);

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
