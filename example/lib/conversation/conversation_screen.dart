import 'package:elgchat/conversation_screen.dart';
import 'package:elgchat/models.dart';
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
  // User of the app
  final Contact user;
  // The elg chat information
  final ChatGroup chatGroup;
  // Users in the chat
  final List<Contact> receivers;

  ConversationViewScreen(
      {Key key,
      @required this.chatGroup,
      @required this.user,
      @required this.receivers})
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
              chatGroup: this.widget.chatGroup, userId: this.widget.user.id));
      },
      child: ConversationViewForm(
        chatMessages: chatMessages,
        user: this.widget.user,
        receivers: this.widget.receivers,
        // chatGroup: this.widget.chatGroup,
        title: this.widget.chatGroup.name,
      ),
    );
  }

  // ChatMessage genChat(String userId) {
  //   return new ChatMessage(
  //       id: Random().nextInt(1000).toString(),
  //       message: faker.lorem.sentence(),
  //       senderId: userId,
  //       created: DateTime.now());

  //   // setState(() {
  //   //   lastMsgCount = chatMessages.length;
  //   //   chatMessages.add(chatMessage);
  //   // });
  // }
}

class ConversationViewForm extends StatelessWidget {
  ConversationViewForm(
      {Key key,
      @required this.title,
      @required this.user,
      // @required this.chatGroup,
      @required this.chatMessages,
      @required this.receivers})
      : super(key: key);

  final String title;
  final Contact user;
  // final ChatGroup chatGroup;
  final List<ChatMessage> chatMessages;
  // Users in the chat
  final List<Contact> receivers;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationBloc, ConversationState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ConversationList(
            title: title,
            user: user,
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
        receivers: this.receivers));
  }
}
