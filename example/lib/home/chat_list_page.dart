import 'package:elgchat/elgchat.dart';
import 'package:elgchat_example/conversation/conversation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user_repository.dart';
import 'bloc/messages_bloc.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // int numItmes = 11;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatGroupScreenBloc, ChatGroupScreenState>(
        builder: (BuildContext context, ChatGroupScreenState state) {

      if (state is LoadedChatGroups) {
        return _buildList(state);
      }

      return _buildLoading();
    });
  }

  _buildLoading() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chat List'),
        ),
        body: Center(child: CircularProgressIndicator()));
  }

  _buildList(LoadedChatGroups state) {
    final Contact contact = _getContact();

    // Load groups from state and use ref
    List<ChatGroup> chatGroups = state.chatGroups;

    //import 'package:elgchat/bloc/chat_list_bloc.dart';
    return ChatGroupList(
      // floatingActionBar: FloatingActionButton(onPressed: () {
      //   // setState(() {BuildContext, ChatGroupsState
      //   //   var id = faker.guid.guid();
      //   //   chatGroups.add(ChatGroup(
      //   //     id: id,
      //   //     name: faker.internet.userName(),
      //   //     // contacts: allContacts.sublist(0, randomInt),
      //   //     lastMessage: faker.lorem.sentence(),
      //   //     created: faker.date.dateTime(),
      //   //     seenBy: [id],
      //   //   ));
      //   // });
      // }),
      onTap: (ChatGroup chatGroup) => _onChatGroupTap(context, chatGroup),
      chatGroups: chatGroups,
      // onLoadChatGroups: onLoadChatGroups,
      // onLoadMoreChatGroups: onLoadMoreChatGroups,
      stateCreator: () => ChatGroupListState(),
      trailingActions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _onFindUserToChatTo(context),
        )
      ],
      user: contact,
      onTogglePinned: (List<ChatGroup> chatGroups) {
        BlocProvider.of<ChatGroupScreenBloc>(context)
            .add(TogglePinned(chatGroups: chatGroups));
      },
      onToggleMuted: (List<ChatGroup> chatGroups) {
        BlocProvider.of<ChatGroupScreenBloc>(context)
            .add(ToggleMuted(chatGroups: chatGroups));
      },
      // onMarkedRead: (List<ChatGroup> chatGroups) {
      //   BlocProvider.of<ChatGroupScreenBloc>(context)
      //       .add(MarkUnread(userId: contact.id, chatGroups: chatGroups));
      // },
      onMarkedUnread: (List<ChatGroup> chatGroups) {
        BlocProvider.of<ChatGroupScreenBloc>(context)
            .add(MarkUnread(userId: contact.id, chatGroups: chatGroups));
      },
      onArchived: (List<ChatGroup> chatGroups) {
        BlocProvider.of<ChatGroupScreenBloc>(context)
            .add(ArchiveChatGroups(chatGroups: chatGroups));
      },
      // onUnarchived: (List<ChatGroup> chatGroups) {
      //   BlocProvider.of<ChatGroupScreenBloc>(context)
      //       .add(unarchiveChatGroups(chatGroups: chatGroups));
      // },
    );
  }

  void _onChatGroupTap(BuildContext context, ChatGroup chatGroup) {
    final Contact contact = _getContact();

    BlocProvider.of<ChatGroupScreenBloc>(context)
        .add(MarkRead(userId: contact.id, chatGroups: [chatGroup]));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ConversationViewScreen(chatGroup: chatGroup)));
  }

  // Future<List<ChatGroup>> onLoadChatGroups() async {
  //   var allChatGroups = List.generate(numItmes, (i) {
  //     return ChatGroup(
  //       id: i.toString(),
  //       name: faker.internet.userName(),
  //       // contacts: allContacts.sublist(0, randomInt),
  //       lastMessage: faker.lorem.sentence(),
  //       created: faker.date.dateTime(),
  //       seenBy: [i.toString()],
  //     );
  //   });

  //   return allChatGroups;
  // }

  // Future<List<ChatGroup>> onLoadMoreChatGroups() async {
  //   var allChatGroups = List.generate(numItmes, (i) {
  //     // var randomInt = faker.randomGenerator.integer(20);
  //     return ChatGroup(
  //       id: i.toString(),
  //       groupName: faker.internet.userName(),
  //       // contacts: allContacts.sublist(0, randomInt),
  //       lastMessage: faker.lorem.sentence(),
  //       date: faker.date.dateTime(),
  //       seen: faker.randomGenerator.boolean(),
  //     );
  //   });

  //   return allChatGroups;
  // }

  _onFindUserToChatTo(BuildContext context) async {
    // Contact contactSelected = await Navigator.push(
    // context, MaterialPageRoute(builder: (context) => FindUserScreen()));
  }

  Contact _getContact() {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    final FirebaseUser user = userRepository.user;
    // Create n ElgCHat Contact from our firebase user
    return Contact(id: user.uid, photoUrl: user.photoUrl);
  }
}
// class ChatListPage extends StatelessWidget {
//   int numItmes = 11;

//   ChatListPage({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChatListScreen<ChatGroup, ChatListScreenLogic>(
//       onFloating: ((){
// setSt
//       }),
//         // onTap: (ChatGroup chatGroup) => onChatGroupTap(context, chatGroup),
//         chatGroups: [],
//         // onLoadChatGroups: onLoadChatGroups,
//         // onLoadMoreChatGroups: onLoadMoreChatGroups,
//         stateCreator: () => MyChatScreenState(),
//         trailingActions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => onFindUserToChatTo(context),
//           )
//         ]);
//   }

//   void onChatGroupTap(BuildContext context, ChatGroup chatGroup) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 ConversationViewScreen(chatGroup: chatGroup)));
//   }

//   Future<List<ChatGroup>> onLoadChatGroups() async {
//     var allChatGroups = List.generate(numItmes, (i) {
//       return ChatGroup(
//         id: i.toString(),
//         groupName: faker.internet.userName(),
//         // contacts: allContacts.sublist(0, randomInt),
//         lastMessage: faker.lorem.sentence(),
//         date: faker.date.dateTime(),
//         seen: faker.randomGenerator.boolean(),
//       );
//     });

//     return allChatGroups;
//   }

//   Future<List<ChatGroup>> onLoadMoreChatGroups() async {
//     var allChatGroups = List.generate(numItmes, (i) {
//       // var randomInt = faker.randomGenerator.integer(20);
//       return ChatGroup(
//         id: i.toString(),
//         groupName: faker.internet.userName(),
//         // contacts: allContacts.sublist(0, randomInt),
//         lastMessage: faker.lorem.sentence(),
//         date: faker.date.dateTime(),
//         seen: faker.randomGenerator.boolean(),
//       );
//     });

//     return allChatGroups;
//   }

//   onFindUserToChatTo(BuildContext context) async {
//     Contact contactSelected = await Navigator.push(
//         context, MaterialPageRoute(builder: (context) => FindUserScreen()));
//   }
// }

// class MyChatScreenState extends ChatGroupListState {}
