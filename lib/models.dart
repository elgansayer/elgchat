import 'package:equatable/equatable.dart';

enum ChatListState {
  loading,
  list,
  selection,
}

class Contact {
  final String username;
  final String photoUrl;
  final DateTime lastOnline;
  final bool isActive;

  Contact({this.username, this.photoUrl, this.lastOnline, this.isActive});
}

class ChatGroup extends Equatable {
  final String id;
  final String groupName;
  final String lastMessage;
  final DateTime date;
  final bool seen;
  final String avatarUrl;
  final bool selected;
  final bool archived;
  final bool muted;
  final bool pinned;

  ChatGroup(
      {this.pinned = false,
      this.muted = false,
      this.archived = false,
      this.selected = false,
      this.avatarUrl,
      this.id,
      this.lastMessage,
      this.date,
      this.seen = false,
      this.groupName})
      : assert(id != null);

  ChatGroup copyWith({
    String id,
    String groupName,
    String lastMessage,
    DateTime date,
    bool seen,
    String avatarUrl,
    bool selected,
    bool archived,
    bool muted,
    bool pinned
  }) {
    return ChatGroup(
        muted: muted ?? this.muted,
        pinned: pinned ?? this.pinned,
        archived: archived ?? this.archived,
        selected: selected ?? this.selected,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        id: id ?? this.id,
        lastMessage: lastMessage ?? this.lastMessage,
        date: date ?? this.date,
        seen: seen ?? this.seen,
        groupName: groupName ?? this.groupName);
  }

  @override
  List<Object> get props => [this.id];
}
