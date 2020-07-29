import 'dart:async';

import 'bloc/chat_list_callback_events.dart';
import 'bloc/chat_list_events.dart';
import 'models.dart';

extension selectedExtension<E extends ChatGroup> on List<E> {
  List<E> selected() {
    return this.where((element) => element.selected).toList();
  }

  List<E> pinned() {
    return this.where((element) => element.pinned).toList();
  }

  List<E> archivedIs(bool value) {
    return this.where((element) => element.archived == value).toList();
  }
}

class ChatListScreenLogic<T extends ChatGroup> {
  List<T> chatGroups = List<T>();
  List<T> archivedGroups = List<T>();
  ChatListState currentState = ChatListState.loading;
  // String searchString = "";

  ChatListScreenLogic() {
    eventController.stream.listen(handleGotEvent);

    listenToState();
    listenToChatsStream();
  }

  listenToState() {
    stateStreamController.stream.listen((ChatListState newState) {
      if (currentState == ChatListState.selection &&
          newState != ChatListState.selection) {
        unselectAll();
      }

      currentState = newState;
    });
  }

  listenToChatsStream() {
    chatGroupsStreamController.stream.listen((List<T> chatGroups) {
      // bool viewArchived = this.currentState == ChatListState.listarchived;
      // List<T> nonArchived = chatGroups.archivedIs(viewArchived);
      visibleChatGroupsStreamController.add(chatGroups);
    });
  }

  // ChatListState get currentState => currentState;

  handleGotEvent(ChatListEvent event) {
    if (event is SetSearchString) {
      return setSearchString(event);
    }

    if (event is ClearSearchString) {
      return clearSearchString();
    }

    if (event is ToggleSelectedEvent) {
      return toggleSelectedEvent(event);
    }

    if (event is AddChatGroupsEvent) {
      return addChatGroups(event);
    }

    if (event is SetChatGroupsEvent) {
      return setChatGroups(event);
    }

    if (event is SetStateEvent) {
      return setStateEvent(event);
    }

    if (event is MuteSelectedEvent) {
      return muteSelectedEvent();
    }

    if (event is ArchiveSelectedEvent) {
      return archiveSelectedEvent();
    }

    if (event is MarkSelectedUnreadEvent) {
      return markSelectedUnreadEvent();
    }

    if (event is PinSelectedEvent) {
      return pinSelectedEvent();
    }

    if (event is DeleteSelectedEvent) {
      return deleteSelectedEvent();
    }

    if (event is SelectAllEvent) {
      return selectAllEvent();
    }

    if (event is UnArchivedEvent) {
      return unArchivedEvent(event);
    }

    if (event is DeletedArchivedEvent) {
      return deletedArchivedEvent(event);
    }
  }

  deletedArchivedEvent(DeletedArchivedEvent event) {
    // Remove from archived
    List<T> newChatGroups = event.chatGroups;

    // Remove from the archived list
    // any item in newChatGroups
    archivedGroups.removeWhere((cg) => newChatGroups.contains(cg));

    // Add only archived to ourarchive list
    archivedChatGroupsStreamController.add(archivedGroups);
  }

  unArchivedEvent(UnArchivedEvent event) {
    // Remove from archived
    List<T> newChatGroups = event.chatGroups.map((ChatGroup cg) {
      return cg.copyWith(archived: false, selected: false);
    }).toList();

    //Add back into our chat list
    chatGroups.addAll(newChatGroups);

    // Remove from the archived list
    // any item in newChatGroups
    archivedGroups.removeWhere((cg) => newChatGroups.contains(cg));

    // Add only archived to ourarchive list
    archivedChatGroupsStreamController.add(archivedGroups);

    // Update our chat list
    chatGroupsStreamController.add(this.chatGroups);
  }

  clearSearchString() {
    // Runs through the visible filters
    chatGroupsStreamController.add(this.chatGroups);
  }

  setSearchString(SetSearchString event) {
    List<T> chatGroups = this
        .chatGroups
        .where((cg) => cg.groupName.toLowerCase().contains(event.phrase))
        .toList();

    chatGroupsStreamController.add(chatGroups);
  }

  selectAllEvent() {
    chatGroups = chatGroups.map((T cg) {
      return cg.copyWith(selected: true);
    }).toList();

    chatGroupsStreamController.add(this.chatGroups);
    this.selectedStreamController.add(this.chatGroups);
  }

  deleteSelectedEvent() {
    List<T> allSelected = chatGroups.selected();
    chatGroups.removeWhere((T cg) => allSelected.contains(cg));

    // This fires widget.onDeleted
    this.dispatchCallback.add(DeletedCallbackEvent(allSelected));

    unselectAll();
    stateStreamController.add(ChatListState.list);
  }

  pinSelectedEvent() {
    List<T> allSelected = chatGroups.selected();
    chatGroups = chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(pinned: !cg.pinned);
      }
      return cg;
    }).toList();

    // This fires widget.onTogglePinned
    this.dispatchCallback.add(TogglePinnedCallbackEvent(allSelected));

    // Move pinned to the top
    List<T> allPinned = chatGroups.pinned();
    chatGroups.removeWhere((cg) => allPinned.contains(cg));
    chatGroups.insertAll(0, allPinned);

    unselectAll();
    stateStreamController.add(ChatListState.list);
  }

  markSelectedUnreadEvent() {
    List<T> allSelected = chatGroups.selected();
    chatGroups = chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(seen: false);
      }
      return cg;
    }).toList();

    // This fires widget.onMarkedSeen
    this.dispatchCallback.add(MarkedSeenCallbackEvent(allSelected));

    unselectAll();
    stateStreamController.add(ChatListState.list);
  }

  archiveSelectedEvent() {
    List<T> allSelected = chatGroups.selected();
    chatGroups = chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(archived: true, selected: false);
      }
      return cg;
    }).toList();

    // This fires widget.onArchived
    this.dispatchCallback.add(ArchivedCallbackEvent(allSelected));

    // Get all archived, remov ethem from the list
    List<T> allArchived = chatGroups.archivedIs(true);
    chatGroups.removeWhere((cg) => allArchived.contains(cg));

    archivedGroups.addAll(allArchived);
    archivedChatGroupsStreamController.add(archivedGroups);

    unselectAll();

    stateStreamController.add(ChatListState.list);
  }

  muteSelectedEvent() {
    List<T> allSelected = chatGroups.selected();
    chatGroups = chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(muted: !cg.muted);
      }
      return cg;
    }).toList();

    // This fires widget.onToggleMuted
    this.dispatchCallback.add(ToggleMutedCallbackEvent(allSelected));

    unselectAll();
    stateStreamController.add(ChatListState.list);
  }

  final eventController = StreamController<ChatListEvent>();
  Sink<ChatListEvent> get dispatch {
    return eventController.sink;
  }

  final callbackEventController = StreamController<ChatListCallbackEvent>();
  Stream<ChatListCallbackEvent> get callbackEventControllerStream =>
      callbackEventController.stream;
  Sink<ChatListCallbackEvent> get dispatchCallback {
    return callbackEventController.sink;
  }

  final stateStreamController = StreamController<ChatListState>.broadcast();
  StreamSink<ChatListState> get stateSink => stateStreamController.sink;
  Stream<ChatListState> get stateStream => stateStreamController.stream;
  setStateEvent(SetStateEvent event) {
    stateSink.add(event.state);
  }

  final selectedStreamController = StreamController<List<T>>.broadcast();
  StreamSink<List<T>> get selectedChatGroupsSink =>
      selectedStreamController.sink;
  Stream<List<T>> get selectedChatGroupsStream =>
      selectedStreamController.stream;

  toggleSelectedEvent(ToggleSelectedEvent event) {
    int index = this.chatGroups.indexOf(event.chatGroup);
    T oldChatGroup = this.chatGroups.elementAt(index);
    T newChatGroup = event.chatGroup.copyWith(selected: !oldChatGroup.selected);

    this.chatGroups.replaceRange(index, index + 1, [newChatGroup]);

    chatGroupsStreamController.add(this.chatGroups);

    List<T> allSelected = this.chatGroups.selected();
    if (allSelected.length > 0 &&
        this.currentState != ChatListState.selection) {
      stateStreamController.add(ChatListState.selection);
    }

    this.selectedStreamController.add(allSelected);
  }

  unselectAll() {
    this.chatGroups = chatGroups.map((T cg) {
      return cg.copyWith(selected: false);
    }).toList();

    chatGroupsStreamController.add(this.chatGroups);
    this.selectedStreamController.add([]);
  }

  final visibleChatGroupsStreamController = StreamController<List<T>>();
  StreamSink<List<T>> get visibleChatGroupsSink =>
      visibleChatGroupsStreamController.sink;
  Stream<List<T>> get visibleChatGroupsStream =>
      visibleChatGroupsStreamController.stream;

  final chatGroupsStreamController = StreamController<List<T>>.broadcast();
  StreamSink<List<T>> get chatGroupsSink => chatGroupsStreamController.sink;
  Stream<List<T>> get chatGroupsStreamStream =>
      chatGroupsStreamController.stream;

  setChatGroups(SetChatGroupsEvent event) {
    List<T> newChatGroups = event.chatGroups;
    chatGroups.addAll(newChatGroups);

    chatGroupsStreamController.add(chatGroups);

    dispatch.add(SetStateEvent(ChatListState.list));
  }

  addChatGroups(AddChatGroupsEvent event) {
    List<T> newChatGroups = event.chatGroups;
    chatGroups.addAll(newChatGroups);

    chatGroupsStreamController.add(chatGroups);
  }

  final archivedChatGroupsStreamController = StreamController<List<T>>();
  StreamSink<List<T>> get archivedChatGroupsSink =>
      archivedChatGroupsStreamController.sink;
  Stream<List<T>> get archivedChatGroupsStream =>
      archivedChatGroupsStreamController.stream;

  dispose() {
    archivedChatGroupsStreamController.close();
    stateStreamController.close();
    chatGroupsStreamController.close();
    visibleChatGroupsStreamController.close();
    selectedStreamController.close();
    eventController.close();
    callbackEventController.close();
  }
}
