import 'package:elgchat/elgchat.dart';
import 'package:elgchat_example/conversation/conversation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user_repository.dart';
import 'bloc/chat_room_bloc.dart';
import 'find_user_screen.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // int numItmes = 11;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatRoomScreenBloc, ChatRoomScreenState>(
      listener: (BuildContext context, ChatRoomScreenState state) {
        if (state is OpenChatState) {
          this._openConversation(state.usersTo, state.chatRoom);
        }
      },
      builder: (context, state) {
        if (state is LoadedChatRooms) {
          return _buildList(state);
        }

        return _buildLoading();
      },
    );
  }

  _buildLoading() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chat List'),
        ),
        body: Center(child: CircularProgressIndicator()));
  }

  _buildList(LoadedChatRooms state) {
    final ElgContact user = _getAppUserContact();

    // Load rooms from state and use ref
    List<ElgChatRoom> chatRooms = state.chatRooms;

    //import 'package:elgchat/bloc/chat_list_bloc.dart';
    return ElgChatRoomList(
      // floatingActionBar: FloatingActionButton(onPressed: () {
      //   // setState(() {BuildContext, ChatRoomsState
      //   //   var id = faker.guid.guid();
      //   //   chatRooms.add(ChatRoom(
      //   //     id: id,
      //   //     name: faker.internet.userName(),
      //   //     // contacts: allContacts.sublist(0, randomInt),
      //   //     lastMessage: faker.lorem.sentence(),
      //   //     created: faker.date.dateTime(),
      //   //     seenBy: [id],
      //   //   ));
      //   // });
      // }),
      onTap: _onTappedChatRoom,
      chatRooms: chatRooms,
      // onLoadChatRooms: onLoadChatRooms,
      // onLoadMoreChatRooms: onLoadMoreChatRooms,
      stateCreator: () => ElgChatRoomListState(),
      trailingActions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _onFindUserToChatTo(context),
        )
      ],
      user: user,
      onDeleted: (List<ElgChatRoom> chatRooms) {
        BlocProvider.of<ChatRoomScreenBloc>(context)
            .add(DeleteChatRooms(chatRooms: chatRooms));
      },
      onTogglePinned: (List<ElgChatRoom> chatRooms) {
        BlocProvider.of<ChatRoomScreenBloc>(context)
            .add(TogglePinned(chatRooms: chatRooms));
      },
      onToggleMuted: (List<ElgChatRoom> chatRooms) {
        BlocProvider.of<ChatRoomScreenBloc>(context)
            .add(ToggleMuted(chatRooms: chatRooms));
      },
      // onMarkedRead: (List<ChatRoom> chatRooms) {
      //   BlocProvider.of<ChatRoomScreenBloc>(context)
      //       .add(MarkUnread(userId: contact.id, chatRooms: chatRooms));
      // },
      onMarkedUnread: (List<ElgChatRoom> chatRooms) {
        BlocProvider.of<ChatRoomScreenBloc>(context)
            .add(MarkUnread(userId: user.id, chatRooms: chatRooms));
      },
      onArchived: (List<ElgChatRoom> chatRooms) {
        BlocProvider.of<ChatRoomScreenBloc>(context)
            .add(ArchiveChatRooms(chatRooms: chatRooms));
      },
      onUnarchived: (List<ElgChatRoom> chatRooms) {
        BlocProvider.of<ChatRoomScreenBloc>(context)
            .add(UnarchiveChatRooms(chatRooms: chatRooms));
      },
    );
  }

  void _onTappedChatRoom(ElgChatRoom chatRoom) {
    final ElgContact appUserContact = _getAppUserContact();

    BlocProvider.of<ChatRoomScreenBloc>(context)
        .add(OpenChatRoom(chatRoom: chatRoom, appUser: appUserContact));
  }

  void _openConversation(List<ElgContact> receivers, ElgChatRoom chatRoom) {
    final ElgContact user = _getAppUserContact();

    BlocProvider.of<ChatRoomScreenBloc>(context)
        .add(MarkRead(userId: user.id, chatRooms: [chatRoom]));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationViewScreen(
                  user: user,
                  chatRoom: chatRoom,
                  receivers: receivers,
                )));
  }

  _onFindUserToChatTo(BuildContext context) async {
    ElgContact contactSelected = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => FindUserScreen()));

    final ElgContact appUserContact = _getAppUserContact();

    if (contactSelected != null) {
      BlocProvider.of<ChatRoomScreenBloc>(context).add(CreateNewChat(
          receiverUser: contactSelected, appUser: appUserContact));
    }
  }

  ElgContact _getAppUserContact() {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    final FirebaseUser user = userRepository.user;
    // Create n ElgCHat Contact from our firebase user
    return ElgContact(id: user.uid, photoUrl: user.photoUrl);
  }
}
// class ChatListPage extends StatelessWidget {
//   int numItmes = 11;

//   ChatListPage({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChatListScreen<ChatRoom, ChatListScreenLogic>(
//       onFloating: ((){
// setSt
//       }),
//         // onTap: (ChatRoom chatRoom) => onChatRoomTap(context, chatRoom),
//         chatRooms: [],
//         // onLoadChatRooms: onLoadChatRooms,
//         // onLoadMoreChatRooms: onLoadMoreChatRooms,
//         stateCreator: () => MyChatScreenState(),
//         trailingActions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => onFindUserToChatTo(context),
//           )
//         ]);
//   }

//   void onChatRoomTap(BuildContext context, ChatRoom chatRoom) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 ConversationViewScreen(chatRoom: chatRoom)));
//   }

//   Future<List<ChatRoom>> onLoadChatRooms() async {
//     var allChatRooms = List.generate(numItmes, (i) {
//       return ChatRoom(
//         id: i.toString(),
//         roomName: faker.internet.userName(),
//         // contacts: allContacts.sublist(0, randomInt),
//         lastMessage: faker.lorem.sentence(),
//         date: faker.date.dateTime(),
//         seen: faker.randomGenerator.boolean(),
//       );
//     });

//     return allChatRooms;
//   }

//   Future<List<ChatRoom>> onLoadMoreChatRooms() async {
//     var allChatRooms = List.generate(numItmes, (i) {
//       // var randomInt = faker.randomGenerator.integer(20);
//       return ChatRoom(
//         id: i.toString(),
//         roomName: faker.internet.userName(),
//         // contacts: allContacts.sublist(0, randomInt),
//         lastMessage: faker.lorem.sentence(),
//         date: faker.date.dateTime(),
//         seen: faker.randomGenerator.boolean(),
//       );
//     });

//     return allChatRooms;
//   }

//   onFindUserToChatTo(BuildContext context) async {
//     Contact contactSelected = await Navigator.push(
//         context, MaterialPageRoute(builder: (context) => FindUserScreen()));
//   }
// }

// class MyChatScreenState extends ChatRoomListState {}
