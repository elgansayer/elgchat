import 'package:flutter/material.dart';

import 'bloc/chat_list_events.dart';
import 'elgchat.dart';
import 'selection_app_bar.dart';

class ArchivedChatRoomListState extends ElgChatRoomListState {
  List<ElgChatRoom> chatRooms;

  // archiveButton() {
  //   return Tooltip(
  //       message: 'Unarchive',
  //       child: IconButton(
  //           icon: Icon(Icons.unarchive),
  //           onPressed: () {
  //             this.logic.dispatch.add(ArchiveSelectedEvent());
  //             if (widget.onArchived != null) {

  //               widget.onArchived(selected);
  //             }
  //           }));
  // }

  @override
  void initState() {
    this.chatRooms =
        widget.chatRooms.where((element) => element.archived == true).toList();
    super.initState();
  }

  @override
  buildChatRoomsList(List<String> selectedChatIds) {
    return StreamBuilder<String>(
        stream: this.logic.searchChatRoomsStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // Ugly seach filter without rendering twice when chats update

          List<ElgChatRoom> visibleChats =
              searchFilterChats(this.chatRooms, snapshot.data);

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

  @override
  buildSelectionAppbar() {
    return ArchivedSelectionAppBar(
      initialData: this.logic.selectedChatRoomIds,
      chatRooms: chatRooms,
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
        // Now unarchived
        this.logic.dispatch.add(UnarchiveSelectedEvent(selected));
        if (widget.onArchived != null) {
          widget.onUnarchived(selected);
        }
        setState(() {
          selected.forEach((cg) {
            chatRooms.removeWhere((chatGrp) => chatGrp.id == cg.id);
          });
        });
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
}
