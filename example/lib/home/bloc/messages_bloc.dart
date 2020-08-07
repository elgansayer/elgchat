import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgchat/models.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'home_bloc.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MyChatGroupProps extends ChatGroupProps {
  static const String collectionName = "chat_groups";
}

class ChatGroupsRepository {
  PublishSubject<List<ChatGroup>> chatList = PublishSubject();
  StreamSubscription _firebaseSubscription;

  Stream<QuerySnapshot> monitor(LoadChatGroups event) {
    final ref = Firestore.instance
        .collection(MyChatGroupProps.collectionName)
        .where(ChatGroupProps.userIds, arrayContains: event.userId)
        .orderBy(ChatGroupProps.updated);

    return ref.snapshots();
  }

  PublishSubject<List<ChatGroup>> get(LoadChatGroups event) {
    _firebaseSubscription?.cancel();
    _firebaseSubscription =
        this.monitor(event).listen((QuerySnapshot allGroups) {
      List<ChatGroup> chatGroups = allGroups.documents
          .map((DocumentSnapshot doc) => _buildChatGroupFrmDoc(doc))
          .toList();

      chatList.add(chatGroups);
    });

    return this.chatList;
  }

  ChatGroup _buildChatGroupFrmDoc(DocumentSnapshot doc) {
    return ChatGroup.fromMap(doc.data, doc.documentID);
  }

  void close() {
    _firebaseSubscription?.cancel();
  }
}

class ChatGroupsBloc extends Bloc<ChatGroupsEvent, ChatGroupsState> {
  final HomeBloc homeBloc;
  final ChatGroupsRepository messagesRepository;
  StreamSubscription chatsSubscription;

  ChatGroupsBloc(this.messagesRepository, this.homeBloc)
      : super(MessagesInitial());

  @override
  Future<void> close() {
    chatsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<ChatGroupsState> mapEventToState(ChatGroupsEvent event) async* {

    if (event is LoadChatGroups) {
      yield* _monitorChatGroups(event);
    }

    if (event is ChatGroupsLoaded) {
      try {
        yield LoadedChatGroups(chatGroups: event.chatGroups);
        return;
      } catch (e) {
        print(e);
        yield LoadError();
      }
    }
  }

  _monitorChatGroups(LoadChatGroups event) async* {
    try {
      chatsSubscription?.cancel();
      chatsSubscription =
          messagesRepository.get(event).listen((List<ChatGroup> chatGroups) {
        bool anyNotSeen = chatGroups.any((cg) => !cg.seen(event.userId));
        this.homeBloc.add(ChangeHomePageMessagesIcon(anyNotSeen));
        this.add(ChatGroupsLoaded(chatGroups: chatGroups));
      });

      return;
    } catch (e) {
      print(e);
      yield LoadError();
    }
  }
}
