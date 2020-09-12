part of 'chat_room_bloc.dart';

@immutable
abstract class ChatRoomScreenEvent {}

class LoadChatRooms extends ChatRoomScreenEvent {
  final String userId;
  LoadChatRooms({@required this.userId});
}

class ChatRoomsLoaded extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  ChatRoomsLoaded({@required this.chatRooms});
}

class UpdateChatRooms extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  UpdateChatRooms({@required this.chatRooms});
}

class TogglePinned extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  TogglePinned({@required this.chatRooms});
}

class DeleteChatRooms extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  DeleteChatRooms({@required this.chatRooms});
}

class ToggleMuted extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  ToggleMuted({@required this.chatRooms});
}

class MarkUnread extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  final String userId;
  MarkUnread({@required this.userId, @required this.chatRooms});
}

class MarkRead extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  final String userId;
  MarkRead({@required this.userId, @required this.chatRooms});
}

class ArchiveChatRooms extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  ArchiveChatRooms({@required this.chatRooms});
}

class UnarchiveChatRooms extends ChatRoomScreenEvent {
  final List<ElgChatRoom> chatRooms;
  UnarchiveChatRooms({@required this.chatRooms});
}

class CreateNewChat extends ChatRoomScreenEvent {
  final ElgContact receiverUser;
  final ElgContact appUser;
  CreateNewChat({@required this.appUser, @required this.receiverUser});
}
class OpenChatRoom extends ChatRoomScreenEvent {
  final ElgChatRoom chatRoom;
  final ElgContact appUser;
  OpenChatRoom({@required this.appUser, @required this.chatRoom});
}
