import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:appbar_textfield/appbar_textfield.dart';
import 'package:flutter/material.dart';
import 'archived_chat_list_bloc.dart';
import 'archived_chat_list_state.dart';
import 'bloc/chat_list_callback_events.dart';
import 'bloc/chat_list_events.dart';
import 'bloc/chat_list_bloc.dart';
import 'models.dart';
import 'user_search_screen.dart';

typedef LoadChatGroupsCallback<T extends ChatGroup> = Future<List<T>>
    Function();
typedef LoadMoreChatGroupsCallback<T extends ChatGroup> = Future<List<T>>
    Function();

class ChatGroupList<T extends ChatGroup, L extends ChatGroupListLogic<T>>
    extends StatefulWidget {
  // State of the widgets view
  // final LoadChatGroupsCallback onLoadChatGroups;
  // final LoadMoreChatGroupsCallback onLoadMoreChatGroups;
  final VoidCallback onLoadListAtEnd;

  final LoadMoreChatGroupsCallback onLoadMoreArchivedChatGroups;
  final String title;

  final ChatGroupListState Function() stateCreator;
  final ChatGroupListLogic Function() logicCreator;
  final ArchivedChatListScreenLogic Function() archiveLogicCreator;
  final ArchivedChatGroupListState Function() archiveStateCreator;

  // Fired when chat groups are unarchived
  final void Function(List<T> chatGroups) onUnarchived;
  // Fired when chat groups are deleted
  final void Function(List<T> chatGroups) onDeleted;
  // Fired when chat groups are archived
  final void Function(List<T> chatGroups) onArchived;
  // Fired when chat groups are marked seen
  final void Function(List<T> chatGroups) onMarkedSeen;
  // Fired when chat groups are pinned
  final void Function(List<T> chatGroups) onTogglePinned;
  // Fired when chat groups are muted
  final void Function(List<T> chatGroups) onToggleMuted;
  final void Function(T chatGroup) onSelected;
  final void Function(T chatGroup) onTap;

  final List<Widget> trailingActions;
  final List<Widget> leadingActions;
  final Widget floatingActionBar;

  // A reference to a mutatable list
  final List<T> chatGroupsRef;
  // Non-mutated list
  final List<T> chatGroups;

  ChatGroupList(
      {Key key,
      this.stateCreator,
      this.logicCreator,
      // this.onLoadChatGroups,
      this.onLoadListAtEnd,
      this.title = 'Chat list',
      this.archiveLogicCreator,
      this.archiveStateCreator,
      this.onUnarchived,
      this.onDeleted,
      this.onArchived,
      this.onMarkedSeen,
      this.onTogglePinned,
      this.onToggleMuted,
      this.onLoadMoreArchivedChatGroups,
      this.trailingActions,
      this.leadingActions,
      this.onSelected,
      this.onTap,
      this.chatGroupsRef,
      this.chatGroups,
      this.floatingActionBar})
      : super(key: key) {
    //  List<ChatGroup> chatGroups = await widget.onLoadChatGroups();
  }

  @override
  ChatGroupListState createState() {
    if (stateCreator == null) {
      return ChatGroupListState<T, L>();
    } else {
      return this.stateCreator();
    }
  }
}

class ChatGroupListState<T extends ChatGroup, L extends ChatGroupListLogic<T>>
    extends State<ChatGroupList> {
  // The controller for the list view
  ScrollController scrollController = new ScrollController();
  ChatGroupListLogic<ChatGroup> bloc;

  static ChatGroupListState creator() {
    return new ChatGroupListState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    this.bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollControllerListener);

    // Load first chat groups
    // this.initLoadChatGroups();
  }

  // void initLoadChatGroups() async {
  //   List<ChatGroup> chatGroups = await widget.onLoadChatGroups();
  //   bloc.dispatch.add(SetChatGroupsEvent(chatGroups));
  // }

  void loadMoreChatGroups() async {
    //
    if (widget.onLoadListAtEnd != null) {
      widget.onLoadListAtEnd();
    }

    // this.bloc.dispatch.add(AddChatGroupsEvent(chatGroups));
  }

  void scrollControllerListener() {
    if (scrollController.position.atEdge &&
        scrollController.position.pixels > 1) {
      this.loadMoreChatGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logicCreator == null && bloc == null) {
      bloc = ChatGroupListLogic();
    } else if (bloc == null) {
      bloc = widget.logicCreator();
    }

    //
    bloc.dispatch
        .add(SetChatGroupsEvent(widget.chatGroups, widget.chatGroupsRef));

    return StreamBuilder<ChatListCallbackEvent>(
        stream: this.bloc.callbackEventControllerStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            handleCallbackEvent(snapshot.data);
          }
          return buildScaffold();
        });
  }

  handleCallbackEvent(ChatListCallbackEvent event) {
    if (event is UnarchivedCallbackEvent) {
      if (widget.onUnarchived == null) {
        return;
      }
      widget.onUnarchived(event.chatGroups);
    }

    if (event is DeletedCallbackEvent) {
      if (widget.onDeleted == null) {
        return;
      }
      widget.onDeleted(event.chatGroups);
    }

    if (event is ToggleMutedCallbackEvent) {
      if (widget.onToggleMuted == null) {
        return;
      }
      widget.onToggleMuted(event.chatGroups);
    }

    if (event is TogglePinnedCallbackEvent) {
      if (widget.onTogglePinned == null) {
        return;
      }
      widget.onTogglePinned(event.chatGroups);
    }

    if (event is MarkedSeenCallbackEvent) {
      if (widget.onMarkedSeen == null) {
        return;
      }
      widget.onMarkedSeen(event.chatGroups);
    }

    if (event is ArchivedCallbackEvent) {
      if (widget.onArchived == null) {
        return;
      }
      widget.onArchived(event.chatGroups);
    }
  }

  buildScaffold() {
    return StreamBuilder<ChatListState>(
        stream: this.bloc.stateStream,
        builder: (context, snapshot) {
          return Scaffold(
              floatingActionButton: widget.floatingActionBar,
              appBar: buildScaffoldAppBar(snapshot.data),
              body: buildScaffoldBody(snapshot.data));
        });
  }

  buildScaffoldAppBar(ChatListState state) {
    if (state == null) {
      return AppBar(title: Text(widget.title));
    }

    if (state != ChatListState.selection) {
      return buildListAppBar();
    }

    return buildSelectionAppbar();
  }

  buildSelectionAppbar() {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            this.bloc.dispatch.add(SetStateEvent(ChatListState.list));
          }),
      title: StreamBuilder<List<T>>(
          stream: this.bloc.selectedChatGroupsStream,
          builder: (context, snapshot) {
            String selectedCount =
                snapshot.hasData ? snapshot.data.length.toString() : '1';
            return Text(selectedCount);
          }),
      actions: <Widget>[
        pinButton(),
        deleteButton(),
        muteToggleButton(),
        archiveButton(),
        markUnreadButton(),
        moreMenuButton()
      ],
    );
  }

  pinButton() {
    return Tooltip(
        message: 'Pin Toggle',
        child:
            IconButton(icon: Icon(Icons.person_pin), onPressed: pinSelected));
  }

  deleteButton() {
    return Tooltip(
        message: 'Delete',
        child: IconButton(icon: Icon(Icons.delete), onPressed: deleteSelected));
  }

  muteToggleButton() {
    return Tooltip(
        message: 'Mute Toggle',
        child:
            IconButton(icon: Icon(Icons.volume_mute), onPressed: muteSelected));
  }

  archiveButton() {
    return Tooltip(
        message: 'Archive',
        child:
            IconButton(icon: Icon(Icons.archive), onPressed: archiveSelected));
  }

  markUnreadButton() {
    return Tooltip(
        message: 'Mark Unread',
        child: IconButton(
            icon: Icon(Icons.markunread), onPressed: markSelectedUnread));
  }

  moreMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'SelectAll') {
          this.bloc.dispatch.add(SelectAllEvent());
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

  buildListAppBar() {
    return AppBarTextField(
      title: Text(widget.title),
      onChanged: (String phrase) {
        this.bloc.dispatch.add(SetSearchString(phrase));
      },
      onBackPressed: () {
        this.bloc.dispatch.add(ClearSearchString());
      },
      onClearPressed: () {
        this.bloc.dispatch.add(ClearSearchString());
      },
      leadingActionButtons: widget.leadingActions,
      trailingActionButtons: widget.trailingActions,
    );
  }

  muteSelected() {
    this.bloc.dispatch.add(MuteSelectedEvent());
  }

  archiveSelected() {
    this.bloc.dispatch.add(ArchiveSelectedEvent());
  }

  pinSelected() {
    this.bloc.dispatch.add(PinSelectedEvent());
  }

  deleteSelected() {
    this.bloc.dispatch.add(DeleteSelectedEvent());
  }

  markSelectedUnread() {
    this.bloc.dispatch.add(MarkSelectedUnreadEvent());
  }

  openNewChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserSearchScreen(
                onUserSearch: (String value) {
                  return [
                    Contact(
                      username: 'nodnol',
                      photoUrl: 'nodnol',
                      lastOnline: DateTime.now(),
                      isActive: false,
                    )
                  ];
                },
              )),
    );
  }

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
    return StreamBuilder<List<T>>(
        stream: this.bloc.visibleChatGroupsStream,
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
                  controller: scrollController,
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
    return StreamBuilder<List<T>>(
        stream: this.bloc.archivedChatGroupsStream,
        builder: (context, archivedSnapshot) {
          if (!archivedSnapshot.hasData || archivedSnapshot.data.length < 1) {
            return Container();
          }

          return ListTile(
            title: Text("Archived ${archivedSnapshot.data.length}"),
            onTap: () {
              // this._bloc.dispatch.add(ViewArchivedEvent());
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatGroupList<ChatGroup, ArchivedChatListScreenLogic>(
                          title: "Archived",
                          onUnarchived: (List<ChatGroup> unarchived) {
                            this.bloc.dispatch.add(UnArchivedEvent(unarchived));
                          },
                          onDeleted: (List<ChatGroup> unarchived) {
                            this
                                .bloc
                                .dispatch
                                .add(DeletedArchivedEvent(unarchived));
                          },
                          stateCreator: () {
                            if (widget.archiveStateCreator != null) {
                              return widget.archiveStateCreator();
                            } else {
                              return ArchivedChatGroupListState();
                            }
                          },
                          logicCreator: () {
                            if (widget.archiveLogicCreator != null) {
                              return widget.archiveLogicCreator();
                            } else {
                              return ArchivedChatListScreenLogic();
                            }
                          },
                          chatGroups: archivedSnapshot.data,
                          onLoadListAtEnd: () {
                            if (widget.onLoadListAtEnd != null) {
                              return widget.onLoadListAtEnd();
                            }
                          },
                        )),
              );
            },
          );
        });
  }

  buildChatGroupTile(T chatGroup) {
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

  Widget buildDateTime(T chatGroup) {
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

  Widget buildPinned(T chatGroup) {
    return Icon(Icons.person_pin, color: Colors.grey);
  }

  Widget buildMuted(T chatGroup) {
    return Icon(Icons.volume_mute, color: Colors.grey);
  }

  Widget buildNotSeen(T chatGroup) {
    return CircleAvatar(
      radius: 5,
    );
  }

  buildChatGroupAvatar(T chatGroup) {
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

  onChatGroupTileTap(T chatGroup) {
    if (this.bloc.currentState == ChatListState.selection) {
      this.bloc.dispatch.add(ToggleSelectedEvent(chatGroup));
      widget.onSelected(chatGroup);
    } else {
      widget.onTap(chatGroup);
    }
  }

  onChatGroupTileLongPress(T chatGroup) {
    this.bloc.dispatch.add(ToggleSelectedEvent(chatGroup));
  }
}
