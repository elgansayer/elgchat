import 'dart:async';

import 'bloc/chat_list_events.dart';
import 'models.dart';

extension selectedExtension<E extends ChatGroup> on List<E> {
  List<E> selected() {
    return this.where((element) => element.selected).toList();
  }
}

class ChatListScreenLogic<T extends ChatGroup> {
  List<T> _chatGroups = List<T>();
  ChatListState _currentState = ChatListState.loading;
  // String _searchString = "";

  ChatListScreenLogic() {
    _eventController.stream.listen(_handleGotEvent);

    _listenToState();
    _listenToChatsStream();
  }

  _listenToState() {
    _stateStreamController.stream.listen((ChatListState newState) {
      if (_currentState == ChatListState.selection &&
          newState != ChatListState.selection) {
        _unselectAll();
      }

      _currentState = newState;
    });
  }

  _listenToChatsStream() {
    _chatGroupsStreamController.stream.listen((List<T> chatGroups) {
      _visibleChatGroupsStreamController.add(chatGroups);
    });
  }

  ChatListState get currentState => _currentState;

  _handleGotEvent(ChatListEvent event) {
    if (event is SetSearchString) {
      return _setSearchString(event);
    }

    if (event is ClearSearchString) {
      return _clearSearchString();
    }

    if (event is ToggleSelectedEvent) {
      return _toggleSelectedEvent(event);
    }

    if (event is AddChatGroupsEvent) {
      return _addChatGroups(event);
    }

    if (event is SetChatGroupsEvent) {
      return _setChatGroups(event);
    }

    if (event is SetStateEvent) {
      return _setStateEvent(event);
    }

    if (event is MuteSelectedEvent) {
      return _muteSelectedEvent();
    }

    if (event is ArchiveSelectedEvent) {
      return _archiveSelectedEvent();
    }

    if (event is MarkSelectedUnreadEvent) {
      return _markSelectedUnreadEvent();
    }

    if (event is PinSelectedEvent) {
      return _pinSelectedEvent();
    }

    if (event is DeleteSelectedEvent) {
      return _deleteSelectedEvent();
    }

    if (event is SelectAllEvent) {
      return _selectAllEvent();
    }

    if (event is SetArchivedChatGroupsEvent) {
      return _setArchivedChatGroups(event);
    }
  }

  _clearSearchString() {
    _visibleChatGroupsStreamController.add(this._chatGroups);
  }

  _setSearchString(SetSearchString event) {
    List<T> chatGroups = this
        ._chatGroups
        .where((cg) => cg.groupName.toLowerCase().contains(event.phrase)).toList();
    _visibleChatGroupsStreamController.add(chatGroups);
  }

  _selectAllEvent() {
    _chatGroups = _chatGroups.map((T cg) {
      return cg.copyWith(selected: true);
    }).toList();

    _chatGroupsStreamController.add(this._chatGroups);
    this._selectedStreamController.add(this._chatGroups);
  }

  _deleteSelectedEvent() {
    List<T> allSelected = _chatGroups.selected();
    _chatGroups.removeWhere((T cg) => allSelected.contains(cg));

    _unselectAll();
    _stateStreamController.add(ChatListState.list);
  }

  _pinSelectedEvent() {
    List<T> allSelected = _chatGroups.selected();
    _chatGroups = _chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(pinned: !cg.pinned);
      }
      return cg;
    }).toList();

    _unselectAll();
    _stateStreamController.add(ChatListState.list);
  }

  _markSelectedUnreadEvent() {
    List<T> allSelected = _chatGroups.selected();
    _chatGroups = _chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(seen: false);
      }
      return cg;
    }).toList();

    _unselectAll();
    _stateStreamController.add(ChatListState.list);
  }

  _archiveSelectedEvent() {
    List<T> allSelected = _chatGroups.selected();
    _chatGroups = _chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(archived: !cg.archived);
      }
      return cg;
    }).toList();

    _unselectAll();
    _stateStreamController.add(ChatListState.list);
  }

  _muteSelectedEvent() {
    List<T> allSelected = _chatGroups.selected();
    _chatGroups = _chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(muted: !cg.muted);
      }
      return cg;
    }).toList();

    _unselectAll();
    _stateStreamController.add(ChatListState.list);
  }

  final _eventController = StreamController<ChatListEvent>();

  Sink<ChatListEvent> get dispatch {
    return _eventController.sink;
  }

  final _stateStreamController = StreamController<ChatListState>.broadcast();
  StreamSink<ChatListState> get stateSink => _stateStreamController.sink;
  Stream<ChatListState> get stateStream => _stateStreamController.stream;
  _setStateEvent(SetStateEvent event) {
    stateSink.add(event.state);
  }

  final _selectedStreamController = StreamController<List<T>>.broadcast();
  StreamSink<List<T>> get selectedChatGroupsSink =>
      _selectedStreamController.sink;
  Stream<List<T>> get selectedChatGroupsStream =>
      _selectedStreamController.stream;

  _toggleSelectedEvent(ToggleSelectedEvent event) {
    int index = this._chatGroups.indexOf(event.chatGroup);
    T oldChatGroup = this._chatGroups.elementAt(index);
    T newChatGroup = event.chatGroup.copyWith(selected: !oldChatGroup.selected);

    this._chatGroups.replaceRange(index, index + 1, [newChatGroup]);

    _chatGroupsStreamController.add(this._chatGroups);

    List<T> allSelected = this._chatGroups.selected();
    if (allSelected.length > 0 &&
        this._currentState != ChatListState.selection) {
      _stateStreamController.add(ChatListState.selection);
    }

    this._selectedStreamController.add(allSelected);
  }

  _unselectAll() {
    this._chatGroups = _chatGroups.map((T cg) {
      return cg.copyWith(selected: false);
    }).toList();

    _chatGroupsStreamController.add(this._chatGroups);
    this._selectedStreamController.add([]);
  }

  final _visibleChatGroupsStreamController = StreamController<List<T>>();
  StreamSink<List<T>> get visibleChatGroupsSink =>
      _visibleChatGroupsStreamController.sink;
  Stream<List<T>> get visibleChatGroupsStream =>
      _visibleChatGroupsStreamController.stream;

  final _chatGroupsStreamController = StreamController<List<T>>.broadcast();
  StreamSink<List<T>> get chatGroupsSink => _chatGroupsStreamController.sink;
  Stream<List<T>> get chatGroupsStreamStream =>
      _chatGroupsStreamController.stream;

  _setChatGroups(SetChatGroupsEvent event) {
    List<T> newChatGroups = event.chatGroups;
    _chatGroups.addAll(newChatGroups);

    _chatGroupsStreamController.add(_chatGroups);

    dispatch.add(SetStateEvent(ChatListState.list));
  }

  _addChatGroups(AddChatGroupsEvent event) {
    List<T> newChatGroups = event.chatGroups;
    _chatGroups.addAll(newChatGroups);

    _chatGroupsStreamController.add(_chatGroups);
  }

  final _archivedChatGroupsStreamController = StreamController<List<T>>();
  StreamSink<List<T>> get archivedChatGroupsSink =>
      _archivedChatGroupsStreamController.sink;
  Stream<List<T>> get archivedChatGroupsStream =>
      _archivedChatGroupsStreamController.stream;

  _setArchivedChatGroups(SetArchivedChatGroupsEvent event) {}

  dispose() {
    _archivedChatGroupsStreamController.close();
    _stateStreamController.close();
    _chatGroupsStreamController.close();
    _visibleChatGroupsStreamController.close();
    _selectedStreamController.close();
    _eventController.close();
  }
}
