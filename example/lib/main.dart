import 'package:elgchat/models.dart';
import 'package:flutter/material.dart';
import 'package:elgchat/elgchat.dart';
import 'package:faker/faker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int numItmes = 11;

  @override
  Widget build(BuildContext context) {
    // var allContacts = List.generate(22, (i) {
    //   return Contact(
    //     username: faker.internet.userName(),
    //     photoUrl: "",
    //     lastOnline: faker.date.dateTime(),
    //     isActive: faker.randomGenerator.boolean(),
    //   );
    // });

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

    return MaterialApp(
      title: 'ElgChat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatListScreen(
        onLoadMore: onLoadMore,
        chatGroups: allChatGroups,
        stateCreator: () => MyChatScreenState(),
      ),
    );
  }

  void onLoadMore() {
    setState(() {
      numItmes += 11;
    });
  }
}

class MyChatScreenState extends ElgChatListScreenState {}
