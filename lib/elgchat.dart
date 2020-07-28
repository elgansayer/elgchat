library elgchat;

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:appbar_textfield/appbar_textfield.dart';
import 'package:flutter/material.dart';
import 'bloc/chat_list_events.dart';
import 'chat_list_bloc.dart';
import 'models.dart';

class ChatListScreen<TChatGroup extends ChatGroup> extends StatefulWidget {
  // State of the widgets view
  final List<TChatGroup> chatGroups;
  final VoidCallback onLoadMore;
  final ElgChatListScreenState Function() stateCreator;

  ChatListScreen({Key key, this.stateCreator, this.chatGroups, this.onLoadMore})
      : super(key: key);

  @override
  ElgChatListScreenState createState() {
    if (stateCreator == null) {
      return ElgChatListScreenState<TChatGroup>();
    } else {
      return this.stateCreator();
    }
  }
}

class ElgChatListScreenState<TChatGroup extends ChatGroup>
    extends State<ChatListScreen> {
  // The controller for the list view
  ScrollController _scrollController = new ScrollController();

  ChatListScreenLogic<ChatGroup> _bloc;

  static ElgChatListScreenState creator() {
    return new ElgChatListScreenState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _bloc = ChatListScreenLogic(widget.chatGroups, ChatState.loading);
    // _bloc.broadcast.add(SetChatGroupsEvent(widget.chatGroups));

    super.initState();
    _scrollController.addListener(scrollControllerListener);
  }

  void scrollControllerListener() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels > 1) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold();
  }

  buildScaffold() {
    return Scaffold(appBar: buildScaffoldAppBar(), body: buildScaffoldBody());
  }

  buildScaffoldAppBar() {
    return AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: null),
      title: StreamBuilder<List<TChatGroup>>(
          stream: this._bloc.selectedChatGroups,
          builder: (context, snapshot) {
            String selectedCount =
                snapshot.hasData ? snapshot.data.length.toString() : '0';
            return Text(selectedCount);
          }),
      actions: <Widget>[
        IconButton(icon: Icon(Icons.person_pin), onPressed: null),
        IconButton(icon: Icon(Icons.delete), onPressed: null),
        IconButton(icon: Icon(Icons.volume_mute), onPressed: null),
        IconButton(icon: Icon(Icons.archive), onPressed: null),
        IconButton(icon: Icon(Icons.markunread), onPressed: null),
        IconButton(icon: Icon(Icons.more_vert), onPressed: null),
      ],
    );

    return AppBarTextField(
      title: Text("Chat List"),
      trailingActionButtons: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: openNewChatScreen,
        )
      ],
    );
  }

  openNewChatScreen() {}
  buildScaffoldBody() {
    if (widget.chatGroups == null || widget.chatGroups.length <= 0) {
      return buildEmptyChatGroupList();
    } else {
      return buildChatGroupList();
    }
  }

  buildEmptyChatGroupList() {
    return Container();
  }

  buildChatGroupList() {
    return StreamBuilder<List<ChatGroup>>(
        stream: this._bloc.visibleChatGroups,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(child: Text("No chats found")),
            );
          }

          List<ChatGroup> visibleChats = snapshot.data;
          return ListView.builder(
            controller: _scrollController,
            itemCount: visibleChats.length,
            itemBuilder: (context, index) {
              return buildChatGroupTile(visibleChats[index]);
            },
          );
        });
  }

  buildChatGroupTile(TChatGroup chatGroup) {
    return Container(
      color: chatGroup.selected != null && chatGroup.selected
          ? Colors.blue[100]
          : null,
      child: ListTile(
        onTap: () => onChatGroupTileTap(chatGroup),
        onLongPress: () => onChatGroupTileLongPress(chatGroup),
        leading: buildChatGroupAvatar(chatGroup),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatGroup.groupName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            buildDateTime(chatGroup)
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatGroup.lastMessage,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            !chatGroup.seen ? buildNotSeen(chatGroup) : Container()
          ],
        ),
      ),
    );
  }

  Widget buildDateTime(TChatGroup chatGroup) {
    DateTime dateTime = chatGroup.date.toUtc();
    String dateString = formatDateString(dateTime);
    return Text(dateString, style: TextStyle(color: Colors.grey));
  }

  String formatDateString(DateTime dateTime) {
    Duration timeDifference = new DateTime.now().difference(dateTime);

    if (timeDifference.inDays < 1) {
      final fifteenAgo = new DateTime.now().subtract(timeDifference);
      return timeago.format(fifteenAgo, locale: 'en_short');
    } else {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(dateTime);
    }
  }

  Widget buildNotSeen(TChatGroup chatGroup) {
    return CircleAvatar(
      radius: 5,
    );
  }

  buildChatGroupAvatar(TChatGroup chatGroup) {
    return CircleAvatar(
      backgroundColor: chatGroup.selected != null && chatGroup.selected
          ? Colors.green
          : null,
      child: chatGroup.avatarUrl != null
          ? CachedNetworkImage(
              imageUrl: chatGroup.avatarUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )
          : Container(),
    );
  }

  onChatGroupTileTap(TChatGroup chatGroup) {
    print("onChatGroupTileTap");
    _bloc.broadcast.add(AddSelectedEvent(chatGroup));
  }

  onChatGroupTileLongPress(TChatGroup chatGroup) {
    print("onChatGroupTileLongPress");
    _bloc.broadcast.add(AddSelectedEvent(chatGroup));
  }
}

// class HomeBloc implements Searcher<String> {
//   final _filteredData = StreamController<List<String>>();

//   final dataList = [
//     'Thaís Fernandes',
//     'Thainá Santos',
//     'Gabrielly Costa',
//     'Gabriel Sousa',
//     'Luís Lima',
//     'Diego Assunção',
//     'Conceição Cardoso'
//   ];

//   Stream<List<String>> get filteredData => _filteredData.stream;

//   HomeBloc() {
//     _filteredData.add(dataList);
//   }

//   @override
//   get onDataFiltered => _filteredData.add;

//   @override
//   get data => dataList;

//   void dispose() {
//     _filteredData.close();
//   }
// }
