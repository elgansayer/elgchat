import 'package:elgchat/models.dart';
import 'package:elgchat/user_search_screen.dart';
import 'package:flutter/material.dart';

class FindUserScreen extends StatefulWidget {
  FindUserScreen({Key key}) : super(key: key);

  @override
  _FindUserScreenState createState() => _FindUserScreenState();
}

class _FindUserScreenState extends State<FindUserScreen> {
  List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    return UserSearchScreen(
      onTap: onTap,
      contacts: contacts,
      onUserSearch: (String value) {
        setState(() {
          contacts = [
            Contact(
              username: 'nodnol',
              photoUrl: 'nodnol',
              lastOnline: DateTime.now(),
              isActive: false,
            )
          ];
        });
      },
    );
  }

  onTap(Contact contact) {
    Navigator.of(context).pop(contact);
  }
}
