import 'package:flutter/material.dart';

import 'models.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar(
      {Key key,
      this.contact,
      this.radius,
      this.backgroundColor,
      this.onTap,
      this.onLongPress})
      : super(key: key);
  final Contact contact;
  final double radius;
  final Color backgroundColor;

  final Function(Contact contact) onTap;
  final Function(Contact contact) onLongPress;

  @override
  Widget build(BuildContext context) {
    String photoUrl =
        this.contact.photoUrl != null && this.contact.photoUrl.isNotEmpty
            ? this.contact.photoUrl
            : 'https://picsum.photos/200/200';

    return InkWell(
      onTap: () => this.onTap != null ? this.onTap(this.contact) : null,
      onLongPress: () =>
          this.onLongPress != null ? this.onLongPress(this.contact) : null,
      child: CircleAvatar(
          radius: this.radius,
          backgroundColor: this.backgroundColor,
          backgroundImage: NetworkImage(photoUrl)),
    );
  }
}
