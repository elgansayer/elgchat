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
      yield* _initMonitorChatRoom(event.chatRoom);
    }

    if (event is NewMessageEvent) {
      _newChatMessage(event);
    }

    if (event is SubscribeToChatRoomEvent) {
      yield* _subscribeToChatRoomEvent(event);
    }

    if (event is ChatMessagesLoaded) {
      yield state.copyWith(chatMessages: event.chatMessages);
    }
  }

  _monitorConversation(ElgChatRoom chatRoom) {
    try {
      chatsSubscription?.cancel();
      chatsSubscription = this
          ._conversationRepository
          .get(chatRoom.id)
          .listen((List<ElgChatMessage> chatMessages) {
        this.add(ChatMessagesLoaded(chatMessages: chatMessages));
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<ConversationState> _initMonitorChatRoom(ElgChatRoom chatRoom) async* {
    if (chatRoom.id == '-1') {
      yield ConversationState.init(chatRoom);
      return;
    }

    yield state.copyWith(
        chatRoom: chatRoom, chatMessages: state.chatMessages ?? []);

    _monitorConversation(chatRoom);
  }

  Stream<ConversationState> _subscribeToChatRoomEvent(
      SubscribeToChatRoomEvent event) async* {
    var newCHatRoom = state.chatRoom.copyWith(id: event.chatRoomId);
    // var newState = state.copyWith(chatRoom: newCHatRoom);
    yield* _initMonitorChatRoom(newCHatRoom);
  }

  void _newChatMessage(NewMessageEvent event) async {
    NewMessage newMessage = NewMessage(
        chatMessage: event.newChatMessage,
        chatRoom: state.chatRoom,
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

    // Get the subscribed chat room id
    Map returnData = json.decode(response.body);
    String chatRoomId = returnData['chatRoomId'];

    // If this statechat room is wrong.Rebuild
    if (this.state.chatRoom.id != chatRoomId) {
      this.add(SubscribeToChatRoomEvent(chatRoomId: chatRoomId));
    }
  }
}

class NewMessage {
  final ElgChatRoom chatRoom;
  final ElgChatMessage chatMessage;
  final List<String> receiverIds;

  NewMessage(
      {@required this.receiverIds,
      @required this.chatMessage,
      @required this.chatRoom});

  Map<String, dynamic> toJSON() {
    return {
      'receiverIds': this.receiverIds,
      'roomId': this.chatRoom.id,
      'message': this.chatMessage.message,
      'senderId': this.chatMessage.senderId
    };

    // return {
    //   'chatRoom': {
    //     'id': this.chatRoom.id,
    //     'name': this.chatRoom.name,
    //     'photoUrl': this.chatRoom.photoUrl,
    //     'receiverIds': this.receiverIds
    //   },
    //   'chatMessage': {
    //     // 'reactions': this.chatMessage.reactions.map((e) => e.toString()).toList(),
    //     // 'starred': this.chatMessage.starred.toString(),
    //     // 'deleted': this.chatMessage.deleted.toString(),
    //     // 'mediaUrls': this.chatMessage.mediaUrls.map((e) => e.toString()).toList(),
    //     // 'id': this.chatMessage.id ?? 'null',
    //     'message': this.chatMessage.message,
    //     // let the server set dates
    //     // 'created': this.chatMessage.created.toIso8601String(),
    //     // 'receiverIds': this.chatMessage.receiverIds,
    //     'senderId': this.chatMessage.senderId
    //   },
    // };
  }
}
