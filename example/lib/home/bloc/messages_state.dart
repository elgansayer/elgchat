part of 'messages_bloc.dart';

@immutable
abstract class ChatGroupsState {}

class MessagesInitial extends ChatGroupsState {}

class LoadedChatGroups extends ChatGroupsState {
  final List<ChatGroup> chatGroups;

  LoadedChatGroups({@required this.chatGroups});
}

class LoadError extends ChatGroupsState {}
