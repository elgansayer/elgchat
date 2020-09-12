part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class NewMessageEvent extends ConversationEvent {
  final ElgChatMessage newChatMessage;
  final List<ElgContact> receivers;
  // final ChatRoom chatRoom;
  NewMessageEvent({this.newChatMessage, this.receivers});
}

class ChatMessagesLoaded extends ConversationEvent {
  final List<ElgChatMessage> chatMessages;
  ChatMessagesLoaded({this.chatMessages});
}

class SubscribeToChatRoomEvent extends ConversationEvent {
  final String chatRoomId;
  SubscribeToChatRoomEvent({this.chatRoomId});
}

class InitConversationEvent extends ConversationEvent {
  final ElgChatRoom chatRoom;
  final String userId;
  InitConversationEvent({this.chatRoom, this.userId});
}
