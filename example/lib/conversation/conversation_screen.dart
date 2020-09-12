import 'package:elgchat/conversation_screen.dart';
import 'package:elgchat/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/conversation_bloc.dart';

// class ConversationViewScreen extends StatelessWidget {
//   const ConversationViewScreen({Key key, @required this.chatRoom})
//       : super(key: key);
//   final ChatRoom chatRoom;
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
  final ElgContact user;
  // The elg chat information
  final ElgChatRoom chatRoom;
  // Users in the chat
  final List<ElgContact> receivers;

  ConversationViewScreen(
      {Key key,
      @required this.chatRoom,
      @required this.user,
      @required this.receivers})
      : super(key: key);

  @override
  _ConversationViewScreenState createState() => _ConversationViewScreenState();
}

class _ConversationViewScreenState extends State<ConversationViewScreen> {
  List<ElgChatMessage> chatMessages = new List<ElgChatMessage>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ConversationBloc()
          ..add(InitConversationEvent(
              chatRoom: this.widget.chatRoom, userId: this.widget.user.id));
      },
      child: ConversationViewForm(
        chatMessages: chatMessages,
        user: this.widget.user,
        receivers: this.widget.receivers,
        // chatRoom: this.widget.chatRoom,
        title: this.widget.chatRoom.name,
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
      // @required this.chatRoom,
      @required this.chatMessages,
      @required this.receivers})
      : super(key: key);

  final String title;
  final ElgContact user;
  // final ChatRoom chatRoom;
  final List<ElgChatMessage> chatMessages;
  // Users in the chat
  final List<ElgContact> receivers;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationBloc, ConversationState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ElgConversationList(
            title: title,
            user: user,
            chatMessages: state.chatMessages,
            onNewChatMessage: (ElgChatMessage newMessage) =>
                _onNewChatMessage(newMessage, context));
      },
    );
  }

  void _onNewChatMessage(ElgChatMessage newChatMessage, BuildContext context) {
    BlocProvider.of<ConversationBloc>(context).add(NewMessageEvent(
        // chatRoom: chatRoom,
        newChatMessage: newChatMessage,
        receivers: this.receivers));
  }
}
