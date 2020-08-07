import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ConversationState {
  loading,
  list,
  selection,
}

enum ChatListState {
  loading,
  list,
  selection,
}

class Contact extends Equatable {
  final String id;
  final String username;
  final String photoUrl;
  final DateTime lastOnline;
  final bool isActive;

  Contact(
      {@required this.id,
      this.username,
      this.photoUrl,
      this.lastOnline,
      this.isActive})
      : assert(id != null);

  @override
  List<Object> get props => [this.id];
}

abstract class ChatGroupProps {
  static const String id = "id";
  static const String name = "name";
  static const String imageUrl = "imageUrl";
  static const String lastMessage = "lastMessage";
  static const String created = "created";
  static const String updated = "updated";
  static const String seen = "seen";
  static const String userIds = "userIds";
  static const String creatorId = "creatorId";

  static const String selected = "selected";
  static const String archived = "archived";
  static const String muted = "muted";
  static const String pinned = "pinned";
}

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String lastMessage;
  final String creatorId;
  final DateTime created;
  final DateTime update;
  final List<String> seenBy;
  final List<String> userIds;

  // If a user was in seen
  // final bool seen;
  final bool selected;
  final bool archived;
  final bool muted;
  final bool pinned;

  ChatGroup(
      {this.creatorId,
      this.update,
      this.userIds,
      this.pinned = false,
      this.muted = false,
      this.archived = false,
      this.selected = false,
      this.imageUrl,
      this.id,
      this.lastMessage,
      this.created,
      this.seenBy = const [],
      this.name})
      : assert(id != null),
        assert(name != null);

  ChatGroup copyWith(
      {String id,
      String name,
      String lastMessage,
      DateTime date,
      String avatarUrl,
      bool selected,
      bool archived,
      bool muted,
      bool pinned,
      String creatorId,
      DateTime update,
      List<String> seenBy,
      List<String> userIds}) {
    return ChatGroup(
        muted: muted ?? this.muted,
        pinned: pinned ?? this.pinned,
        archived: archived ?? this.archived,
        selected: selected ?? this.selected,
        imageUrl: avatarUrl ?? this.imageUrl,
        id: id ?? this.id,
        lastMessage: lastMessage ?? this.lastMessage,
        created: date ?? this.created,
        seenBy: seenBy ?? this.seenBy,
        name: name ?? this.name,
        creatorId: creatorId ?? this.creatorId,
        update: update ?? this.update,
        userIds: userIds ?? this.userIds);
  }

  bool seen(String userId) {
    return seenBy.contains(userId);
  }

  factory ChatGroup.fromMap(Map data, String documentID) {
    return ChatGroup(
        id: documentID,
        muted: getParam<bool>(ChatGroupProps.muted, data, false),
        pinned: getParam<bool>(ChatGroupProps.pinned, data, false),
        archived: getParam<bool>(ChatGroupProps.archived, data, false),
        selected: false,
        imageUrl: getParam<String>(ChatGroupProps.imageUrl, data, ''),
        lastMessage: getParam<String>(ChatGroupProps.lastMessage, data, ''),
        created: getTimeFromMap(ChatGroupProps.created, data),
        // seen: false,
        name: getParam<String>(ChatGroupProps.name, data, ''),
        creatorId: getParam<String>(ChatGroupProps.creatorId, data, ''),
        update: getTimeFromMap(ChatGroupProps.updated, data),
        userIds: getStrListParam<List<String>>(
            ChatGroupProps.userIds, data, new List<String>()));
  }

  @override
  List<Object> get props => [this.id];
}

DateTime getTimeFromMap(String prop, Map data) {
  try {
    String dateString = data[prop];
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now().toUtc();
    }

    var date = DateTime.parse(dateString).toUtc();
    return DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
  } catch (e) {
    print(e);
    return DateTime.now().toUtc();
  }
}

T getStrListParam<T>(String param, dynamic data, T value) {
  var ret;

  try {
    ret = (data?.containsKey(param) ?? false)
        ? (data[param] as List<dynamic>).map((e) => e.toString()).toList()
        : value;
  } catch (e) {
    print(e);
    return value;
  }

  return ret;
}

T getParam<T>(String param, Map data, T defaultValue) {
  var ret;

  try {
    ret = (data?.containsKey(param) ?? false) ? data[param] as T : defaultValue;
  } catch (e) {
    print(e);
    return defaultValue;
  }

  return ret;
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
