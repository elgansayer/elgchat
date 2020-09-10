import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:elgchat/models.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import '../../api.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(ConversationState.init());

  @override
  Stream<ConversationState> mapEventToState(
    ConversationEvent event,
  ) async* {
    if (event is InitConversationEvent) {
      yield ConversationState(chatGroup: event.chatGroup, chatMessages: []);
    }

    if (event is NewMessageEvent) {
      _newChatMessage(event);
    }
  }

  void _newChatMessage(NewMessageEvent event) async {
    NewMessage newMessage = NewMessage(
        groupId: event.chatGroup.id, chatMessage: event.newChatMessage);

    final response =
        await http.post(API.PostNewMessage, body: newMessage.toJSON());

    if (response.statusCode != 200) {
      throw Exception('Failed to post message');
    }
  }
}

class NewMessage {
  // id: string;
  final String groupId;
  final ChatMessage chatMessage;

  NewMessage({this.groupId, this.chatMessage});

  Map<String, String> toJSON() {
    return {
      'groupId': this.groupId,
      // 'chatMessage': {
      // 'reactions': this.chatMessage.reactions.map((e) => e.toString()).toList(),
      'starred': this.chatMessage.starred.toString(),
      'deleted': this.chatMessage.senderId.toString(),
      // 'mediaUrls': this.chatMessage.mediaUrls.map((e) => e.toString()).toList(),
      'id': this.chatMessage.id ?? 'null',
      'message': this.chatMessage.message,
      'creationDate': this.chatMessage.creationDate.toIso8601String(),
      'senderId': this.chatMessage.senderId
      // },
    };
  }
}
