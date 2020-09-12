part of 'chat_room_bloc.dart';

@immutable
abstract class ChatRoomScreenState {}

class MessagesInitial extends ChatRoomScreenState {}

class LoadedChatRooms extends ChatRoomScreenState {
  final List<ChatRoom> chatRooms;

  LoadedChatRooms({@required this.chatRooms});
}

class LoadError extends ChatRoomScreenState {}

class OpenChatState extends ChatRoomScreenState {
  final ChatRoom chatRoom;
  final List<Contact> usersTo;
  final Contact userThisApp;

  OpenChatState(
      {@required this.chatRoom,
      @required this.usersTo,
      @required this.userThisApp});
}
