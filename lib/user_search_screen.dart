import 'package:flutter/material.dart';

const double kdefaultDecorationHeightOffset = 12.0;

class UserSearchScreen extends StatelessWidget {
  const UserSearchScreen({Key key, this.onUserSearch}) : super(key: key);
  final Function onUserSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: () {
            var getAllData = this.onUserSearch();

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
    );
  }
}
