import 'package:equatable/equatable.dart';

enum ChatState {
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
  final bool isArchived;

  ChatGroup(
      {this.isArchived,
      this.selected,
      this.avatarUrl,
      this.id,
      this.lastMessage,
      this.date,
      this.seen,
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
    bool isArchived,
  }) {
    return ChatGroup(
        isArchived: isArchived ?? this.isArchived,
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
