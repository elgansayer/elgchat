import '../models.dart';

abstract class ChatListCallbackEvent {}

class UnarchivedCallbackEvent<T extends ElgChatRoom>
    extends ChatListCallbackEvent {
  final List<T> chatRooms;
  UnarchivedCallbackEvent(this.chatRooms);
}

class DeletedCallbackEvent<T extends ElgChatRoom> extends ChatListCallbackEvent {
  final List<T> chatRooms;
  DeletedCallbackEvent(this.chatRooms);
}

class ToggleMutedCallbackEvent<T extends ElgChatRoom>
    extends ChatListCallbackEvent {
  final List<T> chatRooms;
  ToggleMutedCallbackEvent(this.chatRooms);
}

class TogglePinnedCallbackEvent<T extends ElgChatRoom>
    extends ChatListCallbackEvent {
  final List<T> chatRooms;
  TogglePinnedCallbackEvent(this.chatRooms);
}

class MarkedUnreadCallbackEvent<T extends ElgChatRoom>
    extends ChatListCallbackEvent {
  final List<T> chatRooms;
  MarkedUnreadCallbackEvent(this.chatRooms);
}

// class MarkedUnseenCallbackEvent<T extends ChatRoom>
//     extends ChatListCallbackEvent {
//   final List<T> chatRooms;
//   MarkedUnseenCallbackEvent(this.chatRooms);
// }

class ArchivedCallbackEvent<T extends ElgChatRoom> extends ChatListCallbackEvent {
  final List<T> chatRooms;
  ArchivedCallbackEvent(this.chatRooms);
}

class ChatRoomTappedCallbackEvent<T extends ElgChatRoom>
    extends ChatListCallbackEvent {
  final T chatRoom;
  ChatRoomTappedCallbackEvent(this.chatRoom);
}
