import 'package:flutter/material.dart';

import 'models.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> initialData;

  const SelectionAppBar(
      {Key key,
      this.onBackPressed,
      this.selectedStream,
      this.popUpMenuSelected,
      this.pinSelected,
      this.deleteSelected,
      this.muteSelected,
      this.archiveSelected,
      this.markSelectedUnread,
      this.chatRooms, this.initialData})
      : super(key: key);

  final VoidCallback onBackPressed;
  final Stream<List<String>> selectedStream;
  final List<ElgChatRoom> chatRooms;
  final void Function(String value, List<ElgChatRoom> selected) popUpMenuSelected;
  final void Function(List<ElgChatRoom> selected) pinSelected;
  final void Function(List<ElgChatRoom> selected) deleteSelected;
  final void Function(List<ElgChatRoom> selected) muteSelected;
  final void Function(List<ElgChatRoom> selected) archiveSelected;
  final void Function(List<ElgChatRoom> selected) markSelectedUnread;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
        initialData: this.initialData,
        stream: this.selectedStream,
        builder: (context, snapshot) {
          String selectedCount =
              snapshot.hasData ? snapshot.data.length.toString() : '1';
          List<String> allSelected = snapshot.hasData ? snapshot.data : [];

          List<ElgChatRoom> selected = this
              .chatRooms
              .where((element) => allSelected.contains(element.id)).toList();

          return AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back), onPressed: onBackPressed),
            title: Text(selectedCount),
            actions: <Widget>[
              pinButton(selected),
              deleteButton(selected),
              muteToggleButton(selected),
              archiveButton(selected),
              markUnreadButton(selected),
              moreMenuButton(selected)
            ],
          );
        });
  }

  pinButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Pin Toggle',
        child: IconButton(
            icon: Icon(Icons.person_pin),
            onPressed: () {
              if (this.pinSelected != null) {
                List<ElgChatRoom> newData =
                    selected.map((e) => e.copyWith(pinned: !e.pinned)).toList();
                this.pinSelected(newData);
              }
            }));
  }

  deleteButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Delete',
        child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (this.deleteSelected != null) {
                this.deleteSelected(selected);
              }
            }));
  }

  muteToggleButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Mute Toggle',
        child: IconButton(
            icon: Icon(Icons.volume_mute),
            onPressed: () {
              // this.muteSelected(selected);
              if (this.muteSelected != null) {
                List<ElgChatRoom> newData =
                    selected.map((e) => e.copyWith(muted: !e.muted)).toList();
                this.muteSelected(newData);
              }
            }));
  }

  archiveButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Archive',
        child: IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              // this.archiveSelected(selected);
              if (this.archiveSelected != null) {
                List<ElgChatRoom> newData = selected
                    .map((e) => e.copyWith(archived: !e.archived))
                    .toList();
                this.archiveSelected(newData);
              }
            }));
  }

  markUnreadButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Mark Unread',
        child: IconButton(
            icon: Icon(Icons.markunread),
            onPressed: () {
              // this.markSelectedUnread(selected);
              if (this.markSelectedUnread != null) {
                List<ElgChatRoom> newData =
                    selected.map((e) => e.copyWith(read: false)).toList();
                this.markSelectedUnread(newData);
              }
            }));
  }

  moreMenuButton(List<ElgChatRoom> selected) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (this.popUpMenuSelected != null) {
          popUpMenuSelected(value, selected);
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

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ArchivedSelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> initialData;

  const ArchivedSelectionAppBar(
      {Key key,
      this.onBackPressed,
      this.selectedStream,
      this.popUpMenuSelected,
      this.pinSelected,
      this.deleteSelected,
      this.muteSelected,
      this.archiveSelected,
      this.markSelectedUnread,
      this.chatRooms, this.initialData})
      : super(key: key);

  final VoidCallback onBackPressed;
  final Stream<List<String>> selectedStream;
  final List<ElgChatRoom> chatRooms;
  final void Function(String value, List<ElgChatRoom> selected) popUpMenuSelected;
  final void Function(List<ElgChatRoom> selected) pinSelected;
  final void Function(List<ElgChatRoom> selected) deleteSelected;
  final void Function(List<ElgChatRoom> selected) muteSelected;
  final void Function(List<ElgChatRoom> selected) archiveSelected;
  final void Function(List<ElgChatRoom> selected) markSelectedUnread;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
        initialData: this.initialData,
        stream: this.selectedStream,
        builder: (context, snapshot) {
          String selectedCount =
              snapshot.hasData ? snapshot.data.length.toString() : '1';
          List<String> allSelected = snapshot.hasData ? snapshot.data : [];

          List<ElgChatRoom> selected = this
              .chatRooms
              .where((element) => allSelected.contains(element.id)).toList();

          return AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back), onPressed: onBackPressed),
            title: Text(selectedCount),
            actions: <Widget>[
              pinButton(selected),
              deleteButton(selected),
              muteToggleButton(selected),
              unarchiveButton(selected),
              markUnreadButton(selected),
              moreMenuButton(selected)
            ],
          );
        });
  }

  pinButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Pin Toggle',
        child: IconButton(
            icon: Icon(Icons.person_pin),
            onPressed: () {
              if (this.pinSelected != null) {
                List<ElgChatRoom> newData =
                    selected.map((e) => e.copyWith(pinned: !e.pinned)).toList();
                this.pinSelected(newData);
              }
            }));
  }

  deleteButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Delete',
        child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (this.deleteSelected != null) {
                this.deleteSelected(selected);
              }
            }));
  }

  muteToggleButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Mute Toggle',
        child: IconButton(
            icon: Icon(Icons.volume_mute),
            onPressed: () {
              // this.muteSelected(selected);
              if (this.muteSelected != null) {
                List<ElgChatRoom> newData =
                    selected.map((e) => e.copyWith(muted: !e.muted)).toList();
                this.muteSelected(newData);
              }
            }));
  }

  unarchiveButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Unarchive',
        child: IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              // this.archiveSelected(selected);
              if (this.archiveSelected != null) {
                List<ElgChatRoom> newData = selected
                    .map((e) => e.copyWith(archived: !e.archived))
                    .toList();
                this.archiveSelected(newData);
              }
            }));
  }

  markUnreadButton(List<ElgChatRoom> selected) {
    return Tooltip(
        message: 'Mark Unread',
        child: IconButton(
            icon: Icon(Icons.markunread),
            onPressed: () {
              // this.markSelectedUnread(selected);
              if (this.markSelectedUnread != null) {
                List<ElgChatRoom> newData =
                    selected.map((e) => e.copyWith(read: false)).toList();
                this.markSelectedUnread(newData);
              }
            }));
  }

  moreMenuButton(List<ElgChatRoom> selected) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (this.popUpMenuSelected != null) {
          popUpMenuSelected(value, selected);
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

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
