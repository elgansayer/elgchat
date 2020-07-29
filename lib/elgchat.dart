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

typedef LoadChatGroupsCallback<T extends ChatGroup> = Future<List<T>>
    Function();
typedef LoadMoreChatGroupsCallback<T extends ChatGroup> = Future<List<T>>
    Function();

class ChatListScreen<TChatGroup extends ChatGroup> extends StatefulWidget {
  // State of the widgets view
  final LoadChatGroupsCallback onLoadChatGroups;
  final LoadMoreChatGroupsCallback onLoadMoreChatGroups;

  final ElgChatListScreenState Function() stateCreator;

  ChatListScreen(
      {Key key,
      this.stateCreator,
      this.onLoadChatGroups,
      this.onLoadMoreChatGroups})
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
    _bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _bloc = ChatListScreenLogic();

    super.initState();
    _scrollController.addListener(scrollControllerListener);

    // Load first chat groups
    this.initLoadChatGroups();
  }

  void initLoadChatGroups() async {
    List<ChatGroup> chatGroups = await widget.onLoadChatGroups();
    _bloc.dispatch.add(SetChatGroupsEvent(chatGroups));
  }

  void loadMoreChatGroups() async {
    List<ChatGroup> chatGroups = await widget.onLoadMoreChatGroups();
    _bloc.dispatch.add(AddChatGroupsEvent(chatGroups));
  }

  void scrollControllerListener() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels > 1) {
      this.loadMoreChatGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold();
  }

  buildScaffold() {
    return StreamBuilder<ChatListState>(
        stream: this._bloc.stateStream,
        builder: (context, snapshot) {
          return Scaffold(
              appBar: buildScaffoldAppBar(snapshot.data),
              body: buildScaffoldBody(snapshot.data));
        });
  }

  buildScaffoldAppBar(ChatListState state) {
    if (state == null) {
      return AppBar(title: Text("Chat List"));
    }

    if (state != ChatListState.selection) {
      return AppBarTextField(
        title: Text("Chat List"),
        onChanged: (String phrase) {
          this._bloc.dispatch.add(SetSearchString(phrase));
        },
        onBackPressed: () {
          this._bloc.dispatch.add(ClearSearchString());
        },
        onClearPressed: () {
          this._bloc.dispatch.add(ClearSearchString());
        },
        trailingActionButtons: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: openNewChatScreen,
          )
        ],
      );
    }

    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            this._bloc.dispatch.add(SetStateEvent(ChatListState.list));
          }),
      title: StreamBuilder<List<TChatGroup>>(
          stream: this._bloc.selectedChatGroupsStream,
          builder: (context, snapshot) {
            String selectedCount =
                snapshot.hasData ? snapshot.data.length.toString() : '1';
            return Text(selectedCount);
          }),
      actions: <Widget>[
        Tooltip(
            message: 'Pin Toggle',
            child: IconButton(
                icon: Icon(Icons.person_pin), onPressed: pinSelected)),
        Tooltip(
            message: 'Delete',
            child: IconButton(
                icon: Icon(Icons.delete), onPressed: deleteSelected)),
        Tooltip(
            message: 'Mute Toggle',
            child: IconButton(
                icon: Icon(Icons.volume_mute), onPressed: muteSelected)),
        Tooltip(
            message: 'Archive',
            child: IconButton(
                icon: Icon(Icons.archive), onPressed: archiveSelected)),
        Tooltip(
            message: 'Mark Unread',
            child: IconButton(
                icon: Icon(Icons.markunread), onPressed: markSelectedUnread)),
        moreMenuButton()
      ],
    );
  }

  moreMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'SelectAll') {
          this._bloc.dispatch.add(SelectAllEvent());
        }
      },
      child: Tooltip(message: 'More', child: Icon(Icons.more_vert)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'SelectAll',
          child: Text('Select All'),
        ),
      ],
    );
  }

  muteSelected() {
    this._bloc.dispatch.add(MuteSelectedEvent());
  }

  archiveSelected() {
    this._bloc.dispatch.add(ArchiveSelectedEvent());
  }

  pinSelected() {
    this._bloc.dispatch.add(PinSelectedEvent());
  }

  deleteSelected() {
    this._bloc.dispatch.add(DeleteSelectedEvent());
  }

  markSelectedUnread() {
    this._bloc.dispatch.add(MarkSelectedUnreadEvent());
  }

  openNewChatScreen() {}

  buildScaffoldBody(ChatListState state) {
    if (state == null) {
      return buildLoading();
    }

    switch (state) {
      case ChatListState.list:
      case ChatListState.selection:
        return buildChatGroupList();
        break;
      case ChatListState.loading:
      default:
        return buildLoading();
    }
  }

  buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  buildChatGroupList() {
    return StreamBuilder<List<TChatGroup>>(
        stream: this._bloc.visibleChatGroupsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(child: Text("No chats found")),
            );
          }

          List<ChatGroup> visibleChats = snapshot.data;
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: visibleChats.length,
                  itemBuilder: (context, index) {
                    return buildChatGroupTile(visibleChats[index]);
                  },
                ),
              ),
              buildArchivedButton()
            ],
          );
        });
  }

  buildArchivedButton() {
    return StreamBuilder<List<TChatGroup>>(
        stream: this._bloc.archivedChatGroupsStream,
        builder: (context, archivedSnapshot) {
          if (!archivedSnapshot.hasData || archivedSnapshot.data.length < 1) {
            return Container();
          }

          return ListTile(
            title: Text("Archived ${archivedSnapshot.data.length}"),
            onTap: () {},
          );
        });
  }

  buildChatGroupTile(TChatGroup chatGroup) {
    return Container(
      color: chatGroup.selected ? Colors.blue[100] : null,
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
            chatGroup.pinned ? buildPinned(chatGroup) : Container(),
            chatGroup.muted ? buildMuted(chatGroup) : Container(),
            chatGroup.seen != true ? buildNotSeen(chatGroup) : Container()
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

  Widget buildPinned(TChatGroup chatGroup) {
    return Icon(Icons.person_pin, color: Colors.grey);
  }

  Widget buildMuted(TChatGroup chatGroup) {
    return Icon(Icons.volume_mute, color: Colors.grey);
  }

  Widget buildNotSeen(TChatGroup chatGroup) {
    return CircleAvatar(
      radius: 5,
    );
  }

  buildChatGroupAvatar(TChatGroup chatGroup) {
    Widget avatar = CircleAvatar(
      child: chatGroup.avatarUrl != null
          ? CachedNetworkImage(
              imageUrl: chatGroup.avatarUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )
          : Container(),
    );

    if (!chatGroup.selected) {
      return avatar;
    }

    return Stack(
      children: <Widget>[
        avatar,
        Positioned.fill(
            child: Align(
          alignment: Alignment.bottomRight,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: 8,
            child: Icon(Icons.done, size: 13),
          ),
        ))
      ],
    );
  }

  onChatGroupTileTap(TChatGroup chatGroup) {
    if (this._bloc.currentState == ChatListState.selection) {
      _bloc.dispatch.add(ToggleSelectedEvent(chatGroup));
    }
  }

  onChatGroupTileLongPress(TChatGroup chatGroup) {
    _bloc.dispatch.add(ToggleSelectedEvent(chatGroup));
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
