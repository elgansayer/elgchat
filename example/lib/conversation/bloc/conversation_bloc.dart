import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:elgchat/models.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'conversation_repository.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(ConversationState.init(null));

  ConversationRepository _conversationRepository = new ConversationRepository();
  StreamSubscription chatsSubscription;

  @override
  Future<void> close() {
    chatsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<ConversationState> mapEventToState(
    ConversationEvent event,
  ) async* {
    if (event is InitConversationEvent) {
      yield* _initMonitorChatGroup(event.chatGroup);
    }

    if (event is NewMessageEvent) {
      _newChatMessage(event);
    }

    if (event is SubscribeToChatGroupEvent) {
      yield* _subscribeToChatGroupEvent(event);
    }

    if (event is ChatMessagesLoaded) {
      yield state.copyWith(chatMessages: event.chatMessages);
    }
  }

  _monitorConversation(ChatGroup chatGroup) {
    try {
      chatsSubscription?.cancel();
      chatsSubscription = this
          ._conversationRepository
          .get(chatGroup.id)
          .listen((List<ChatMessage> chatMessages) {
        this.add(ChatMessagesLoaded(chatMessages: chatMessages));
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<ConversationState> _initMonitorChatGroup(ChatGroup chatGroup) async* {
    if (chatGroup.id == '-1') {
      yield ConversationState.init(chatGroup);
      return;
    }

    yield state.copyWith(
        chatGroup: chatGroup, chatMessages: state.chatMessages ?? []);

    _monitorConversation(chatGroup);
  }

  Stream<ConversationState> _subscribeToChatGroupEvent(
      SubscribeToChatGroupEvent event) async* {
    var newCHatGroup = state.chatGroup.copyWith(id: event.chatGroupId);
    // var newState = state.copyWith(chatGroup: newCHatGroup);
    yield* _initMonitorChatGroup(newCHatGroup);
  }

  void _newChatMessage(NewMessageEvent event) async {
    NewMessage newMessage = NewMessage(
        chatMessage: event.newChatMessage,
        chatGroup: state.chatGroup,
        receiverIds: event.receivers.map((e) => e.id).toList());

    Map<String, String> headers = Map<String, String>();
    headers['Content-Type'] = 'application/json';

    final data = json.encode(newMessage.toJSON());

    final response = await http.post(
        'http://192.168.1.86:5001/elgchat/us-central1/api/newMessage',
        headers: headers,
        body: data);

    if (response.statusCode != 200) {
      print("statusCode ${response.statusCode}");
      throw Exception('Failed to post message');
    }

    // Get the subscribed chat group id
    Map returnData = json.decode(response.body);
    String chatGroupId = returnData['chatGroupId'];

    // If this statechat group is wrong.Rebuild
    if (this.state.chatGroup.id != chatGroupId) {
      this.add(SubscribeToChatGroupEvent(chatGroupId: chatGroupId));
    }
  }
}

class NewMessage {
  final ChatGroup chatGroup;
  final ChatMessage chatMessage;
  final List<String> receiverIds;

  NewMessage(
      {@required this.receiverIds,
      @required this.chatMessage,
      @required this.chatGroup});

  Map<String, dynamic> toJSON() {
    return {
      'chatGroup': {
        'id': this.chatGroup.id,
        'name': this.chatGroup.name,
        'photoUrl': this.chatGroup.photoUrl,
        'receiverIds': this.receiverIds
      },
      'chatMessage': {
        // 'reactions': this.chatMessage.reactions.map((e) => e.toString()).toList(),
        // 'starred': this.chatMessage.starred.toString(),
        // 'deleted': this.chatMessage.deleted.toString(),
        // 'mediaUrls': this.chatMessage.mediaUrls.map((e) => e.toString()).toList(),
        // 'id': this.chatMessage.id ?? 'null',
        'message': this.chatMessage.message,
        // let the server set dates
        // 'created': this.chatMessage.created.toIso8601String(),
        // 'receiverIds': this.chatMessage.receiverIds,
        'senderId': this.chatMessage.senderId
      },
    };
  }
}
