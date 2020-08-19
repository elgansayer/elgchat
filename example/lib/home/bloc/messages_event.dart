part of 'messages_bloc.dart';

@immutable
abstract class ChatGroupScreenEvent {}

class LoadChatGroups extends ChatGroupScreenEvent {
  final String userId;
  LoadChatGroups({@required this.userId});
}

class ChatGroupsLoaded extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  ChatGroupsLoaded({@required this.chatGroups});
}

class UpdateChatGroups extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  UpdateChatGroups({@required this.chatGroups});
}

class TogglePinned extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  TogglePinned({@required this.chatGroups});
}

class ToggleMuted extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  ToggleMuted({@required this.chatGroups});
}

class MarkUnread extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  final String userId;
  MarkUnread({@required this.userId, @required this.chatGroups});
}

class MarkRead extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  final String userId;
  MarkRead({@required this.userId, @required this.chatGroups});
}

class ArchiveChatGroups extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  ArchiveChatGroups({@required this.chatGroups});
}

class UnarchiveChatGroups extends ChatGroupScreenEvent {
  final List<ChatGroup> chatGroups;
  UnarchiveChatGroups({@required this.chatGroups});
}
