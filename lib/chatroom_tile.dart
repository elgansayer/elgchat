import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'models.dart';

class ChatRoomTile extends StatelessWidget {
  const ChatRoomTile(
      {Key key,
      this.chatRoom,
      this.onChatRoomTileTap,
      this.onChatRoomTileLongPress,
      this.chatRoomAvatarBuilder,
      this.selected})
      : super(key: key);
  final bool selected;
  final ChatRoom chatRoom;
  final void Function(ChatRoom chatRoom) onChatRoomTileTap;
  final void Function(ChatRoom chatRoom) onChatRoomTileLongPress;
  final Widget Function(ChatRoom chatRoom, bool selected) chatRoomAvatarBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.selected ? Colors.blue[100] : null,
      child: ListTile(
        onTap: () => onChatRoomTileTap(chatRoom),
        onLongPress: () => onChatRoomTileLongPress(chatRoom),
        leading: this.chatRoomAvatarBuilder(chatRoom, this.selected),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatRoom.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            buildDateTime(chatRoom)
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatRoom.lastMessage,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            chatRoom.pinned ? buildPinned(chatRoom) : Container(),
            chatRoom.muted ? buildMuted(chatRoom) : Container(),
            chatRoom.read != true ? buildNotRead(chatRoom) : Container()
          ],
        ),
      ),
    );
  }

  Widget buildDateTime(ChatRoom chatRoom) {
    DateTime dateTime = chatRoom.updated.toUtc();
    String dateString = formatDateString(dateTime);
    return Text(dateString, style: TextStyle(color: Colors.grey));
  }

  String formatDateString(DateTime dateTime) {
    Duration timeDifference = new DateTime.now().difference(dateTime);

    if (timeDifference.inDays < 1) {
      final fifteenAgo = new DateTime.now().subtract(timeDifference);
      return timeago.format(fifteenAgo, locale: 'en_short');
    } else {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(dateTime);
    }
  }

  Widget buildPinned(ChatRoom chatRoom) {
    return Icon(Icons.person_pin, color: Colors.grey);
  }

  Widget buildMuted(ChatRoom chatRoom) {
    return Icon(Icons.volume_mute, color: Colors.grey);
  }

  Widget buildNotRead(ChatRoom chatRoom) {
    return CircleAvatar(
      radius: 5,
    );
  }
}
