part of 'messages_bloc.dart';

@immutable
abstract class ChatGroupsEvent {}

class LoadChatGroups extends ChatGroupsEvent {
  final String userId;
  LoadChatGroups({@required this.userId});
}

class ChatGroupsLoaded extends ChatGroupsEvent {
  final List<ChatGroup> chatGroups;
  ChatGroupsLoaded({@required this.chatGroups});
}
