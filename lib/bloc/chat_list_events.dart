import '../models.dart';

abstract class ChatListEvent {}

class AddSelectedEvent<T extends ChatGroup> extends ChatListEvent {
  final T chatGroup;
  AddSelectedEvent(this.chatGroup);
}

class SetChatGroupsEvent<T extends ChatGroup> extends ChatListEvent {
  final List<T> chatGroups;
  SetChatGroupsEvent(this.chatGroups);
}
