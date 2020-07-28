import 'dart:async';

import 'bloc/chat_list_events.dart';
import 'models.dart';

class ChatListScreenLogic<T extends ChatGroup> {
  List<T> _chatGroups;
  List<T> _visibleChatGroups;
  ChatState _state;
  List<T> _selectedChatGroups = new List<T>();

  ChatListScreenLogic(List<T> chatGroups, ChatState state) {
    _chatGroups = chatGroups;
    _state = state;
    _eventController.stream.listen(_handleGotEvent);

    _setChatGroups(SetChatGroupsEvent(chatGroups));
  }

  _handleGotEvent(ChatListEvent event) {
    if (event is AddSelectedEvent) {
      return _addSelectedEvent(event);
    }

    if (event is SetChatGroupsEvent) {
      return _setChatGroups(event);
    }
  }

  // Stream of events from broascast
  final _eventController = StreamController<ChatListEvent>();

  // Fires the event inside the bloc
  Sink<ChatListEvent> get broadcast {
    return _eventController.sink;
  }

  // Selected Chat Groups
  final _selectedStreamController = StreamController<List<T>>();
  StreamSink<List<T>> get selectedChatGroupsSink =>
      _selectedStreamController.sink;
  Stream<List<T>> get selectedChatGroups => _selectedStreamController.stream;
  _addSelectedEvent(AddSelectedEvent event) {
    int haveItem = _selectedChatGroups.indexOf(event.chatGroup);
    if (haveItem > -1) {
      _selectedChatGroups.removeAt(haveItem);
    } else {
      _selectedChatGroups.add(event.chatGroup);
    }

    List<ChatGroup> visibleChatGroups = _chatGroups.map((T cg) {
      int haveItem = _selectedChatGroups.indexOf(cg);
      bool selected = haveItem > -1;
      return cg.copyWith(selected: selected);
    }).toList();

    _setChatGroups(SetChatGroupsEvent(visibleChatGroups));
    selectedChatGroupsSink.add(_selectedChatGroups);
  }

  // Visible Chat Groups
  final _visibleChatGroupsStreamController = StreamController<List<T>>();
  StreamSink<List<T>> get visibleChatGroupsSink =>
      _visibleChatGroupsStreamController.sink;
  Stream<List<T>> get visibleChatGroups =>
      _visibleChatGroupsStreamController.stream;
  _setChatGroups(SetChatGroupsEvent event) {
    _visibleChatGroups = event.chatGroups;
    _visibleChatGroupsStreamController.add(_visibleChatGroups);
  }

  dispose() {
    _visibleChatGroupsStreamController.close();
    _selectedStreamController.close();
    _eventController.close();
  }
}
