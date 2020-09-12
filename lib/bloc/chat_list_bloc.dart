// import 'dart:async';

// import 'chat_list_callback_events.dart';
// import 'chat_list_events.dart';
// import '../models.dart';

// import '../models.dart';

// class ChatRoomListLogic<T extends ChatRoom> {
//   List<T> chatRooms = List<T>();
//   List<T> archivedRooms = List<T>();
//   ChatListState currentState = ChatListState.loading;
//   // String searchString = "";

//   ChatRoomListLogic(chatRooms) {

//     eventController.stream.listen(handleGotEvent);
//     listenToState();
//     listenToChatsStream();

//         this.setChatRooms(SetChatRoomsEvent(chatRooms));

//   }

//   listenToState() {
//     stateStreamController.stream.listen((ChatListState newState) {
//       if (currentState == ChatListState.selection &&
//           newState != ChatListState.selection) {
//         unselectAll();
//       }

//       currentState = newState;
//     });
//   }

//   listenToChatsStream() {
//     chatRoomsStreamController.stream.listen((List<T> chatRooms) {
//       // bool viewArchived = this.currentState == ChatListState.listarchived;
//       // List<T> nonArchived = chatRooms.archivedIs(viewArchived);
//       visibleChatRoomsStreamController.add(chatRooms);
//     });
//   }

//   // ChatListState get currentState => currentState;

//   handleGotEvent(ChatListEvent event) {
//     if (event is SetSearchString) {
//       return setSearchString(event);
//     }

//     if (event is ClearSearchString) {
//       return clearSearchString();
//     }

//     if (event is ToggleSelectedEvent) {
//       return toggleSelectedEvent(event);
//     }

//     // if (event is AddChatRoomsEvent) {
//     //   return addChatRooms(event);
//     // }

//     if (event is SetChatRoomsEvent) {
//       return setChatRooms(event);
//     }

//     if (event is SetStateEvent) {
//       return setStateEvent(event);
//     }

//     if (event is MuteSelectedEvent) {
//       return muteSelectedEvent();
//     }

//     if (event is ArchiveSelectedEvent) {
//       return archiveSelectedEvent();
//     }

//     if (event is MarkSelectedUnreadEvent) {
//       return markSelectedUnreadEvent(event);
//     }

//     if (event is PinSelectedEvent) {
//       return pinSelectedEvent();
//     }

//     if (event is DeleteSelectedEvent) {
//       return deleteSelectedEvent();
//     }

//     if (event is SelectAllEvent) {
//       return selectAllEvent();
//     }

//     if (event is UnArchivedEvent) {
//       return unArchivedEvent(event);
//     }

//     if (event is DeletedArchivedEvent) {
//       return deletedArchivedEvent(event);
//     }
//   }

//   deletedArchivedEvent(DeletedArchivedEvent event) {
//     // Remove from archived
//     List<T> newChatRooms = event.chatRooms;

//     // Remove from the archived list
//     // any item in newChatRooms
//     archivedRooms.removeWhere((cg) => newChatRooms.contains(cg));

//     // Add only archived to ourarchive list
//     archivedChatRoomsStreamController.add(archivedRooms);
//   }

//   unArchivedEvent(UnArchivedEvent event) {
//     // Remove from archived
//     List<T> newChatRooms = event.chatRooms.map((ChatRoom cg) {
//       return cg.copyWith(archived: false, selected: false);
//     }).toList();

//     //Add back into our chat list
//     chatRooms.addAll(newChatRooms);

//     // Remove from the archived list
//     // any item in newChatRooms
//     archivedRooms.removeWhere((cg) => newChatRooms.contains(cg));

//     // Add only archived to ourarchive list
//     archivedChatRoomsStreamController.add(archivedRooms);

//     // Update our chat list
//     chatRoomsStreamController.add(this.chatRooms);
//   }

//   clearSearchString() {
//     // Runs through the visible filters
//     chatRoomsStreamController.add(this.chatRooms);
//   }

//   setSearchString(SetSearchString event) {
//     List<T> chatRooms = this
//         .chatRooms
//         .where((cg) => cg.name.toLowerCase().contains(event.phrase))
//         .toList();

//     chatRoomsStreamController.add(chatRooms);
//   }

//   selectAllEvent() {
//     chatRooms = chatRooms.map((T cg) {
//       if (cg.archived != true) {
//         return cg.copyWith(selected: true);
//       }
//       return cg.copyWith(selected: false);
//     }).toList();

//     chatRoomsStreamController.add(this.chatRooms);
//     this.selectedStreamController.add(this.chatRooms);
//   }

//   deleteSelectedEvent() {
//     List<T> allSelected = chatRooms.selected();
//     chatRooms.removeWhere((T cg) => allSelected.contains(cg));

//     // This fires widget.onDeleted
//     this.dispatchCallback.add(DeletedCallbackEvent(allSelected));

//     unselectAll();
//     stateStreamController.add(ChatListState.list);
//   }

//   pinSelectedEvent() {
//     List<T> allSelected = chatRooms.selected();
//     chatRooms = chatRooms.map((T cg) {
//       bool selected = allSelected.contains(cg);
//       if (selected) {
//         return cg.copyWith(pinned: !cg.pinned);
//       }
//       return cg;
//     }).toList();

//     List<T> allUpdatedSelected =
//         chatRooms.where((T cg) => allSelected.contains(cg)).toList();

//     // This fires widget.onTogglePinned
//     this.dispatchCallback.add(TogglePinnedCallbackEvent(allUpdatedSelected));

//     // Move pinned to the top
//     List<T> allPinned = chatRooms.pinned();
//     chatRooms.removeWhere((cg) => allPinned.contains(cg));
//     chatRooms.insertAll(0, allPinned);

//     unselectAll();
//     stateStreamController.add(ChatListState.list);
//   }

//   markSelectedUnreadEvent(MarkSelectedUnreadEvent event) {
//     List<T> allSelected = chatRooms.selected();
//     chatRooms = chatRooms.map((T cg) {
//       bool selected = allSelected.contains(cg);

//       if (selected) {
//         List<String> seenIds = [...cg.readBy];
//         seenIds.removeWhere((String id) => id.compareTo(event.userid) == 0);
//         return cg.copyWith(seenBy: seenIds);
//       }

//       // if (selected) {
//       //   List<String> seenIds = cg.readBy;
//       //   return cg.copyWith(seenBy: [...seenIds, event.userid]);
//       // }

//       return cg;
//     }).toList();

//     List<T> allUpdatedSelected =
//         chatRooms.where((T cg) => allSelected.contains(cg)).toList();

//     // This fires widget.onMarkedUnread
//     this.dispatchCallback.add(MarkedUnreadCallbackEvent(allUpdatedSelected));

//     unselectAll();
//     stateStreamController.add(ChatListState.list);
//   }

//   // markReadEvent(MarkSelectedReadEvent event) {
//   //   List<T> allSelected = chatRooms.selected();
//   //   chatRooms = chatRooms.map((T cg) {
//   //     bool selected = allSelected.contains(cg);

//   //     if (selected) {
//   //       List<String> seenIds = cg.seenBy;
//   //       return cg.copyWith(seenBy: [...seenIds, event.userid]);
//   //     }

//   //     return cg;
//   //   }).toList();

//   //   List<T> allUpdatedSelected =
//   //       chatRooms.where((T cg) => allSelected.contains(cg)).toList();

//   //   // This fires widget.onMarkedRead
//   //   this.dispatchCallback.add(MarkedReadCallbackEvent(allUpdatedSelected));

//   //   unselectAll();
//   //   stateStreamController.add(ChatListState.list);
//   // }

//   archiveSelectedEvent() {
//     List<T> allSelected = chatRooms.selected();
//     chatRooms = chatRooms.map((T cg) {
//       bool selected = allSelected.contains(cg);
//       if (selected) {
//         return cg.copyWith(archived: true, selected: false);
//       }
//       return cg;
//     }).toList();

//     List<T> allUpdatedSelected =
//         chatRooms.where((T cg) => allSelected.contains(cg)).toList();

//     // This fires widget.onArchived
//     this.dispatchCallback.add(ArchivedCallbackEvent(allUpdatedSelected));

//     // Get all archived, remov ethem from the list
//     List<T> allArchived = chatRooms.archivedIs(true);
//     chatRooms.removeWhere((cg) => allArchived.contains(cg));

//     archivedRooms.addAll(allArchived);
//     archivedChatRoomsStreamController.add(archivedRooms);

//     unselectAll();

//     stateStreamController.add(ChatListState.list);
//   }

//   muteSelectedEvent() {
//     List<T> allSelected = chatRooms.selected();
//     chatRooms = chatRooms.map((T cg) {
//       bool selected = allSelected.contains(cg);
//       if (selected) {
//         return cg.copyWith(muted: !cg.muted);
//       }
//       return cg;
//     }).toList();

//     List<T> allUpdatedSelected =
//         chatRooms.where((T cg) => allSelected.contains(cg)).toList();

//     // This fires widget.onToggleMuted
//     this.dispatchCallback.add(ToggleMutedCallbackEvent(allUpdatedSelected));

//     unselectAll();
//     stateStreamController.add(ChatListState.list);
//   }

//   final eventController = StreamController<ChatListEvent>();
//   Sink<ChatListEvent> get dispatch {
//     return eventController.sink;
//   }

//   final callbackEventController = StreamController<ChatListCallbackEvent>();
//   Stream<ChatListCallbackEvent> get callbackEventControllerStream =>
//       callbackEventController.stream;
//   Sink<ChatListCallbackEvent> get dispatchCallback {
//     return callbackEventController.sink;
//   }

//   final stateStreamController = StreamController<ChatListState>.broadcast();
//   StreamSink<ChatListState> get stateSink => stateStreamController.sink;
//   Stream<ChatListState> get stateStream => stateStreamController.stream;
//   setStateEvent(SetStateEvent event) {
//     stateSink.add(event.state);
//   }

//   final selectedStreamController = StreamController<List<T>>.broadcast();
//   StreamSink<List<T>> get selectedChatRoomsSink =>
//       selectedStreamController.sink;
//   Stream<List<T>> get selectedChatRoomsStream =>
//       selectedStreamController.stream;

//   toggleSelectedEvent(ToggleSelectedEvent event) {
//     int index = this.chatRooms.indexOf(event.chatRoom);
//     T oldChatRoom = this.chatRooms.elementAt(index);
//     T newChatRoom = event.chatRoom.copyWith(selected: !oldChatRoom.selected);

//     this.chatRooms.replaceRange(index, index + 1, [newChatRoom]);

//     chatRoomsStreamController.add(this.chatRooms);

//     List<T> allSelected = this.chatRooms.selected();
//     if (allSelected.length > 0 &&
//         this.currentState != ChatListState.selection) {
//       stateStreamController.add(ChatListState.selection);
//     }

//     this.selectedStreamController.add(allSelected);
//   }

//   unselectAll() {
//     this.chatRooms = chatRooms.map((T cg) {
//       return cg.copyWith(selected: false);
//     }).toList();

//     chatRoomsStreamController.add(this.chatRooms);
//     this.selectedStreamController.add([]);
//   }

//   final visibleChatRoomsStreamController = StreamController<List<T>>();
//   StreamSink<List<T>> get visibleChatRoomsSink =>
//       visibleChatRoomsStreamController.sink;
//   Stream<List<T>> get visibleChatRoomsStream =>
//       visibleChatRoomsStreamController.stream;

//   final chatRoomsStreamController = StreamController<List<T>>.broadcast();
//   StreamSink<List<T>> get chatRoomsSink => chatRoomsStreamController.sink;
//   Stream<List<T>> get chatRoomsStreamStream =>
//       chatRoomsStreamController.stream;

//   setChatRooms(SetChatRoomsEvent event) {
//     // If we want to use a reference, else use mutatable list
//     // if (event.chatRoomsRef != null) {
//     //   List<T> newChatRooms = event.chatRoomsRef;
//     //   chatRooms = newChatRooms;
//     // } else {
//     //   List<T> newChatRooms = event.chatRooms;
//     //   chatRooms = [...newChatRooms];
//     // }
//     chatRooms = [...event.chatRooms];
//     chatRoomsStreamController.add(chatRooms);
//     if (this.currentState == ChatListState.loading) {
//       // dispatch.add(SetStateEvent(ChatListState.list));
//       this.stateSink.add(ChatListState.list);
//     }
//   }

//   // addChatRooms(AddChatRoomsEvent event) {
//   //   List<T> newChatRooms = event.chatRooms;
//   //   chatRooms.addAll(newChatRooms);

//   //   chatRoomsStreamController.add(chatRooms);
//   // }

//   final archivedChatRoomsStreamController = StreamController<List<T>>();
//   StreamSink<List<T>> get archivedChatRoomsSink =>
//       archivedChatRoomsStreamController.sink;
//   Stream<List<T>> get archivedChatRoomsStream =>
//       archivedChatRoomsStreamController.stream;

//   dispose() {
//     archivedChatRoomsStreamController.close();
//     stateStreamController.close();
//     chatRoomsStreamController.close();
//     visibleChatRoomsStreamController.close();
//     selectedStreamController.close();
//     eventController.close();
//     callbackEventController.close();
//   }
// }
