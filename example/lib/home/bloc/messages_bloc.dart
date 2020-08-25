import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../models.dart';
import 'home_bloc.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MyChatGroupProps extends ChatGroupProps {
  static const String collectionName = "chat_groups";
}

class MyChatGroup extends ChatGroup {
  final List<String> readBy;
  final List<String> userIds;

  MyChatGroup(
      {this.readBy,
      this.userIds,
      String id,
      String name,
      String lastMessage,
      DateTime created,
      String imageUrl,
      bool selected,
      bool archived,
      bool muted,
      bool pinned,
      bool read,
      String creatorId,
      DateTime updated})
      : super(
            read: read,
            creatorId: creatorId,
            updated: updated,
            pinned: pinned,
            muted: muted,
            archived: archived,
            // selected: selected,
            imageUrl: imageUrl,
            id: id,
            lastMessage: lastMessage,
            created: created,
            name: name);

  // bool isRead(String userId) {
  //   if (userId.compareTo(this.creatorId) == 0) {
  //     return true;
  //   }

  //   return readBy.contains(userId);
  // }
}

class ChatGroupsRepository {
  List<MyChatGroup> myChatList = List<MyChatGroup>();

  PublishSubject<List<ChatGroup>> chatList = PublishSubject<List<ChatGroup>>();

  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(String userId) {
    final ref = Firestore.instance
        .collection(MyChatGroupProps.collectionName)
        .where(ChatGroupProps.userIds, arrayContains: userId)
        .orderBy(ChatGroupProps.updated);

    return ref.snapshots();
  }

  PublishSubject<List<ChatGroup>> get(String userId) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(userId).listen((QuerySnapshot allGroups) {
      List<MyChatGroup> myChatGroups = allGroups.documents
          .map((DocumentSnapshot doc) => _buildChatGroupFrmDoc(userId, doc))
          .toList();

      List<ChatGroup> chatGroups =
          myChatGroups.map((MyChatGroup mcg) => mcg.copyWith()).toList();
      myChatList.addAll(myChatGroups);
      chatList.add(chatGroups);
    });

    return this.chatList;
  }

  bool isRead(String userId, String creatorId, List<String> readBy) {
    if (userId.compareTo(creatorId) == 0) {
      return true;
    }

    return readBy.contains(userId);
  }

  MyChatGroup _buildChatGroupFrmDoc(String userId, DocumentSnapshot doc) {
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
        imageUrl: getParam<String>(ChatGroupProps.imageUrl, data, ''),
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

class ChatGroupUpdateData {
  final String documentId;
  final Map<String, dynamic> mappedData;
  ChatGroupUpdateData(this.documentId, this.mappedData);
}

class ChatGroupScreenBloc
    extends Bloc<ChatGroupScreenEvent, ChatGroupScreenState> {
  final HomeBloc homeBloc;
  final ChatGroupsRepository chatGroupsRepository;
  StreamSubscription chatsSubscription;

  ChatGroupScreenBloc(this.chatGroupsRepository, this.homeBloc)
      : super(MessagesInitial());

  @override
  Future<void> close() {
    chatsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<ChatGroupScreenState> mapEventToState(
      ChatGroupScreenEvent event) async* {
    if (event is LoadChatGroups) {
      yield* _monitorChatGroups(event);
      return;
    }

    if (event is DeleteChatGroups) {
      _deleteChatGroups(event);
      return;
    }
    if (event is TogglePinned) {
      _togglePinned(event);
      yield state;
      return;
    }

    if (event is MarkUnread) {
      _markUnread(event);
      yield state;
      return;
    }

    if (event is MarkRead) {
      _markRead(event);
      yield state;
      return;
    }

    // if (event is MarkUnseen) {
    //   _markUnseen(event);
    // }

    if (event is ToggleMuted) {
      _toggleMuted(event);
      yield state;
      return;
    }

    if (event is ArchiveChatGroups) {
      _archiveChatGroups(event);
      yield state;
      return;
    }

    if (event is UnarchiveChatGroups) {
      _unarchiveChatGroups(event);
      yield state;
      return;
    }

    if (event is ChatGroupsLoaded) {
      try {
        yield LoadedChatGroups(chatGroups: event.chatGroups);
        return;
      } catch (e) {
        print(e);
        yield LoadError();
      }
    }
  }

  Stream<ChatGroupScreenState> _monitorChatGroups(LoadChatGroups event) async* {
    try {
      chatsSubscription?.cancel();
      chatsSubscription = chatGroupsRepository
          .get(event.userId)
          .listen((List<ChatGroup> chatGroups) {
        bool anyNotSeen = chatGroups.any((cg) => !cg.read);
        this.homeBloc.add(ChangeHomePageMessagesIcon(anyNotSeen));

        this.add(ChatGroupsLoaded(chatGroups: chatGroups));
      });

      return;
    } catch (e) {
      print(e);
      yield LoadError();
    }
  }

  void _deleteChatGroups(DeleteChatGroups event) {
    WriteBatch fsBatch = Firestore.instance.batch();

    for (var chatGroup in event.chatGroups) {
      CollectionReference collectionRef =
          Firestore.instance.collection(MyChatGroupProps.collectionName);
      String documentId = chatGroup.id;
      DocumentReference document = collectionRef.document(documentId);
      fsBatch.delete(document);
    }

    fsBatch.commit();
  }

  void _markRead(MarkRead event) {
    List<ChatGroupUpdateData> allUpdateData = new List<ChatGroupUpdateData>();
    for (var chatGroup in event.chatGroups) {
      MyChatGroup myChatGroup = chatGroupsRepository.myChatList
          .firstWhere((cg) => cg.id == chatGroup.id);

      List<String> readBy = [...myChatGroup.readBy];
      if (readBy.contains(event.userId)) {
        return;
      }
      readBy.add(event.userId);

      ChatGroupUpdateData chatGroupUpdateData = new ChatGroupUpdateData(
          chatGroup.id, {ChatGroupProps.readBy: readBy});

      allUpdateData.add(chatGroupUpdateData);
    }

    this.chatGroupsRepository.updateChatGroups(allUpdateData);
  }

  void _markUnread(MarkUnread event) {
    List<ChatGroupUpdateData> allUpdateData = new List<ChatGroupUpdateData>();
    for (var chatGroup in event.chatGroups) {
      MyChatGroup myChatGroup = chatGroupsRepository.myChatList
          .firstWhere((cg) => cg.id == chatGroup.id);

      List<String> readBy = [...myChatGroup.readBy];
      readBy.removeWhere((String id) => id.compareTo(event.userId) == 0);

      ChatGroupUpdateData chatGroupUpdateData = new ChatGroupUpdateData(
          chatGroup.id, {ChatGroupProps.readBy: readBy});

      allUpdateData.add(chatGroupUpdateData);
    }

    this.chatGroupsRepository.updateChatGroups(allUpdateData);
  }

  void _togglePinned(TogglePinned event) {
    List<ChatGroupUpdateData> allUpdateData = new List<ChatGroupUpdateData>();
    for (var chatGroup in event.chatGroups) {
      ChatGroupUpdateData chatGroupUpdateData = new ChatGroupUpdateData(
          chatGroup.id, {ChatGroupProps.pinned: chatGroup.pinned});

      allUpdateData.add(chatGroupUpdateData);
    }

    this.chatGroupsRepository.updateChatGroups(allUpdateData);
  }

  void _toggleMuted(ToggleMuted event) {
    List<ChatGroupUpdateData> allUpdateData = new List<ChatGroupUpdateData>();
    for (var chatGroup in event.chatGroups) {
      ChatGroupUpdateData chatGroupUpdateData = new ChatGroupUpdateData(
          chatGroup.id, {ChatGroupProps.muted: chatGroup.muted});

      allUpdateData.add(chatGroupUpdateData);
    }

    this.chatGroupsRepository.updateChatGroups(allUpdateData);
  }

  void _archiveChatGroups(ArchiveChatGroups event) {
    List<ChatGroupUpdateData> allUpdateData = new List<ChatGroupUpdateData>();
    for (var chatGroup in event.chatGroups) {
      ChatGroupUpdateData chatGroupUpdateData = new ChatGroupUpdateData(
          chatGroup.id, {ChatGroupProps.archived: true});

      allUpdateData.add(chatGroupUpdateData);
    }

    this.chatGroupsRepository.updateChatGroups(allUpdateData);
  }

  void _unarchiveChatGroups(UnarchiveChatGroups event) {
    List<ChatGroupUpdateData> allUpdateData = new List<ChatGroupUpdateData>();
    for (var chatGroup in event.chatGroups) {
      ChatGroupUpdateData chatGroupUpdateData = new ChatGroupUpdateData(
          chatGroup.id, {ChatGroupProps.archived: false});

      allUpdateData.add(chatGroupUpdateData);
    }

    this.chatGroupsRepository.updateChatGroups(allUpdateData);
  }
}
