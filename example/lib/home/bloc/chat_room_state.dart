part of 'chat_room_bloc.dart';

@immutable
abstract class ChatRoomScreenState {}

class MessagesInitial extends ChatRoomScreenState {}

class LoadedChatRooms extends ChatRoomScreenState {
  final List<ElgChatRoom> chatRooms;

  LoadedChatRooms({@required this.chatRooms});
}

class LoadError extends ChatRoomScreenState {}

class OpenChatState extends ChatRoomScreenState {
  final ElgChatRoom chatRoom;
  final List<ElgContact> usersTo;
  final ElgContact userThisApp;

  OpenChatState(
      {@required this.chatRoom,
      @required this.usersTo,
      @required this.userThisApp});
}
