import 'package:flutter/material.dart';

import 'bloc/chat_list_events.dart';
import 'elgchat.dart';
import 'selection_app_bar.dart';

class ArchivedChatGroupListState extends ChatGroupListState {
  List<ChatGroup> chatGroups;

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
    this.chatGroups =
        widget.chatGroups.where((element) => element.archived == true).toList();
    super.initState();
  }

  @override
  buildChatGroupsList(List<String> selectedChatIds) {
    return StreamBuilder<String>(
        stream: this.logic.searchChatGroupsStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // Ugly seach filter without rendering twice when chats update

          List<ChatGroup> visibleChats =
              searchFilterChats(this.chatGroups, snapshot.data);

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
      initialData: this.logic.selectedChatGroupIds,
      chatGroups: chatGroups,
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
        // Now unarchived
        this.logic.dispatch.add(UnarchiveSelectedEvent(selected));
        if (widget.onArchived != null) {
          widget.onUnarchived(selected);
        }
        setState(() {
          selected.forEach((cg) {
            chatGroups.removeWhere((chatGrp) => chatGrp.id == cg.id);
          });
        });
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
}
