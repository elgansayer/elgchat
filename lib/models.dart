import 'package:equatable/equatable.dart';

enum ChatListState {
  loading,
  list,
  // list_archived,
  selection,
}

class Contact {
  final String id;
  final String username;
  final String photoUrl;
  final DateTime lastOnline;
  final bool isActive;

  Contact({this.id, this.username, this.photoUrl, this.lastOnline, this.isActive});
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

class ChatMessage {
  final String id;
  final String message;
  final DateTime creationDate;
  final String userId;
  final List<String> mediaUrls;

  ChatMessage(
      {this.mediaUrls, this.id, this.message, this.creationDate, this.userId});

  Map<String, dynamic> toMap() {
    return {
      ChatMessageProps.id: this.id,
      ChatMessageProps.mediaUrl: this.mediaUrls,
      ChatMessageProps.message: this.message,
      ChatMessageProps.creationDate: this.creationDate,
      ChatMessageProps.userId: this.userId,
    };
  }

  // factory ChatMessage.fromDocument(DocumentSnapshot document) {
  //   return ChatMessage.fromMap(document.data, document.documentID ?? "");
  // }

  // factory ChatMessage.fromJSON(Map data) {
  //   String id = data.containsKey(ChatMessageProps.id)
  //       ? data[ChatMessageProps.id].toString()
  //       : "";
  //   return ChatMessage.fromMap(data, id);
  // }

  // factory ChatMessage.fromMap(dynamic data, String documentID) {
  //   return ChatMessage(
  //       id: documentID,
  //       mediaUrls: Deets.getStrListParam<List<String>>(
  //           ChatMessageProps.mediaUrl, data, List<String>()),
  //       message: Deets.getParam<String>(ChatMessageProps.message, data, ""),
  //       creationDate: Deets.getTimeFromMap(ChatMessageProps.creationDate, data),
  //       userId: Deets.getParam<String>(ChatMessageProps.userId, data, ""));
  // }
}
