part of 'chat_group_bloc.dart';

@immutable
abstract class ChatGroupScreenState {}

class MessagesInitial extends ChatGroupScreenState {}

class LoadedChatGroups extends ChatGroupScreenState {
  final List<ChatGroup> chatGroups;

  LoadedChatGroups({@required this.chatGroups});
}

class LoadError extends ChatGroupScreenState {}

class OpenChatState extends ChatGroupScreenState {
  final ChatGroup chatGroup;
  final List<Contact> usersTo;
  final Contact userThisApp;

  OpenChatState(
      {@required this.chatGroup,
      @required this.usersTo,
      @required this.userThisApp});
}
