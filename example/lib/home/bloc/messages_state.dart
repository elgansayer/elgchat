part of 'messages_bloc.dart';

@immutable
abstract class ChatGroupScreenState {}

class MessagesInitial extends ChatGroupScreenState {}

class LoadedChatGroups extends ChatGroupScreenState {
  final List<ChatGroup> chatGroups;

  LoadedChatGroups({@required this.chatGroups});
}

class LoadError extends ChatGroupScreenState {}
