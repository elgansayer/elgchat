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
  // final List<T> chatGroupsRef;
  final List<T> chatGroups;
  SetChatGroupsEvent(this.chatGroups);
}

class SetStateEvent extends ChatListEvent {
  final ChatListState state;
  SetStateEvent(this.state);
}

class DeleteSelectedEvent extends ChatListEvent {
  final List<ChatGroup> chatGroups;
  DeleteSelectedEvent(this.chatGroups);
}

class MuteSelectedEvent extends ChatListEvent {
  final List<ChatGroup> chatGroups;
  MuteSelectedEvent(this.chatGroups);
}

class UnarchiveSelectedEvent extends ChatListEvent {
  final List<ChatGroup> chatGroups;
  UnarchiveSelectedEvent(this.chatGroups);
}

class ArchiveSelectedEvent extends ChatListEvent {
  final List<ChatGroup> chatGroups;
  ArchiveSelectedEvent(this.chatGroups);
}

class MarkSelectedUnreadEvent extends ChatListEvent {
  final List<ChatGroup> chatGroups;
  MarkSelectedUnreadEvent(this.chatGroups);
}

class PinSelectedEvent extends ChatListEvent {
  final List<ChatGroup> chatGroups;
  PinSelectedEvent(this.chatGroups);
}

class SelectAllEvent extends ChatListEvent {
  SelectAllEvent();
}

// class SetArchivedChatGroupsEvent<T extends ChatGroup> extends ChatListEvent {
//   final List<T> chatGroups;
//   SetArchivedChatGroupsEvent(this.chatGroups);
// }

// class UnArchivedEvent<T extends ChatGroup> extends ChatListEvent {
//   final List<T> chatGroups;
//   UnArchivedEvent(this.chatGroups);
// }

// class DeletedArchivedEvent<T extends ChatGroup> extends ChatListEvent {
//   final List<T> chatGroups;
//   DeletedArchivedEvent(this.chatGroups);
// }

// class ViewArchivedEvent extends ChatListEvent {
//   ViewArchivedEvent();
// }
