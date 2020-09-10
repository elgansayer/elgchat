import 'dart:async';

import 'package:appbar_textfield/appbar_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elgchat/chatgroup_tile.dart';
import 'package:flutter/material.dart';
import 'archived_chat_list_state.dart';
import 'bloc/chat_list_events.dart';
import 'models.dart';
import 'selection_app_bar.dart';

extension selectedExtension on List<ChatGroup> {
  // List<ChatGroup> selected() {
  //   return this.where((element) => element.selected).toList();
  // }

  List<ChatGroup> pinned() {
    return this.where((element) => element.pinned).toList();
  }

  List<ChatGroup> archivedIs(bool value) {
    return this.where((element) => element.archived == value).toList();
  }
}

class ChatGroupList extends StatefulWidget {
  final VoidCallback onLoadListAtEnd;
  // final LoadMoreChatGroupsCallback onLoadMoreArchivedChatGroups;
  final String title;
  final ChatGroupListState Function() stateCreator;
  // final ChatGroupListLogic Function() logicCreator;
  // final ArchivedChatListScreenLogic Function() archiveLogicCreator;
  // final ArchivedChatGroupListState Function() archiveStateCreator;
  final void Function(List<ChatGroup> chatGroups) onUnarchived;
  final void Function(List<ChatGroup> chatGroups) onDeleted;
  final void Function(List<ChatGroup> chatGroups) onArchived;
  final void Function(List<ChatGroup> chatGroups) onMarkedUnread;
  final void Function(List<ChatGroup> chatGroups) onTogglePinned;
  final void Function(List<ChatGroup> chatGroups) onToggleMuted;
  final void Function(ChatGroup chatGroup) onSelected;
  final void Function(ChatGroup chatGroup) onTap;
  final void Function(ChatGroup chatGroup) onLongPress;

  final List<Widget> trailingActions;
  final List<Widget> leadingActions;
  final Widget floatingActionBar;
  // final List<T> chatGroupsRef;
  final List<ChatGroup> chatGroups;
  final Contact user;

  // Show archived chats only
  final bool showArchived;

  ChatGroupList(
      {Key key,
      @required this.user,
      this.stateCreator,
      // this.logicCreator,
      this.onLoadListAtEnd,
      this.title = 'Chat list',
      // this.archiveLogicCreator,
      // this.archiveStateCreator,
      this.onUnarchived,
      this.onDeleted,
      this.onArchived,
      this.onMarkedUnread,
      this.onTogglePinned,
      this.onToggleMuted,
      // this.onLoadMoreArchivedChatGroups,
      this.trailingActions,
      this.leadingActions,
      this.onSelected,
      this.onTap,
      // this.chatGroupsRef,
      this.chatGroups,
      this.floatingActionBar,
      this.onLongPress,
      this.showArchived = false})
      : assert(user != null),
        super(key: key);

  @override
  ChatGroupListState createState() {
    if (this.stateCreator != null) {
      return this.stateCreator();
    } else {
      return ChatGroupListState();
    }
  }
}

class ChatGroupListState extends State<ChatGroupList> {
  final ChatGroupListLogic logic = new ChatGroupListLogic();
  ScrollController scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    // logic.chatGroups = widget.chatGroups;

    return StreamBuilder<ChatListState>(
      stream: this.logic.stateStream,
      builder: (context, snapshot) {
        return Scaffold(
            floatingActionButton: widget.floatingActionBar,
            appBar: buildScaffoldAppBar(snapshot.data),
            body: buildScaffoldBody(snapshot.data));
      },
      initialData: ChatListState.list,
    );
  }

  buildListAppBar() {
    return AppBarTextField(
      title: Text(widget.title),
      onChanged: (String phrase) {
        this.logic.dispatch.add(SetSearchString(phrase));
      },
      onBackPressed: () {
        this.logic.dispatch.add(ClearSearchString());
      },
      onClearPressed: () {
        this.logic.dispatch.add(ClearSearchString());
      },
      leadingActionButtons: widget.leadingActions,
      trailingActionButtons: widget.trailingActions,
    );
  }

  buildScaffoldAppBar(ChatListState state) {
    if (state != ChatListState.selection) {
      return buildListAppBar();
    }

    return buildSelectionAppbar();
  }

  buildSelectionAppbar() {
    return SelectionAppBar(
      initialData: this.logic.selectedChatGroupIds,
      chatGroups: widget.chatGroups,
      onBackPressed: () {
        this.logic.dispatch.add(SetStateEvent(ChatListState.list));
      },
      selectedStream: this.logic.selectedChatGroupsStream,
      popUpMenuSelected: (String value, List<ChatGroup> selected) {
        if (value == 'SelectAll') {
          this.logic.dispatch.add(SelectAllEvent());
        }
      },
      pinSelected: (List<ChatGroup> selected) {
        // widget.onTogglePinned(selected);
        this.logic.dispatch.add(PinSelectedEvent(selected));
        if (widget.onTogglePinned != null) {
          widget.onTogglePinned(selected);
        }
      },
      deleteSelected: (List<ChatGroup> selected) {
        // widget.onDeleted(selected);
        this.logic.dispatch.add(DeleteSelectedEvent(selected));
        if (widget.onDeleted != null) {
          widget.onDeleted(selected);
        }
      },
      muteSelected: (List<ChatGroup> selected) {
        // widget.onToggleMuted(selected);
        this.logic.dispatch.add(MuteSelectedEvent(selected));
        if (widget.onToggleMuted != null) {
          widget.onToggleMuted(selected);
        }
      },
      archiveSelected: (List<ChatGroup> selected) {
        // widget.onArchived(selected);
        this.logic.dispatch.add(ArchiveSelectedEvent(selected));
        if (widget.onArchived != null) {
          widget.onArchived(selected);
        }
      },
      markSelectedUnread: (List<ChatGroup> selected) {
        // widget.onMarkedUnread(selected);
        this.logic.dispatch.add(MarkSelectedUnreadEvent(selected));
        if (widget.onMarkedUnread != null) {
          widget.onMarkedUnread(selected);
        }
      },
    );
  }

  buildScaffoldBody(ChatListState state) {
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
    // return StreamBuilder<List<ChatGroup>>(
    //     initialData: widget.chatGroups,
    //     stream: this.logic.visibleChatGroupsStream,
    //     builder:
    //         (BuildContext context, AsyncSnapshot<List<ChatGroup>> snapshot) {
    //       if (!snapshot.hasData || snapshot.data.length == 0) {
    //         return Container(
    //           child: Center(child: Text("No chats found")),
    //         );
    //       }

    //       List<ChatGroup> visibleChats = snapshot.data;

    return StreamBuilder<List<String>>(
        initialData: [],
        stream: this.logic.selectedChatGroupsStream,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          List<String> selectedChatIds = snapshot.data;

          return Column(
            children: <Widget>[
              buildChatGroupsList(selectedChatIds),
              buildArchivedButton()
            ],
          );
        });
    // });
  }

  List<ChatGroup> archiveFilterChats(
      List<ChatGroup> chatGroups, bool showArchived) {
    return chatGroups.where((cg) => isArchived(cg) == showArchived).toList();
  }

  List<ChatGroup> searchFilterChats(
      List<ChatGroup> chatGroups, String searchPhrase) {
    if (searchPhrase == null) {
      return chatGroups;
    }

    return chatGroups
        .where((cg) => cg.name.toLowerCase().contains(searchPhrase))
        .toList();
  }

  buildChatGroupsList(List<String> selectedChatIds) {
    return StreamBuilder<String>(
        stream: this.logic.searchChatGroupsStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // Ugly seach filter without rendering twice when chats update

          // Strip archived
          List<ChatGroup> archiveVisibleChats =
              archiveFilterChats(widget.chatGroups, widget.showArchived);

          List<ChatGroup> visibleChats =
              searchFilterChats(archiveVisibleChats, snapshot.data);

          return Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: visibleChats.length,
              itemBuilder: (context, index) {
                return buildListTile(visibleChats[index],
                    selectedChatIds.contains(visibleChats[index].id));
              },
            ),
          );
        });
  }

  Widget buildListTile(ChatGroup chatGroup, bool selected) {
    return ChatGroupTile(
      selected: selected,
      chatGroup: chatGroup,
      onChatGroupTileTap: onChatGroupTileTap,
      onChatGroupTileLongPress: onChatGroupTileLongPress,
      chatGroupAvatarBuilder: buildChatGroupAvatar,
    );
  }

  bool isArchived(ChatGroup chatGroup) {
    return (chatGroup.archived == true && chatGroup.read == true);
  }

  Widget buildArchivedButton() {
    int count =
        widget.chatGroups.where((chatGroup) => isArchived(chatGroup)).length;
    if (count == 0 || widget.showArchived) {
      return Container();
    }

    return Card(
      child: ListTile(
          onTap: () {
            openArchivedScreen();
          },
          dense: true,
          leading: Icon(Icons.archive),
          title: Text("$count Archived")),
    );
  }

  void openArchivedScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatGroupList(
                user: widget.user,
                stateCreator: () {
                  return ArchivedChatGroupListState();
                },
                onLoadListAtEnd: widget.onLoadListAtEnd,
                title: "Archived",
                onUnarchived: widget.onUnarchived,
                onDeleted: widget.onDeleted,
                onArchived: widget.onArchived,
                onMarkedUnread: widget.onMarkedUnread,
                onTogglePinned: widget.onTogglePinned,
                onToggleMuted: widget.onToggleMuted,
                trailingActions: widget.trailingActions,
                leadingActions: widget.leadingActions,
                onSelected: widget.onSelected,
                onTap: widget.onTap,
                chatGroups: widget.chatGroups,
                floatingActionBar: widget.floatingActionBar,
                onLongPress: widget.onLongPress,
                showArchived: true)));
  }

  void onChatGroupTileTap(ChatGroup chatGroup) {
    if (this.logic.currentState == ChatListState.selection) {
      this.logic.dispatch.add(ToggleSelectedEvent(chatGroup));
      // this.onSelected(chatGroup);

      if (widget.onSelected != null) {
        widget.onSelected(chatGroup);
      }
      // widget.onSelected(chatGroup);
    } else {
      // this.onTap(chatGroup);
      if (widget.onTap != null) {
        widget.onTap(chatGroup);
      }
    }
  }

  void onChatGroupTileLongPress(ChatGroup chatGroup) {
    this.logic.dispatch.add(ToggleSelectedEvent(chatGroup));
    if (widget.onLongPress != null) {
      widget.onLongPress(chatGroup);
    }
  }

  Widget buildChatGroupAvatar(ChatGroup chatGroup, bool selected) {
    Widget avatar = CircleAvatar(
      child: chatGroup.photoUrl != null && chatGroup.photoUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: chatGroup.photoUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            )
          : Container(),
    );

    if (!selected) {
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
}

class ChatGroupListLogic {
  ChatListState currentState = ChatListState.loading;

  String searchPhrase;
  // List<ChatGroup> _chatGroups = new List<ChatGroup>();
  List<String> selectedChatGroupIds = new List<String>();

  ChatGroupListLogic() {
    eventController.stream.listen(handleGotEvent);
    listenToState();
  }

  // List<ChatGroup> get chatGroups => this._chatGroups;
  // set chatGroups(List<ChatGroup> chatGroups) {
  // this._chatGroups = chatGroups;

  //   bool selecting = chatGroups.any((cg) => cg.selected);
  //   if (selecting) {
  //     setStateEvent(SetStateEvent(ChatListState.selection));
  //   }

  //   visibleChatGroupsSink.add(this.chatGroups);
  // }

  listenToState() {
    stateStreamController.stream.listen((ChatListState newState) {
      if (currentState == ChatListState.selection &&
          newState != ChatListState.selection) {
        unselectAll();
      }
      currentState = newState;
    });
  }

  // listenToChatsStream() {
  //   chatGroupsStreamController.stream.listen((List<T> chatGroups) {
  //     // bool viewArchived = this.currentState == ChatListState.listarchived;
  //     // List<T> nonArchived = chatGroups.archivedIs(viewArchived);
  //     visibleChatGroupsStreamController.add(chatGroups);
  //   });
  // }

  handleGotEvent(ChatListEvent event) {
    if (event is SetStateEvent) {
      return setStateEvent(event);
    }

    //** Search Events */
    if (event is SetSearchString) {
      return setSearchString(event);
    }

    if (event is ClearSearchString) {
      return clearSearchString();
    }

    // Selected events
    if (event is ToggleSelectedEvent) {
      return toggleSelectedEvent(event);
    }

// PinSelectedEvent
// DeleteSelectedEvent
// MuteSelectedEvent
// ArchiveSelectedEvent
// MarkSelectedUnreadEvent

    if (event is MuteSelectedEvent) {
      return unselectChatGroups(event.chatGroups);
    }

    if (event is ArchiveSelectedEvent) {
      return unselectChatGroups(event.chatGroups);
    }

    if (event is UnarchiveSelectedEvent) {
      return unselectChatGroups(event.chatGroups);
    }

    if (event is MarkSelectedUnreadEvent) {
      return unselectChatGroups(event.chatGroups);
    }

    if (event is PinSelectedEvent) {
      return unselectChatGroups(event.chatGroups);
    }

    // if (event is DeleteSelectedEvent) {
    //   return unselectChatGroups(event.chatGroups);;
    // }

    // if (event is SelectAllEvent) {
    //   return selectAllEvent();
    // }

    // if (event is UnArchivedEvent) {
    //   return unArchivedEvent(event);
    // }

    // if (event is DeletedArchivedEvent) {
    //   return unselectChatGroups(event.chatGroups);
    // }
  }

  // selectAllEvent() {
  //   // List<ChatGroup> allChats = this.chatGroups.map((cg) {
  //   //   return cg.copyWith(selected: true);
  //   // }).toList();

  //   // this.visibleChatGroupsSink.add(allChats);
  // }

  // deleteSelectedEvent() {
  //   // List<ChatGroup> allChats = this.chatGroups.map((cg) {
  //   //   bool selected = _selectedChatGroups.contains(cg);
  //   //   return cg.copyWith(deleted: selected);
  //   // }).toList();

  //   this.visibleChatGroupsSink.add([]);

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  // }

  // pinSelectedEvent() {
  //   List<ChatGroup> allChats = this.chatGroups.map((cg) {
  //     bool selected = _selectedChatGroups.contains(cg);

  //     if (selected) {
  //       return cg.copyWith(pinned: !cg.pinned);
  //     }

  //     return cg;
  //   }).toList();

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  //   this.visibleChatGroupsSink.add(allChats);
  // }

  // markSelectedUnreadEvent() {
  //   List<ChatGroup> allChats = this.chatGroups.map((cg) {
  //     bool selected = _selectedChatGroups.contains(cg);
  //     if (selected) {
  //       return cg.copyWith(read: false);
  //     }

  //     return cg;
  //   }).toList();

  //   this.visibleChatGroupsSink.add(allChats);
  // }

  // archiveSelectedEvent() {
  //   List<ChatGroup> allChats = this.chatGroups.map((cg) {
  //     // bool selected = _selectedChatGroups.contains(cg);
  //     int index = _selectedChatGroups.indexOf(cg);
  //     if (index > -1) {
  //       return cg.copyWith(archived: !cg.archived);
  //     }

  //     return cg;
  //   }).toList();

  //   this.visibleChatGroupsSink.add(allChats);

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  // }

  // muteSelectedEvent() {
  //   List<ChatGroup> allChats = this.chatGroups.map((cg) {
  //     bool selected = _selectedChatGroups.contains(cg);
  //     if (selected) {
  //       return cg.copyWith(muted: !cg.muted);
  //     }

  //     return cg;
  //   }).toList();

  //   this.visibleChatGroupsSink.add(allChats);

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  // }

  unselectChatGroups(List<ChatGroup> chatGroups) {
    selectedChatGroupIds.removeWhere((chatGrouPid) =>
        chatGroups.any((selectedCg) => selectedCg.id == chatGrouPid));

    if (selectedChatGroupIds.length > 0 &&
        this.currentState != ChatListState.selection) {
      stateStreamController.add(ChatListState.selection);
    } else if (selectedChatGroupIds.length <= 0 &&
        this.currentState != ChatListState.list) {
      stateStreamController.add(ChatListState.list);
    }

    this.selectedChatGroupsSink.add(selectedChatGroupIds);

    if (this.searchPhrase != null && this.searchPhrase.isNotEmpty) {
      clearSearchString();
    }
  }

  toggleSelectedEvent(ToggleSelectedEvent event) {
    // int index = this.chatGroups.indexOf(event.chatGroup);

    if (selectedChatGroupIds.contains(event.chatGroup.id)) {
      selectedChatGroupIds.remove(event.chatGroup.id);
    } else {
      selectedChatGroupIds.add(event.chatGroup.id);
    }

    if (selectedChatGroupIds.length > 0 &&
        this.currentState != ChatListState.selection) {
      stateStreamController.add(ChatListState.selection);
    } else if (selectedChatGroupIds.length <= 0 &&
        this.currentState != ChatListState.list) {
      stateStreamController.add(ChatListState.list);
    }

    // List<ChatGroup> allChats = this.chatGroups.map((cg) {
    //   bool selected = _selectedChatGroups.contains(cg);
    //   return cg.copyWith(selected: selected);
    // }).toList();

    // List<ChatGroup> allSelected = allChats.selected();

    // this.visibleChatGroupsSink.add(allChats);
    this.selectedChatGroupsSink.add(selectedChatGroupIds);

    if (this.searchPhrase != null && this.searchPhrase.isNotEmpty) {
      clearSearchString();
    }
  }

  clearSearchString() {
    // Runs through the visible filters
    // visibleChatGroupsSink.add(this.chatGroups);
    this.searchPhrase = '';
    searchChatGroupsSink.add(searchPhrase);
  }

  setSearchString(SetSearchString event) {
    this.searchPhrase = event.phrase;
    searchChatGroupsSink.add(searchPhrase);

    // List<ChatGroup> chatGroups = this
    //     .chatGroups
    //     .where((cg) => cg.name.toLowerCase().contains(event.phrase))
    //     .toList();

    // visibleChatGroupsSink.add(chatGroups);
  }

  unselectAll() {
    // visibleChatGroupsSink.add(this.chatGroups);
    selectedChatGroupsSink.add([]);
  }

  final stateStreamController = StreamController<ChatListState>.broadcast();
  StreamSink<ChatListState> get stateSink => stateStreamController.sink;
  Stream<ChatListState> get stateStream => stateStreamController.stream;
  setStateEvent(SetStateEvent event) {
    // currentState = event.state;
    stateSink.add(event.state);
  }

  final selectedStreamController = StreamController<List<String>>.broadcast();
  StreamSink<List<String>> get selectedChatGroupsSink =>
      selectedStreamController.sink;
  Stream<List<String>> get selectedChatGroupsStream =>
      selectedStreamController.stream;

  final eventController = StreamController<ChatListEvent>();
  Sink<ChatListEvent> get dispatch {
    return eventController.sink;
  }

  final searchStreamController = StreamController<String>.broadcast();
  StreamSink<String> get searchChatGroupsSink => searchStreamController.sink;
  Stream<String> get searchChatGroupsStream => searchStreamController.stream;

  // final visibleChatGroupsStreamController = StreamController<List<ChatGroup>>();
  // StreamSink<List<ChatGroup>> get visibleChatGroupsSink =>
  //     visibleChatGroupsStreamController.sink;
  // Stream<List<ChatGroup>> get visibleChatGroupsStream =>
  //     visibleChatGroupsStreamController.stream;

  void close() {
    // visibleChatGroupsStreamController.close();
    searchStreamController.close();
    selectedStreamController.close();
    eventController.close();
    stateStreamController.close();
  }
}
