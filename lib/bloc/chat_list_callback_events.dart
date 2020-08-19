import '../models.dart';

abstract class ChatListCallbackEvent {}

class UnarchivedCallbackEvent<T extends ChatGroup>
    extends ChatListCallbackEvent {
  final List<T> chatGroups;
  UnarchivedCallbackEvent(this.chatGroups);
}

class DeletedCallbackEvent<T extends ChatGroup> extends ChatListCallbackEvent {
  final List<T> chatGroups;
  DeletedCallbackEvent(this.chatGroups);
}

class ToggleMutedCallbackEvent<T extends ChatGroup>
    extends ChatListCallbackEvent {
  final List<T> chatGroups;
  ToggleMutedCallbackEvent(this.chatGroups);
}

class TogglePinnedCallbackEvent<T extends ChatGroup>
    extends ChatListCallbackEvent {
  final List<T> chatGroups;
  TogglePinnedCallbackEvent(this.chatGroups);
}

class MarkedUnreadCallbackEvent<T extends ChatGroup>
    extends ChatListCallbackEvent {
  final List<T> chatGroups;
  MarkedUnreadCallbackEvent(this.chatGroups);
}

// class MarkedUnseenCallbackEvent<T extends ChatGroup>
//     extends ChatListCallbackEvent {
//   final List<T> chatGroups;
//   MarkedUnseenCallbackEvent(this.chatGroups);
// }

class ArchivedCallbackEvent<T extends ChatGroup> extends ChatListCallbackEvent {
  final List<T> chatGroups;
  ArchivedCallbackEvent(this.chatGroups);
}

class ChatGroupTappedCallbackEvent<T extends ChatGroup>
    extends ChatListCallbackEvent {
  final T chatGroup;
  ChatGroupTappedCallbackEvent(this.chatGroup);
}
