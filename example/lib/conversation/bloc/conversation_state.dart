part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  ConversationState({@required this.chatGroup, @required this.chatMessages});
  final List<ChatMessage> chatMessages;
  final ChatGroup chatGroup;

  factory ConversationState.init(ChatGroup chatGroup) {
    return ConversationState(chatGroup: chatGroup, chatMessages: []);
  }

  ConversationState copyWith({
    List<ChatMessage> chatMessages,
    ChatGroup chatGroup,
  }) {
    return ConversationState(
      chatMessages: chatMessages ?? this.chatMessages,
      chatGroup: chatGroup ?? this.chatGroup,
    );
  }

  @override
  List<Object> get props => [chatMessages, chatGroup];
}
