import 'package:elgchat/conversation_screen.dart';
import 'package:elgchat/models.dart';
import 'package:flutter/material.dart';

class ConversationViewScreen extends StatelessWidget {
  const ConversationViewScreen({Key key, @required this.chatGroup})
      : super(key: key);
  final ChatGroup chatGroup;
  // final Contact contact;

  @override
  Widget build(BuildContext context) {
    Contact contact = Contact(
      id: "1",
      username: 'nodnol',
      photoUrl: 'nodnol',
      lastOnline: DateTime.now(),
      isActive: false,
    );
    return ConversationScreen(contact: contact);
  }
}
