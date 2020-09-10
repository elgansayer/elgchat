import 'dart:math';

import 'package:elgchat/conversation_screen.dart';
import 'package:elgchat/models.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/conversation_bloc.dart';

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
  final Contact contact;
  final ChatGroup chatGroup;

  ConversationViewScreen(
      {Key key, @required this.chatGroup, @required this.contact})
      : super(key: key);

  @override
  _ConversationViewScreenState createState() => _ConversationViewScreenState();
}

class _ConversationViewScreenState extends State<ConversationViewScreen> {
  List<ChatMessage> chatMessages = new List<ChatMessage>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ConversationBloc()
          ..add(InitConversationEvent(
              chatGroup: this.widget.chatGroup,
              userId: this.widget.contact.id));
      },
      child: ConversationViewForm(
        chatMessages: chatMessages,
        contact: this.widget.contact,
        // chatGroup: this.widget.chatGroup,
        title: this.widget.chatGroup.name,
      ),
    );
  }

  ChatMessage genChat(String userId) {
    return new ChatMessage(
        id: Random().nextInt(1000).toString(),
        message: faker.lorem.sentence(),
        senderId: userId,
        created: DateTime.now());

    // setState(() {
    //   lastMsgCount = chatMessages.length;
    //   chatMessages.add(chatMessage);
    // });
  }
}

class ConversationViewForm extends StatelessWidget {
  ConversationViewForm(
      {Key key,
      @required this.title,
      @required this.contact,
      // @required this.chatGroup,
      @required this.chatMessages})
      : super(key: key);

  final String title;
  final Contact contact;
  // final ChatGroup chatGroup;
  final List<ChatMessage> chatMessages;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationBloc, ConversationState>(
      listener: (context, state) {

      },
      builder: (context, state) {
        return ConversationList(
            title: title,
            contact: contact,
            chatMessages: state.chatMessages,
            onNewChatMessage: (ChatMessage newMessage) =>
                _onNewChatMessage(newMessage, context));
      },
    );
  }

  void _onNewChatMessage(ChatMessage newChatMessage, BuildContext context) {
    BlocProvider.of<ConversationBloc>(context).add(NewMessageEvent(
        // chatGroup: chatGroup,
        newChatMessage: newChatMessage,
        receiverId: this.contact.id));
  }
}
