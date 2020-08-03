import 'dart:math';

import 'package:elgchat/conversation_screen.dart';
import 'package:elgchat/models.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

// class ConversationViewScreen extends StatelessWidget {
//   const ConversationViewScreen({Key key, @required this.chatGroup})
//       : super(key: key);
//   final ChatGroup chatGroup;
//   // final Contact contact;

//   @override
//   Widget build(BuildContext context) {
//     Contact contact = Contact(
//       id: "1",
//       username: 'nodnol',
//       photoUrl: 'nodnol',
//       lastOnline: DateTime.now(),
//       isActive: false,
//     );
//     return ConversationScreen(contact: contact
// chatMessages: ChatMessages,
// onNewChatMessage: ()
// {

// }
//     );
//   }
// }

class ConversationViewScreen extends StatefulWidget {
  ConversationViewScreen({Key key, ChatGroup chatGroup}) : super(key: key);

  @override
  _ConversationViewScreenState createState() => _ConversationViewScreenState();
}

class _ConversationViewScreenState extends State<ConversationViewScreen> {
  List<ChatMessage> chatMessages = new List<ChatMessage>();

  @override
  Widget build(BuildContext context) {
    Contact contact = Contact(
      id: "1",
      username: 'nodnol',
      photoUrl: 'nodnol',
      lastOnline: DateTime.now(),
      isActive: false,
    );
    return ConversationList(
        contact: contact,
        chatMessages: chatMessages,
        onNewChatMessage: _onNewChatMessage);
  }

  _onNewChatMessage() {
    setState(() {
      chatMessages.add(genChat('1'));
    });
  }

  ChatMessage genChat(String userId) {
    return new ChatMessage(
        id: Random().nextInt(1000).toString(),
        message: faker.lorem.sentence(),
        userId: userId,
        creationDate: DateTime.now());

    // setState(() {
    //   lastMsgCount = chatMessages.length;
    //   chatMessages.add(chatMessage);
    // });
  }
}
