import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:bloc/bloc.dart';
import 'package:elgchat_example/user_repository.dart';
import 'package:meta/meta.dart';
import '../../models.dart';
import 'chat_rooms_repository.dart';
import 'home_bloc.dart';

part 'chat_room_event.dart';
part 'chat_room_state.dart';

class UserChatRoomInfoProps extends ChatRoomProps {
  static const String collectionName = "room_info";
  static const String roomId = "roomId";
  static const String lastRead = "lastRead";
  static const String roomPhotoUrl = "roomPhotoUrl";
  static const String roomName = "roomName";
}

class UserChatRoomInfo extends ElgChatRoom {
  // final List<String> readBy;
  final List<String> receiverIds;
  final String roomId;
  final DateTime lastRead;

  UserChatRoomInfo(
      {
      // this.readBy,
      this.receiverIds,
      this.roomId,
      this.lastRead,
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
      ChatRoomProps.id: this.id,
      ChatRoomProps.name: this.name,
      ChatRoomProps.photoUrl: this.photoUrl,
      ChatRoomProps.lastMessage: this.lastMessage,
      ChatRoomProps.created: this.created,
      ChatRoomProps.updated: this.updated,
      // ChatRoomProps.readBy: this.readBy,
      // ChatRoomProps.read: this.read,
      ChatRoomProps.receiverIds: this.receiverIds,
      ChatRoomProps.creatorId: this.creatorId,
      ChatRoomProps.archived: this.archived,
      ChatRoomProps.muted: this.muted,
      ChatRoomProps.pinned: this.pinned,
    };
  }

  // bool isRead(String userId) {
  //   if (userId.compareTo(this.creatorId) == 0) {
  //     return true;
  //   }

  //   return readBy.contains(userId);
  // }
}

class ChatRoomUpdateData {
  final String documentId;
  final Map<String, dynamic> mappedData;
  ChatRoomUpdateData(this.documentId, this.mappedData);
}

class ChatRoomScreenBloc
    extends Bloc<ChatRoomScreenEvent, ChatRoomScreenState> {
  final HomeBloc homeBloc;
  final ChatRoomsRepository chatRoomsRepository;
  final UserRepository userRepository;

  StreamSubscription chatRoomsSubscription;

  ChatRoomScreenBloc(
      this.chatRoomsRepository, this.userRepository, this.homeBloc)
      : super(MessagesInitial());

  @override
  Future<void> close() {
    chatRoomsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<ChatRoomScreenState> mapEventToState(
      ChatRoomScreenEvent event) async* {
    if (event is LoadChatRooms) {
      yield* _monitorChatRooms(event);
      return;
    }

    if (event is DeleteChatRooms) {
      _deleteChatRooms(event);
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

    if (event is ArchiveChatRooms) {
      _archiveChatRooms(event);
      yield state;
      return;
    }

    if (event is UnarchiveChatRooms) {
      _unarchiveChatRooms(event);
      yield state;
      return;
    }

    if (event is CreateNewChat) {
      yield* _openNewChat(event);
      return;
    }

    if (event is OpenChatRoom) {
      yield* _openChatRoom(event);
      return;
    }

    if (event is ChatRoomsLoaded) {
      try {
        yield LoadedChatRooms(chatRooms: event.chatRooms);
        return;
      } catch (e) {
        print(e);
        yield LoadError();
      }
    }
  }

  Stream<ChatRoomScreenState> _openChatRoom(OpenChatRoom event) async* {
    // List<ChatRoom> chatRoomList = this.chatRoomsRepository.chatRoomList;
    List<UserChatRoomInfo> myChatRoomList = this.chatRoomsRepository.myChatList;

    // String contactToId = event.receiverUser.id;
    // String userIdThisApp = event.appUser.id;

    // Ignore room chats
    UserChatRoomInfo foundChatRoom = myChatRoomList
        .firstWhere((cg) => cg.id == event.chatRoom.id, orElse: () => null);

    // final chatRoom =
    //     chatRoomList.firstWhere((cg) => cg.id == foundChatRoom.id);
    // _markRead(MarkRead(chatRooms: [chatRoom], userId: userIdThisApp));

    List<ElgContact> receivers = foundChatRoom.receiverIds.map((receiverId) {
      return ElgContact(
          id: receiverId,
          username: "err",
          photoUrl: "",
          // lastOnline:
          isActive: false);
    }).toList();

// Contact contact = Contact(id: )

    yield OpenChatState(
        chatRoom: event.chatRoom,
        userThisApp: event.appUser,
        usersTo: receivers);
  }

  Stream<ChatRoomScreenState> _openNewChat(CreateNewChat event) async* {
    List<ElgChatRoom> chatRoomList = this.chatRoomsRepository.chatRoomList;
    List<UserChatRoomInfo> myChatRoomList = this.chatRoomsRepository.myChatList;

    String contactToId = event.receiverUser.id;
    String userIdThisApp = event.appUser.id;

    // Ignore room chats
    UserChatRoomInfo foundChatRoom = myChatRoomList.firstWhere(
        (cg) =>
            cg.receiverIds.contains(contactToId) && cg.receiverIds.length == 1,
        orElse: () => null);

    if (foundChatRoom == null) {
      ElgChatRoom newChatRoom = ElgChatRoom(
          id: '-1',
          name: event.receiverUser.username,
          lastMessage: '',
          created: DateTime.now().toUtc(),
          photoUrl: event.receiverUser.photoUrl,
          creatorId: contactToId,
          updated: DateTime.now().toUtc());

      yield OpenChatState(
          chatRoom: newChatRoom,
          userThisApp: event.appUser,
          usersTo: [event.receiverUser]);
    } else {
      final chatRoom =
          chatRoomList.firstWhere((cg) => cg.id == foundChatRoom.id);
      _markRead(MarkRead(chatRooms: [chatRoom], userId: userIdThisApp));

      yield OpenChatState(
          chatRoom: chatRoom,
          userThisApp: event.appUser,
          usersTo: [event.receiverUser]);
    }
  }

  Stream<ChatRoomScreenState> _monitorChatRooms(LoadChatRooms event) async* {
    try {
      chatRoomsSubscription?.cancel();
      chatRoomsSubscription = chatRoomsRepository
          .get(event.userId)
          .listen((List<ElgChatRoom> chatRooms) {
        bool anyNotSeen = chatRooms.any((cg) => !cg.read);
        this.homeBloc.add(ChangeHomePageMessagesIcon(anyNotSeen));

        this.add(ChatRoomsLoaded(chatRooms: chatRooms));
      });

      return;
    } catch (e) {
      print(e);
      yield LoadError();
    }
  }

  void _deleteChatRooms(DeleteChatRooms event) {
    WriteBatch fsBatch = Firestore.instance.batch();
    String appUserId = userRepository.user.uid;

    for (ElgChatRoom chatRoom in event.chatRooms) {
      CollectionReference collectionRef = Firestore.instance.collection(
          "${UsersProps.collectionName}/$appUserId/${UserChatRoomInfoProps.collectionName}");
      String documentId = chatRoom.id;
      DocumentReference document = collectionRef.document(documentId);
      fsBatch.delete(document);
    }

    fsBatch.commit();
  }

  void _markRead(MarkRead event) {
    //  // String appUserId = userRepository.user.uid;

    // List<ChatRoomUpdateData> allUpdateData = new List<ChatRoomUpdateData>();
    // for (var chatRoom in event.chatRooms) {
    //   MyChatRoom myChatRoom = chatRoomsRepository.myChatList
    //       .firstWhere((cg) => cg.id == chatRoom.id);

    //   List<String> readBy = [...myChatRoom.readBy];
    //   if (readBy.contains(event.userId)) {
    //     return;
    //   }
    //   readBy.add(event.userId);

    //   ChatRoomUpdateData chatRoomUpdateData = new ChatRoomUpdateData(
    //       chatRoom.id, {ChatRoomProps.readBy: readBy});

    //   allUpdateData.add(chatRoomUpdateData);
    // }

    // this.chatRoomsRepository.updateChatRooms(allUpdateData);
  }

  void _markUnread(MarkUnread event) {
    // List<ChatRoomUpdateData> allUpdateData = new List<ChatRoomUpdateData>();
    // for (var chatRoom in event.chatRooms) {
    //   MyChatRoom myChatRoom = chatRoomsRepository.myChatList
    //       .firstWhere((cg) => cg.id == chatRoom.id);

    //   List<String> readBy = [...myChatRoom.readBy];
    //   readBy.removeWhere((String id) => id.compareTo(event.userId) == 0);

    //   ChatRoomUpdateData chatRoomUpdateData = new ChatRoomUpdateData(
    //       chatRoom.id, {ChatRoomProps.readBy: readBy});

    //   allUpdateData.add(chatRoomUpdateData);
    // }

    // this.chatRoomsRepository.updateChatRooms(allUpdateData);
  }

  void _togglePinned(TogglePinned event) {
    List<ChatRoomUpdateData> allUpdateData = new List<ChatRoomUpdateData>();
    for (var chatRoom in event.chatRooms) {
      ChatRoomUpdateData chatRoomUpdateData = new ChatRoomUpdateData(
          chatRoom.id, {ChatRoomProps.pinned: chatRoom.pinned});

      allUpdateData.add(chatRoomUpdateData);
    }

    this.chatRoomsRepository.updateChatRooms(allUpdateData);
  }

  void _toggleMuted(ToggleMuted event) {
    List<ChatRoomUpdateData> allUpdateData = new List<ChatRoomUpdateData>();
    for (var chatRoom in event.chatRooms) {
      ChatRoomUpdateData chatRoomUpdateData = new ChatRoomUpdateData(
          chatRoom.id, {ChatRoomProps.muted: chatRoom.muted});

      allUpdateData.add(chatRoomUpdateData);
    }

    this.chatRoomsRepository.updateChatRooms(allUpdateData);
  }

  void _archiveChatRooms(ArchiveChatRooms event) {
    List<ChatRoomUpdateData> allUpdateData = new List<ChatRoomUpdateData>();
    for (var chatRoom in event.chatRooms) {
      ChatRoomUpdateData chatRoomUpdateData =
          new ChatRoomUpdateData(chatRoom.id, {ChatRoomProps.archived: true});

      allUpdateData.add(chatRoomUpdateData);
    }

    this.chatRoomsRepository.updateChatRooms(allUpdateData);
  }

  void _unarchiveChatRooms(UnarchiveChatRooms event) {
    List<ChatRoomUpdateData> allUpdateData = new List<ChatRoomUpdateData>();
    for (var chatRoom in event.chatRooms) {
      ChatRoomUpdateData chatRoomUpdateData =
          new ChatRoomUpdateData(chatRoom.id, {ChatRoomProps.archived: false});

      allUpdateData.add(chatRoomUpdateData);
    }

    this.chatRoomsRepository.updateChatRooms(allUpdateData);
  }
}
