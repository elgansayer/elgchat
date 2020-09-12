import '../models.dart';

abstract class ChatListEvent {}

class ToggleSelectedEvent<T extends ElgChatRoom> extends ChatListEvent {
  final T chatRoom;
  ToggleSelectedEvent(this.chatRoom);
}

class SetSearchString extends ChatListEvent {
  final String phrase;
  SetSearchString(this.phrase);
}

class ClearSearchString extends ChatListEvent {
  ClearSearchString();
}

// class SetVisibleChatRoomsEvent<T extends ChatRoom> extends ChatListEvent {
//   final List<T> chatRooms;
//   SetVisibleChatRoomsEvent(this.chatRooms);
// }

class AddChatRoomsEvent<T extends ElgChatRoom> extends ChatListEvent {
  final List<T> chatRooms;
  AddChatRoomsEvent(this.chatRooms);
}

class SetChatRoomsEvent<T extends ElgChatRoom> extends ChatListEvent {
  // final List<T> chatRoomsRef;
  final List<T> chatRooms;
  SetChatRoomsEvent(this.chatRooms);
}

class SetStateEvent extends ChatListEvent {
  final ChatListState state;
  SetStateEvent(this.state);
}

class DeleteSelectedEvent extends ChatListEvent {
  final List<ElgChatRoom> chatRooms;
  DeleteSelectedEvent(this.chatRooms);
}

class MuteSelectedEvent extends ChatListEvent {
  final List<ElgChatRoom> chatRooms;
  MuteSelectedEvent(this.chatRooms);
}

class UnarchiveSelectedEvent extends ChatListEvent {
  final List<ElgChatRoom> chatRooms;
  UnarchiveSelectedEvent(this.chatRooms);
}

class ArchiveSelectedEvent extends ChatListEvent {
  final List<ElgChatRoom> chatRooms;
  ArchiveSelectedEvent(this.chatRooms);
}

class MarkSelectedUnreadEvent extends ChatListEvent {
  final List<ElgChatRoom> chatRooms;
  MarkSelectedUnreadEvent(this.chatRooms);
}

class PinSelectedEvent extends ChatListEvent {
  final List<ElgChatRoom> chatRooms;
  PinSelectedEvent(this.chatRooms);
}

class SelectAllEvent extends ChatListEvent {
  SelectAllEvent();
}

// class SetArchivedChatRoomsEvent<T extends ChatRoom> extends ChatListEvent {
//   final List<T> chatRooms;
//   SetArchivedChatRoomsEvent(this.chatRooms);
// }

// class UnArchivedEvent<T extends ChatRoom> extends ChatListEvent {
//   final List<T> chatRooms;
//   UnArchivedEvent(this.chatRooms);
// }

// class DeletedArchivedEvent<T extends ChatRoom> extends ChatListEvent {
//   final List<T> chatRooms;
//   DeletedArchivedEvent(this.chatRooms);
// }

// class ViewArchivedEvent extends ChatListEvent {
//   ViewArchivedEvent();
// }
