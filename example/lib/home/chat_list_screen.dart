import 'package:elgchat/elgchat.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatelessWidget {
  int numItmes = 11;

  ChatListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatListScreen(
      onLoadChatGroups: onLoadChatGroups,
      onLoadMoreChatGroups: onLoadMoreChatGroups,
      stateCreator: () => MyChatScreenState(),
    );
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
}

class MyChatScreenState extends ChatListScreenState {}
