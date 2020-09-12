import 'package:flutter/material.dart';

import '../models.dart';

abstract class ConversationCallbackEvent {}

class ShowToastCallbackEvent extends ConversationCallbackEvent {
  final String message;
  ShowToastCallbackEvent(this.message);
}

class UnarchivedCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final List<T> chatMessages;
  UnarchivedCallbackEvent(this.chatMessages);
}

class DeletedCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final List<T> chatMessages;
  DeletedCallbackEvent(this.chatMessages);
}

class ToggleMutedCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final List<T> chatMessages;
  ToggleMutedCallbackEvent(this.chatMessages);
}

class TogglePinnedCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final List<T> chatMessages;
  TogglePinnedCallbackEvent(this.chatMessages);
}

class MarkedSeenCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final List<T> chatMessages;
  MarkedSeenCallbackEvent(this.chatMessages);
}

class ArchivedCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final List<T> chatMessages;
  ArchivedCallbackEvent(this.chatMessages);
}

class ChatMessageTappedCallbackEvent<T extends ElgChatMessage>
    extends ConversationCallbackEvent {
  final T chatMessage;
  ChatMessageTappedCallbackEvent(this.chatMessage);
}

abstract class ConversationEvent {}

class ToggleSelectedEvent extends ConversationEvent {
  final ElgChatMessage chatMessage;
  ToggleSelectedEvent(this.chatMessage);
}

class ToggleReactedEvent extends ConversationEvent {
  final ElgChatMessage chatMessage;
  final String uCode;
  final ElgContact contact;
  ToggleReactedEvent(
      {@required this.chatMessage,
      @required this.uCode,
      @required this.contact});
}

class SetSearchString extends ConversationEvent {
  final String phrase;
  SetSearchString(this.phrase);
}

class ClearSearchString extends ConversationEvent {
  ClearSearchString();
}

// class SetVisibleChatMessagesEvent<T extends ChatMessage> extends ConversationEvent {
//   final List<T> chatMessages;
//   SetVisibleChatMessagesEvent(this.chatMessages);
// }

class AddChatMessagesEvent<T extends ElgChatMessage> extends ConversationEvent {
  final List<T> chatMessages;
  AddChatMessagesEvent(this.chatMessages);
}

class SetChatMessagesEvent<T extends ElgChatMessage> extends ConversationEvent {
  final List<T> chatMessages;
  final List<T> chatMessagesRef;
  SetChatMessagesEvent(this.chatMessages, this.chatMessagesRef);
}

class SetStateEvent extends ConversationEvent {
  final ConversationLogicState state;
  SetStateEvent(this.state);
}

class DeleteSelectedEvent extends ConversationEvent {
  DeleteSelectedEvent();
}

class MuteSelectedEvent extends ConversationEvent {
  MuteSelectedEvent();
}

class CopySelectedEvent extends ConversationEvent {
  CopySelectedEvent();
}

class MarkSelectedUnreadEvent extends ConversationEvent {
  MarkSelectedUnreadEvent();
}

class ReplyWithSelectedEvent extends ConversationEvent {
  ReplyWithSelectedEvent();
}

class RemoveReplyWithSelectedEvent extends ConversationEvent {
  RemoveReplyWithSelectedEvent();
}

class SelectAllEvent extends ConversationEvent {
  SelectAllEvent();
}

class SetArchivedChatMessagesEvent<T extends ElgChatMessage>
    extends ConversationEvent {
  final List<T> chatMessages;
  SetArchivedChatMessagesEvent(this.chatMessages);
}

class UnArchivedEvent<T extends ElgChatMessage> extends ConversationEvent {
  final List<T> chatMessages;
  UnArchivedEvent(this.chatMessages);
}

class DeletedArchivedEvent<T extends ElgChatMessage> extends ConversationEvent {
  final List<T> chatMessages;
  DeletedArchivedEvent(this.chatMessages);
}

// class ViewArchivedEvent extends ConversationEvent {
//   ViewArchivedEvent();
// }

class SetScrollButtonValueEvent extends ConversationEvent {
  final bool value;
  SetScrollButtonValueEvent(this.value);
}
