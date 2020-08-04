import 'package:equatable/equatable.dart';

enum ConversationState {
  loading,
  list,
  selection,
}

enum ChatListState {
  loading,
  list,
  // list_archived,
  selection,
}

class Contact extends Equatable {
  final String id;
  final String username;
  final String photoUrl;
  final DateTime lastOnline;
  final bool isActive;

  Contact(
      {this.id, this.username, this.photoUrl, this.lastOnline, this.isActive})
      : assert(id != null);

  @override
  List<Object> get props => [this.id];
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
      : assert(id != null),
        assert(groupName != null);

  ChatGroup copyWith(
      {String id,
      String groupName,
      String lastMessage,
      DateTime date,
      bool seen,
      String avatarUrl,
      bool selected,
      bool archived,
      bool muted,
      bool pinned}) {
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

abstract class ChatMessageProps {
  static const String collectionName = "messages";
  static const String mediaUrl = "mediaUrl";
  static const String id = "id";
  static const String message = "message";
  static const String creationDate = "creationDate";
  static const String userId = 'userId';
}

class ChatMessage extends Equatable {
  final String id;
  final String message;
  final DateTime creationDate;
  final String userId;
  final List<String> mediaUrls;
  final List<String> reactions;
  final bool selected;
  final bool starred;
  final bool deleted;

  ChatMessage(
      {this.reactions,
      this.selected = false,
      this.starred = false,
      this.deleted = false,
      this.mediaUrls,
      this.id,
      this.message,
      this.creationDate,
      this.userId})
      : assert(id != null),
        assert(userId != null),
        assert(message != null);

  ChatMessage copyWith({
    String id,
    String message,
    DateTime creationDate,
    String userId,
    List<String> mediaUrls,
    List<String> reactions,
    bool selected,
    bool starred,
    bool deleted,
  }) {
    return ChatMessage(
      reactions: reactions ?? this.reactions,
      selected: selected ?? this.selected,
      starred: starred ?? this.starred,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      id: id ?? this.id,
      message: message ?? this.message,
      creationDate: creationDate ?? this.creationDate,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  List<Object> get props => [this.id];
}
