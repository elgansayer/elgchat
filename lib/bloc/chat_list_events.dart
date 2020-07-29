import '../models.dart';

abstract class ChatListEvent {}

class ToggleSelectedEvent<T extends ChatGroup> extends ChatListEvent {
  final T chatGroup;
  ToggleSelectedEvent(this.chatGroup);
}

class SetSearchString extends ChatListEvent {
  final String phrase;
  SetSearchString(this.phrase);
}
class ClearSearchString extends ChatListEvent {
  ClearSearchString();
}

// class SetVisibleChatGroupsEvent<T extends ChatGroup> extends ChatListEvent {
//   final List<T> chatGroups;
//   SetVisibleChatGroupsEvent(this.chatGroups);
// }

class AddChatGroupsEvent<T extends ChatGroup> extends ChatListEvent {
  final List<T> chatGroups;
  AddChatGroupsEvent(this.chatGroups);
}

class SetChatGroupsEvent<T extends ChatGroup> extends ChatListEvent {
  final List<T> chatGroups;
  SetChatGroupsEvent(this.chatGroups);
}

class SetStateEvent extends ChatListEvent {
  final ChatListState state;
  SetStateEvent(this.state);
}

class DeleteSelectedEvent extends ChatListEvent {
  DeleteSelectedEvent();
}

class MuteSelectedEvent extends ChatListEvent {
  MuteSelectedEvent();
}

class ArchiveSelectedEvent extends ChatListEvent {
  ArchiveSelectedEvent();
}

class MarkSelectedUnreadEvent extends ChatListEvent {
  MarkSelectedUnreadEvent();
}

class PinSelectedEvent extends ChatListEvent {
  PinSelectedEvent();
}

class SelectAllEvent extends ChatListEvent {
  SelectAllEvent();
}

class SetArchivedChatGroupsEvent<T extends ChatGroup> extends ChatListEvent {
  final List<T> chatGroups;
  SetArchivedChatGroupsEvent(this.chatGroups);
}
