import 'package:elgchat/contact_avatar.dart';
import 'package:flutter/material.dart';

import 'models.dart';

const double kdefaultDecorationHeightOffset = 12.0;

class ElgUserSearchScreen extends StatelessWidget {
  const ElgUserSearchScreen({
    Key key,
    this.onUserSearch,
    this.onTap,
    this.onLongPress,
    this.contacts,
  }) : super(key: key);

  final Function(String value) onUserSearch;
  final List<ElgContact> contacts;
  final Function(ElgContact contact) onTap;
  final Function(ElgContact contact) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (String value) {
              this.onUserSearch(value);
            },
            autofocus: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(top: kdefaultDecorationHeightOffset),
              hintText: 'Search...',
            ),
          ),
        ),
        body: _buildBody());
  }

  _buildBody() {
    if (this.contacts == null) {
      return buildHasNoContacts();
    }

    return ListView.builder(
        itemCount: this.contacts.length,
        itemBuilder: (context, index) {
          return buildContact(this.contacts[index]);
        });
  }

  buildHasNoContacts() {
    return Container();
  }

  buildContact(ElgContact contact) {
    return ListTile(
        onTap: this.onTap != null ? () => this.onTap(contact) : null,
        onLongPress:
            this.onTap != null ? () => this.onLongPress(contact) : null,
        leading: ContactAvatar(contact: contact),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                contact.username,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }
}
