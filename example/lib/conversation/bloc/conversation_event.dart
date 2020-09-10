part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class NewMessageEvent extends ConversationEvent {
  final ChatMessage newChatMessage;
  final String receiverId;
  // final ChatGroup chatGroup;
  NewMessageEvent({this.newChatMessage, this.receiverId});
}

class ChatMessagesLoaded extends ConversationEvent {
  final List<ChatMessage> chatMessages;
  ChatMessagesLoaded({this.chatMessages});
}

class SubscribeToChatGroupEvent extends ConversationEvent {
  final String chatGroupId;
  SubscribeToChatGroupEvent({this.chatGroupId});
}

class InitConversationEvent extends ConversationEvent {
  final ChatGroup chatGroup;
  final String userId;
  InitConversationEvent({this.chatGroup, this.userId});
}
