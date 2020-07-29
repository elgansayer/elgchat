import 'package:flutter/material.dart';

import 'chat_list_bloc.dart';
import 'elgchat.dart';
import 'models.dart';

class ArchivedChatListScreenState<T extends ChatGroup,
    L extends ChatListScreenLogic<T>> extends ChatListScreenState<T, L> {
  archiveButton() {
    return Tooltip(
        message: 'Unarchive',
        child: IconButton(
            icon: Icon(Icons.unarchive), onPressed: archiveSelected));
  }
}
