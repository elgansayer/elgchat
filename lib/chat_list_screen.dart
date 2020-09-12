import 'dart:async';

import 'package:appbar_textfield/appbar_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elgchat/chatroom_tile.dart';
import 'package:flutter/material.dart';
import 'archived_chat_list_state.dart';
import 'bloc/chat_list_events.dart';
import 'models.dart';
import 'selection_app_bar.dart';

extension selectedExtension on List<ElgChatRoom> {
  // List<ChatRoom> selected() {
  //   return this.where((element) => element.selected).toList();
  // }

  List<ElgChatRoom> pinned() {
    return this.where((element) => element.pinned).toList();
  }

  List<ElgChatRoom> archivedIs(bool value) {
    return this.where((element) => element.archived == value).toList();
  }
}

class ElgChatRoomList extends StatefulWidget {
  final VoidCallback onLoadListAtEnd;
  // final LoadMoreChatRoomsCallback onLoadMoreArchivedChatRooms;
  final String title;
  final ElgChatRoomListState Function() stateCreator;
  // final ChatRoomListLogic Function() logicCreator;
  // final ArchivedChatListScreenLogic Function() archiveLogicCreator;
  // final ArchivedChatRoomListState Function() archiveStateCreator;
  final void Function(List<ElgChatRoom> chatRooms) onUnarchived;
  final void Function(List<ElgChatRoom> chatRooms) onDeleted;
  final void Function(List<ElgChatRoom> chatRooms) onArchived;
  final void Function(List<ElgChatRoom> chatRooms) onMarkedUnread;
  final void Function(List<ElgChatRoom> chatRooms) onTogglePinned;
  final void Function(List<ElgChatRoom> chatRooms) onToggleMuted;
  final void Function(ElgChatRoom chatRoom) onSelected;
  final void Function(ElgChatRoom chatRoom) onTap;
  final void Function(ElgChatRoom chatRoom) onLongPress;

  final List<Widget> trailingActions;
  final List<Widget> leadingActions;
  final Widget floatingActionBar;
  // final List<T> chatRoomsRef;
  final List<ElgChatRoom> chatRooms;
  final ElgContact user;

  // Show archived chats only
  final bool showArchived;

  ElgChatRoomList(
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
      // this.onLoadMoreArchivedChatRooms,
      this.trailingActions,
      this.leadingActions,
      this.onSelected,
      this.onTap,
      // this.chatRoomsRef,
      this.chatRooms,
      this.floatingActionBar,
      this.onLongPress,
      this.showArchived = false})
      : assert(user != null),
        super(key: key);

  @override
  ElgChatRoomListState createState() {
    if (this.stateCreator != null) {
      return this.stateCreator();
    } else {
      return ElgChatRoomListState();
    }
  }
}

class ElgChatRoomListState extends State<ElgChatRoomList> {
  final ChatRoomListLogic logic = new ChatRoomListLogic();
  ScrollController scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    // logic.chatRooms = widget.chatRooms;

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
      initialData: this.logic.selectedChatRoomIds,
      chatRooms: widget.chatRooms,
      onBackPressed: () {
        this.logic.dispatch.add(SetStateEvent(ChatListState.list));
      },
      selectedStream: this.logic.selectedChatRoomsStream,
      popUpMenuSelected: (String value, List<ElgChatRoom> selected) {
        if (value == 'SelectAll') {
          this.logic.dispatch.add(SelectAllEvent());
        }
      },
      pinSelected: (List<ElgChatRoom> selected) {
        // widget.onTogglePinned(selected);
        this.logic.dispatch.add(PinSelectedEvent(selected));
        if (widget.onTogglePinned != null) {
          widget.onTogglePinned(selected);
        }
      },
      deleteSelected: (List<ElgChatRoom> selected) {
        // widget.onDeleted(selected);
        this.logic.dispatch.add(DeleteSelectedEvent(selected));
        if (widget.onDeleted != null) {
          widget.onDeleted(selected);
        }
      },
      muteSelected: (List<ElgChatRoom> selected) {
        // widget.onToggleMuted(selected);
        this.logic.dispatch.add(MuteSelectedEvent(selected));
        if (widget.onToggleMuted != null) {
          widget.onToggleMuted(selected);
        }
      },
      archiveSelected: (List<ElgChatRoom> selected) {
        // widget.onArchived(selected);
        this.logic.dispatch.add(ArchiveSelectedEvent(selected));
        if (widget.onArchived != null) {
          widget.onArchived(selected);
        }
      },
      markSelectedUnread: (List<ElgChatRoom> selected) {
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
        return buildChatRoomList();
        break;
      case ChatListState.loading:
      default:
        return buildLoading();
    }
  }

  buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  buildChatRoomList() {
    // return StreamBuilder<List<ChatRoom>>(
    //     initialData: widget.chatRooms,
    //     stream: this.logic.visibleChatRoomsStream,
    //     builder:
    //         (BuildContext context, AsyncSnapshot<List<ChatRoom>> snapshot) {
    //       if (!snapshot.hasData || snapshot.data.length == 0) {
    //         return Container(
    //           child: Center(child: Text("No chats found")),
    //         );
    //       }

    //       List<ChatRoom> visibleChats = snapshot.data;

    return StreamBuilder<List<String>>(
        initialData: [],
        stream: this.logic.selectedChatRoomsStream,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          List<String> selectedChatIds = snapshot.data;

          return Column(
            children: <Widget>[
              buildChatRoomsList(selectedChatIds),
              buildArchivedButton()
            ],
          );
        });
    // });
  }

  List<ElgChatRoom> archiveFilterChats(
      List<ElgChatRoom> chatRooms, bool showArchived) {
    return chatRooms.where((cg) => isArchived(cg) == showArchived).toList();
  }

  List<ElgChatRoom> searchFilterChats(
      List<ElgChatRoom> chatRooms, String searchPhrase) {
    if (searchPhrase == null) {
      return chatRooms;
    }

    return chatRooms
        .where((cg) => cg.name.toLowerCase().contains(searchPhrase))
        .toList();
  }

  buildChatRoomsList(List<String> selectedChatIds) {
    return StreamBuilder<String>(
        stream: this.logic.searchChatRoomsStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // Ugly seach filter without rendering twice when chats update

          // Strip archived
          List<ElgChatRoom> archiveVisibleChats =
              archiveFilterChats(widget.chatRooms, widget.showArchived);

          List<ElgChatRoom> visibleChats =
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

  Widget buildListTile(ElgChatRoom chatRoom, bool selected) {
    return ChatRoomTile(
      selected: selected,
      chatRoom: chatRoom,
      onChatRoomTileTap: onChatRoomTileTap,
      onChatRoomTileLongPress: onChatRoomTileLongPress,
      chatRoomAvatarBuilder: buildChatRoomAvatar,
    );
  }

  bool isArchived(ElgChatRoom chatRoom) {
    return (chatRoom.archived == true && chatRoom.read == true);
  }

  Widget buildArchivedButton() {
    int count =
        widget.chatRooms.where((chatRoom) => isArchived(chatRoom)).length;
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
            builder: (context) => ElgChatRoomList(
                user: widget.user,
                stateCreator: () {
                  return ArchivedChatRoomListState();
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
                chatRooms: widget.chatRooms,
                floatingActionBar: widget.floatingActionBar,
                onLongPress: widget.onLongPress,
                showArchived: true)));
  }

  void onChatRoomTileTap(ElgChatRoom chatRoom) {
    if (this.logic.currentState == ChatListState.selection) {
      this.logic.dispatch.add(ToggleSelectedEvent(chatRoom));
      // this.onSelected(chatRoom);

      if (widget.onSelected != null) {
        widget.onSelected(chatRoom);
      }
      // widget.onSelected(chatRoom);
    } else {
      // this.onTap(chatRoom);
      if (widget.onTap != null) {
        widget.onTap(chatRoom);
      }
    }
  }

  void onChatRoomTileLongPress(ElgChatRoom chatRoom) {
    this.logic.dispatch.add(ToggleSelectedEvent(chatRoom));
    if (widget.onLongPress != null) {
      widget.onLongPress(chatRoom);
    }
  }

  Widget buildChatRoomAvatar(ElgChatRoom chatRoom, bool selected) {
    Widget avatar = CircleAvatar(
      child: chatRoom.photoUrl != null && chatRoom.photoUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: chatRoom.photoUrl,
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

class ChatRoomListLogic {
  ChatListState currentState = ChatListState.loading;

  String searchPhrase;
  // List<ChatRoom> _chatRooms = new List<ChatRoom>();
  List<String> selectedChatRoomIds = new List<String>();

  ChatRoomListLogic() {
    eventController.stream.listen(handleGotEvent);
    listenToState();
  }

  // List<ChatRoom> get chatRooms => this._chatRooms;
  // set chatRooms(List<ChatRoom> chatRooms) {
  // this._chatRooms = chatRooms;

  //   bool selecting = chatRooms.any((cg) => cg.selected);
  //   if (selecting) {
  //     setStateEvent(SetStateEvent(ChatListState.selection));
  //   }

  //   visibleChatRoomsSink.add(this.chatRooms);
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
  //   chatRoomsStreamController.stream.listen((List<T> chatRooms) {
  //     // bool viewArchived = this.currentState == ChatListState.listarchived;
  //     // List<T> nonArchived = chatRooms.archivedIs(viewArchived);
  //     visibleChatRoomsStreamController.add(chatRooms);
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
      return unselectChatRooms(event.chatRooms);
    }

    if (event is ArchiveSelectedEvent) {
      return unselectChatRooms(event.chatRooms);
    }

    if (event is UnarchiveSelectedEvent) {
      return unselectChatRooms(event.chatRooms);
    }

    if (event is MarkSelectedUnreadEvent) {
      return unselectChatRooms(event.chatRooms);
    }

    if (event is PinSelectedEvent) {
      return unselectChatRooms(event.chatRooms);
    }

    // if (event is DeleteSelectedEvent) {
    //   return unselectChatRooms(event.chatRooms);;
    // }

    // if (event is SelectAllEvent) {
    //   return selectAllEvent();
    // }

    // if (event is UnArchivedEvent) {
    //   return unArchivedEvent(event);
    // }

    // if (event is DeletedArchivedEvent) {
    //   return unselectChatRooms(event.chatRooms);
    // }
  }

  // selectAllEvent() {
  //   // List<ChatRoom> allChats = this.chatRooms.map((cg) {
  //   //   return cg.copyWith(selected: true);
  //   // }).toList();

  //   // this.visibleChatRoomsSink.add(allChats);
  // }

  // deleteSelectedEvent() {
  //   // List<ChatRoom> allChats = this.chatRooms.map((cg) {
  //   //   bool selected = _selectedChatRooms.contains(cg);
  //   //   return cg.copyWith(deleted: selected);
  //   // }).toList();

  //   this.visibleChatRoomsSink.add([]);

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  // }

  // pinSelectedEvent() {
  //   List<ChatRoom> allChats = this.chatRooms.map((cg) {
  //     bool selected = _selectedChatRooms.contains(cg);

  //     if (selected) {
  //       return cg.copyWith(pinned: !cg.pinned);
  //     }

  //     return cg;
  //   }).toList();

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  //   this.visibleChatRoomsSink.add(allChats);
  // }

  // markSelectedUnreadEvent() {
  //   List<ChatRoom> allChats = this.chatRooms.map((cg) {
  //     bool selected = _selectedChatRooms.contains(cg);
  //     if (selected) {
  //       return cg.copyWith(read: false);
  //     }

  //     return cg;
  //   }).toList();

  //   this.visibleChatRoomsSink.add(allChats);
  // }

  // archiveSelectedEvent() {
  //   List<ChatRoom> allChats = this.chatRooms.map((cg) {
  //     // bool selected = _selectedChatRooms.contains(cg);
  //     int index = _selectedChatRooms.indexOf(cg);
  //     if (index > -1) {
  //       return cg.copyWith(archived: !cg.archived);
  //     }

  //     return cg;
  //   }).toList();

  //   this.visibleChatRoomsSink.add(allChats);

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  // }

  // muteSelectedEvent() {
  //   List<ChatRoom> allChats = this.chatRooms.map((cg) {
  //     bool selected = _selectedChatRooms.contains(cg);
  //     if (selected) {
  //       return cg.copyWith(muted: !cg.muted);
  //     }

  //     return cg;
  //   }).toList();

  //   this.visibleChatRoomsSink.add(allChats);

  //   unselectAll();
  //   stateStreamController.add(ChatListState.list);
  // }

  unselectChatRooms(List<ElgChatRoom> chatRooms) {
    selectedChatRoomIds.removeWhere((chatGrouPid) =>
        chatRooms.any((selectedCg) => selectedCg.id == chatGrouPid));

    if (selectedChatRoomIds.length > 0 &&
        this.currentState != ChatListState.selection) {
      stateStreamController.add(ChatListState.selection);
    } else if (selectedChatRoomIds.length <= 0 &&
        this.currentState != ChatListState.list) {
      stateStreamController.add(ChatListState.list);
    }

    this.selectedChatRoomsSink.add(selectedChatRoomIds);

    if (this.searchPhrase != null && this.searchPhrase.isNotEmpty) {
      clearSearchString();
    }
  }

  toggleSelectedEvent(ToggleSelectedEvent event) {
    // int index = this.chatRooms.indexOf(event.chatRoom);

    if (selectedChatRoomIds.contains(event.chatRoom.id)) {
      selectedChatRoomIds.remove(event.chatRoom.id);
    } else {
      selectedChatRoomIds.add(event.chatRoom.id);
    }

    if (selectedChatRoomIds.length > 0 &&
        this.currentState != ChatListState.selection) {
      stateStreamController.add(ChatListState.selection);
    } else if (selectedChatRoomIds.length <= 0 &&
        this.currentState != ChatListState.list) {
      stateStreamController.add(ChatListState.list);
    }

    // List<ChatRoom> allChats = this.chatRooms.map((cg) {
    //   bool selected = _selectedChatRooms.contains(cg);
    //   return cg.copyWith(selected: selected);
    // }).toList();

    // List<ChatRoom> allSelected = allChats.selected();

    // this.visibleChatRoomsSink.add(allChats);
    this.selectedChatRoomsSink.add(selectedChatRoomIds);

    if (this.searchPhrase != null && this.searchPhrase.isNotEmpty) {
      clearSearchString();
    }
  }

  clearSearchString() {
    // Runs through the visible filters
    // visibleChatRoomsSink.add(this.chatRooms);
    this.searchPhrase = '';
    searchChatRoomsSink.add(searchPhrase);
  }

  setSearchString(SetSearchString event) {
    this.searchPhrase = event.phrase;
    searchChatRoomsSink.add(searchPhrase);

    // List<ChatRoom> chatRooms = this
    //     .chatRooms
    //     .where((cg) => cg.name.toLowerCase().contains(event.phrase))
    //     .toList();

    // visibleChatRoomsSink.add(chatRooms);
  }

  unselectAll() {
    // visibleChatRoomsSink.add(this.chatRooms);
    selectedChatRoomsSink.add([]);
  }

  final stateStreamController = StreamController<ChatListState>.broadcast();
  StreamSink<ChatListState> get stateSink => stateStreamController.sink;
  Stream<ChatListState> get stateStream => stateStreamController.stream;
  setStateEvent(SetStateEvent event) {
    // currentState = event.state;
    stateSink.add(event.state);
  }

  final selectedStreamController = StreamController<List<String>>.broadcast();
  StreamSink<List<String>> get selectedChatRoomsSink =>
      selectedStreamController.sink;
  Stream<List<String>> get selectedChatRoomsStream =>
      selectedStreamController.stream;

  final eventController = StreamController<ChatListEvent>();
  Sink<ChatListEvent> get dispatch {
    return eventController.sink;
  }

  final searchStreamController = StreamController<String>.broadcast();
  StreamSink<String> get searchChatRoomsSink => searchStreamController.sink;
  Stream<String> get searchChatRoomsStream => searchStreamController.stream;

  // final visibleChatRoomsStreamController = StreamController<List<ChatRoom>>();
  // StreamSink<List<ChatRoom>> get visibleChatRoomsSink =>
  //     visibleChatRoomsStreamController.sink;
  // Stream<List<ChatRoom>> get visibleChatRoomsStream =>
  //     visibleChatRoomsStreamController.stream;

  void close() {
    // visibleChatRoomsStreamController.close();
    searchStreamController.close();
    selectedStreamController.close();
    eventController.close();
    stateStreamController.close();
  }
}
