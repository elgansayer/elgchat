part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class NewMessageEvent extends ConversationEvent {
  final ChatMessage newChatMessage;
  final String userId;
  final ChatGroup chatGroup;
  NewMessageEvent({this.chatGroup, this.newChatMessage, this.userId});
}

class InitConversationEvent extends ConversationEvent {
  final ChatGroup chatGroup;
  final String userId;
  InitConversationEvent({this.chatGroup, this.userId});
}
