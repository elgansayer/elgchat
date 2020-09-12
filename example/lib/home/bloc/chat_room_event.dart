part of 'chat_room_bloc.dart';

@immutable
abstract class ChatRoomScreenEvent {}

class LoadChatRooms extends ChatRoomScreenEvent {
  final String userId;
  LoadChatRooms({@required this.userId});
}

class ChatRoomsLoaded extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  ChatRoomsLoaded({@required this.chatRooms});
}

class UpdateChatRooms extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  UpdateChatRooms({@required this.chatRooms});
}

class TogglePinned extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  TogglePinned({@required this.chatRooms});
}

class DeleteChatRooms extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  DeleteChatRooms({@required this.chatRooms});
}

class ToggleMuted extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  ToggleMuted({@required this.chatRooms});
}

class MarkUnread extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  final String userId;
  MarkUnread({@required this.userId, @required this.chatRooms});
}

class MarkRead extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  final String userId;
  MarkRead({@required this.userId, @required this.chatRooms});
}

class ArchiveChatRooms extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  ArchiveChatRooms({@required this.chatRooms});
}

class UnarchiveChatRooms extends ChatRoomScreenEvent {
  final List<ChatRoom> chatRooms;
  UnarchiveChatRooms({@required this.chatRooms});
}

class CreateNewChat extends ChatRoomScreenEvent {
  final Contact receiverUser;
  final Contact appUser;
  CreateNewChat({@required this.appUser, @required this.receiverUser});
}
class OpenChatRoom extends ChatRoomScreenEvent {
  final ChatRoom chatRoom;
  final Contact appUser;
  OpenChatRoom({@required this.appUser, @required this.chatRoom});
}
