import 'package:elgchat/elgchat.dart';
import 'package:elgchat_example/conversation/conversation_screen.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'find_user_screen.dart';

class ChatListPage extends StatelessWidget {
  int numItmes = 11;

  ChatListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatListScreen(
        onTap: (ChatGroup chatGroup) => onChatGroupTap(context, chatGroup),
        onLoadChatGroups: onLoadChatGroups,
        onLoadMoreChatGroups: onLoadMoreChatGroups,
        stateCreator: () => MyChatScreenState(),
        trailingActions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => onFindUserToChatTo(context),
          )
        ]);
  }

  void onChatGroupTap(BuildContext context, ChatGroup chatGroup) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ConversationViewScreen(chatGroup: chatGroup)));
  }

  Future<List<ChatGroup>> onLoadChatGroups() async {
    var allChatGroups = List.generate(numItmes, (i) {
      return ChatGroup(
        id: i.toString(),
        groupName: faker.internet.userName(),
        // contacts: allContacts.sublist(0, randomInt),
        lastMessage: faker.lorem.sentence(),
        date: faker.date.dateTime(),
        seen: faker.randomGenerator.boolean(),
      );
    });

    return allChatGroups;
  }

  Future<List<ChatGroup>> onLoadMoreChatGroups() async {
    var allChatGroups = List.generate(numItmes, (i) {
      // var randomInt = faker.randomGenerator.integer(20);
      return ChatGroup(
        id: i.toString(),
        groupName: faker.internet.userName(),
        // contacts: allContacts.sublist(0, randomInt),
        lastMessage: faker.lorem.sentence(),
        date: faker.date.dateTime(),
        seen: faker.randomGenerator.boolean(),
      );
    });

    return allChatGroups;
  }

  onFindUserToChatTo(BuildContext context) async {
    Contact contactSelected = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => FindUserScreen()));
  }
}

class MyChatScreenState extends ChatListScreenState {}
