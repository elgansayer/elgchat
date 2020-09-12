part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  ConversationState({@required this.chatRoom, @required this.chatMessages});
  final List<ElgChatMessage> chatMessages;
  final ElgChatRoom chatRoom;

  factory ConversationState.init(ElgChatRoom chatRoom) {
    return ConversationState(chatRoom: chatRoom, chatMessages: []);
  }

  ConversationState copyWith({
    List<ElgChatMessage> chatMessages,
    ElgChatRoom chatRoom,
  }) {
    return ConversationState(
      chatMessages: chatMessages ?? this.chatMessages,
      chatRoom: chatRoom ?? this.chatRoom,
    );
  }

  @override
  List<Object> get props => [chatMessages, chatRoom];
}
