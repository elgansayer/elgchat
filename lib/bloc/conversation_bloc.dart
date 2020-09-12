import 'dart:async';

import 'package:flutter/services.dart';

import '../models.dart';
import 'conversation_event.dart';

class ConversationListLogic {
  List<ElgChatMessage> chatMessages = List<ElgChatMessage>();
  ConversationLogicState currentState = ConversationLogicState.loading;
  ElgChatMessage selectedChatMessage;
  ElgChatMessage repiyingWithChatMessage;
  bool scrollButtonValue = false;

  ConversationListLogic() {
    eventController.stream.listen(handleGotEvent);
  }

  handleGotEvent(ConversationEvent event) {
    // if (event is SetSearchString) {
    // return setSearchString(event);
    // }
    if (event is ToggleSelectedEvent) {
      return toggleSelectedEvent(event);
    }

    if (event is SetStateEvent) {
      return setStateEvent(event);
    }

    if (event is SetChatMessagesEvent) {
      return setChatMessages(event);
    }

    if (event is CopySelectedEvent) {
      return copySelected(event);
    }
    if (event is ReplyWithSelectedEvent) {
      return replyWithSelectedEvent(event);
    }
    if (event is RemoveReplyWithSelectedEvent) {
      return removeReplyWithSelectedEvent();
    }

    if (event is SetScrollButtonValueEvent) {
      return setScrollButtonValueEvent(event);
    }

    if (event is ToggleReactedEvent) {
      return toggleReactedEvent(event);
    }
  }

  toggleReactedEvent(ToggleReactedEvent event) {
    var reactions = event.chatMessage.reactions ?? [];
    if (reactions.contains(event.uCode)) {
      reactions.removeWhere((String uc) => uc.compareTo(event.uCode) == 0);
    } else {
      reactions.add(event.uCode);
    }

    ElgChatMessage newChatMessage =
        event.chatMessage.copyWith(reactions: reactions);

    var index = this.chatMessages.indexOf(event.chatMessage);

    this.chatMessages.replaceRange(index, index + 1, [newChatMessage]);

    chatMessagesStreamController.add(this.chatMessages);
  }

  copySelected(CopySelectedEvent event) {
    String message = selectedChatMessage.message;
    Clipboard.setData(ClipboardData(text: message)).then((result) {
      dispatchCallback.add(ShowToastCallbackEvent('Copied'));
    });
  }

  final showScrollBtnController = StreamController<bool>();
  Stream<bool> get showScrollBtnStream => showScrollBtnController.stream;
  Sink<bool> get showScrollBtnSink {
    return showScrollBtnController.sink;
  }

  setScrollButtonValueEvent(SetScrollButtonValueEvent event) {
    showScrollBtnController.add(event.value);
    this.scrollButtonValue = event.value;
  }

  final replyingWithCMController = StreamController<ElgChatMessage>();
  Stream<ElgChatMessage> get replyingWithChatMsgStream =>
      replyingWithCMController.stream;
  Sink<ElgChatMessage> get replyingWithCMControllerSink {
    return replyingWithCMController.sink;
  }

  replyWithSelectedEvent(ReplyWithSelectedEvent event) {
    this.repiyingWithChatMessage = selectedChatMessage;
    replyingWithCMController.add(repiyingWithChatMessage);
  }

  removeReplyWithSelectedEvent() {
    this.repiyingWithChatMessage = null;
    replyingWithCMController.add(null);
  }

  final eventController = StreamController<ConversationEvent>();
  Sink<ConversationEvent> get dispatch {
    return eventController.sink;
  }

  final callbackEventController = StreamController<ConversationCallbackEvent>();
  Stream<ConversationCallbackEvent> get callbackEventStream =>
      callbackEventController.stream;
  Sink<ConversationCallbackEvent> get dispatchCallback {
    return callbackEventController.sink;
  }

  final stateStreamController = StreamController<ConversationLogicState>.broadcast();
  StreamSink<ConversationLogicState> get stateSink => stateStreamController.sink;
  Stream<ConversationLogicState> get stateStream => stateStreamController.stream;
  setStateEvent(SetStateEvent event) {
    stateSink.add(event.state);
  }

  final chatMessagesStreamController =
      StreamController<List<ElgChatMessage>>.broadcast();
  StreamSink<List<ElgChatMessage>> get chatMessagesSink =>
      chatMessagesStreamController.sink;
  Stream<List<ElgChatMessage>> get visibleChatMessagesStream =>
      chatMessagesStreamController.stream;
  setChatMessages(SetChatMessagesEvent event) {
    // If we want to use a reference, else use mutatable list
    if (event.chatMessagesRef != null) {
      List<ElgChatMessage> newChatMessages = event.chatMessagesRef;
      chatMessages = newChatMessages;
    } else {
      List<ElgChatMessage> newChatMessages = event.chatMessages;
      chatMessages = [...newChatMessages];
    }

    chatMessagesStreamController.add(chatMessages);

    if (this.currentState == ConversationLogicState.loading) {
      // dispatch.add(SetStateEvent(ConversationState.list));
      this.stateSink.add(ConversationLogicState.list);
    }
  }

  final selectedStreamController = StreamController<ElgChatMessage>.broadcast();
  StreamSink<ElgChatMessage> get selectedChatRoomsSink =>
      selectedStreamController.sink;
  Stream<ElgChatMessage> get selectedChatRoomsStream =>
      selectedStreamController.stream;

  toggleSelectedEvent(ToggleSelectedEvent event) {
    // int index = this.chatMessages.indexOf(event.chatMessage);
    // ChatMessage oldChatMessage = this.chatMessages.elementAt(index);
    // ChatMessage newChatMessage =
    //     event.chatMessage.copyWith(selected: !oldChatMessage.selected);

    // this.chatMessages.replaceRange(index, index + 1, [newChatMessage]);
    // chatMessagesStreamController.add(this.chatMessages);

    // if (this.currentState != ConversationState.selection) {
    //   stateStreamController.add(ConversationState.selection);
    // }

    // if (newChatMessage.selected) {
    //   this.selectedChatMessage = newChatMessage;
    //   this.selectedStreamController.add(newChatMessage);
    // } else {
    //   this.selectedChatMessage = newChatMessage;
    //   this.selectedStreamController.add(null);
    // }
  }

  dispose() {
    showScrollBtnController.close();
    selectedStreamController.close();
    chatMessagesStreamController.close();
    stateStreamController.close();
    eventController.close();
    callbackEventController.close();
  }
}
