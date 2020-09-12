import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ConversationLogicState {
  loading,
  list,
  selection,
}

enum ChatListState {
  loading,
  list,
  selection,
}

class ElgContact extends Equatable {
  final String id;
  final String username;
  final String photoUrl;
  final DateTime lastOnline;
  final bool isActive;

  ElgContact(
      {@required this.id,
      this.username,
      this.photoUrl,
      this.lastOnline,
      this.isActive})
      : assert(id != null);

  @override
  List<Object> get props => [this.id];
}

abstract class ChatRoomProps {
  static const String id = "id";
  static const String name = "name";
  static const String photoUrl = "photoUrl";
  static const String lastMessage = "lastMessage";
  static const String created = "created";
  static const String updated = "updated";

  // static const String readBy = "readBy";
  static const String read = "read";
  static const String receiverIds = "receiverIds";
  static const String creatorId = "creatorId";

  // static const String selected = "selected";
  static const String archived = "archived";
  static const String muted = "muted";
  static const String pinned = "pinned";
}

class ElgChatRoom extends Equatable {
  final String id;
  final String name;
  final String photoUrl;
  final String lastMessage;
  final String creatorId;
  final DateTime created;
  final DateTime updated;
  // final List<String> readBy;
  // final List<String> userIds;

  // If a user was in seen
  // final bool seen;
  // final bool selected;
  final bool archived;
  final bool muted;
  final bool pinned;
  final bool read;

  ElgChatRoom(
      {this.read = false,
      this.creatorId,
      this.updated,
      // this.userIds,
      this.pinned = false,
      this.muted = false,
      this.archived = false,
      // this.selected = false,
      this.photoUrl,
      this.id,
      this.lastMessage,
      this.created,
      // this.readBy = const [],
      this.name})
      : assert(id != null),
        assert(name != null);

  ElgChatRoom copyWith({
    String id,
    String name,
    String lastMessage,
    DateTime date,
    String photoUrl,
    // bool selected,
    bool archived,
    bool muted,
    bool pinned,
    bool read,
    String creatorId,
    DateTime updated,
    // List<String> seenBy,
    // List<String> userIds
  }) {
    return ElgChatRoom(
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      // selected: selected ?? this.selected,
      photoUrl: photoUrl ?? this.photoUrl,
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      created: date ?? this.created,
      // readBy: seenBy ?? this.readBy,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      updated: updated ?? this.updated,
      read: read ?? this.read,
      // userIds: userIds ?? this.userIds
    );
  }

  // bool read(String userId) {
  //   if (userId.compareTo(this.creatorId) == 0) {
  //     return true;
  //   }

  //   return readBy.contains(userId);
  // }

  @override
  List<Object> get props => [this.id];
}

abstract class ChatMessageProps {
  static const String id = "id";
  static const String message = "message";
  static const String created = "created";
  static const String senderId = "senderId";
  static const String mediaUrls = "mediaUrls";
  static const String reactions = "reactions";
  static const String starred = "starred";
  static const String deleted = "deleted";
}

class ElgChatMessage extends Equatable {
  final String id;
  final String message;
  final DateTime created;
  final String senderId;
  final List<String> mediaUrls;
  final List<String> reactions;
  // final bool selected;
  final bool starred;
  final bool deleted;

  ElgChatMessage(
      {this.reactions,
      // this.selected = false,
      this.starred = false,
      this.deleted = false,
      this.mediaUrls,
      this.id,
      this.message,
      this.created,
      @required this.senderId})
      : assert(senderId != null),
        assert(message != null)
  // assert(id != null),
  ;

  ElgChatMessage copyWith({
    String id,
    String message,
    DateTime created,
    String userId,
    List<String> mediaUrls,
    List<String> reactions,
    // bool selected,
    bool starred,
    bool deleted,
  }) {
    return ElgChatMessage(
      reactions: reactions ?? this.reactions,
      // selected: selected ?? this.selected,
      starred: starred ?? this.starred,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      id: id ?? this.id,
      message: message ?? this.message,
      created: created ?? this.created,
      senderId: userId ?? this.senderId,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  List<Object> get props => [this.id];
}
