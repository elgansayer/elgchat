part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  ConversationState({@required this.chatGroup, @required this.chatMessages});
  final List<ChatMessage> chatMessages;
  final ChatGroup chatGroup;

  factory ConversationState.init() {
    return ConversationState(chatGroup: null, chatMessages: []);
  }

  @override
  List<Object> get props => [chatMessages, chatGroup];
}
