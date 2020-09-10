import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'chat_groups_repository.dart';
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
      String photoUrl,
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
            photoUrl: photoUrl,
            id: id,
            lastMessage: lastMessage,
            created: created,
            name: name);

  Map<String, dynamic> toMap() {
    return {
      ChatGroupProps.id: this.id,
      ChatGroupProps.name: this.name,
      ChatGroupProps.photoUrl: this.photoUrl,
      ChatGroupProps.lastMessage: this.lastMessage,
      ChatGroupProps.created: this.created,
      ChatGroupProps.updated: this.updated,
      ChatGroupProps.readBy: this.readBy,
      ChatGroupProps.userIds: this.userIds,
      ChatGroupProps.creatorId: this.creatorId,
      ChatGroupProps.archived: this.archived,
      ChatGroupProps.muted: this.muted,
      ChatGroupProps.pinned: this.pinned,
    };
  }

  // bool isRead(String userId) {
  //   if (userId.compareTo(this.creatorId) == 0) {
  //     return true;
  //   }

  //   return readBy.contains(userId);
  // }
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

    if (event is CreateNewChat) {
      yield* _openNewChat(event);
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

  Stream<ChatGroupScreenState> _openNewChat(CreateNewChat event) async* {
    List<ChatGroup> chatList = this.chatGroupsRepository.chatGroupList;
    List<MyChatGroup> myChatList = this.chatGroupsRepository.myChatList;

    String contactToId = event.userTo.id;
    String userIdThisApp = event.userThisApp.id;

    // Ignore group chats
    MyChatGroup foundChatGroup = myChatList.firstWhere(
        (cg) => cg.userIds.contains(contactToId) && cg.userIds.length == 2,
        orElse: () => null);

    if (foundChatGroup == null) {
      ChatGroup newChatGroup = ChatGroup(
          id: '-1',
          name: event.userTo.username,
          lastMessage: '',
          created: DateTime.now(),
          photoUrl: event.userTo.photoUrl,
          creatorId: contactToId,
          updated: DateTime.now());

      yield OpenChatState(
          chatGroup: newChatGroup,
          userThisApp: event.userThisApp,
          userTo: event.userTo);
    } else {
      final chatGroup = chatList.firstWhere((cg) => cg.id == foundChatGroup.id);
      _markRead(MarkRead(chatGroups: [chatGroup], userId: userIdThisApp));

      yield OpenChatState(
          chatGroup: chatGroup,
          userThisApp: event.userThisApp,
          userTo: event.userTo);
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

    for (ChatGroup chatGroup in event.chatGroups) {
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
