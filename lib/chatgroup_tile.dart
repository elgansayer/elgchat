import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'models.dart';

class ChatGroupTile extends StatelessWidget {
  const ChatGroupTile(
      {Key key,
      this.chatGroup,
      this.onChatGroupTileTap,
      this.onChatGroupTileLongPress,
      this.chatGroupAvatarBuilder,
      this.selected})
      : super(key: key);
  final bool selected;
  final ChatGroup chatGroup;
  final void Function(ChatGroup chatGroup) onChatGroupTileTap;
  final void Function(ChatGroup chatGroup) onChatGroupTileLongPress;
  final Widget Function(ChatGroup chatGroup, bool selected) chatGroupAvatarBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.selected ? Colors.blue[100] : null,
      child: ListTile(
        onTap: () => onChatGroupTileTap(chatGroup),
        onLongPress: () => onChatGroupTileLongPress(chatGroup),
        leading: this.chatGroupAvatarBuilder(chatGroup, this.selected),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatGroup.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            buildDateTime(chatGroup)
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatGroup.lastMessage,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            chatGroup.pinned ? buildPinned(chatGroup) : Container(),
            chatGroup.muted ? buildMuted(chatGroup) : Container(),
            chatGroup.read != true ? buildNotRead(chatGroup) : Container()
          ],
        ),
      ),
    );
  }

  Widget buildDateTime(ChatGroup chatGroup) {
    DateTime dateTime = chatGroup.updated.toUtc();
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

  Widget buildPinned(ChatGroup chatGroup) {
    return Icon(Icons.person_pin, color: Colors.grey);
  }

  Widget buildMuted(ChatGroup chatGroup) {
    return Icon(Icons.volume_mute, color: Colors.grey);
  }

  Widget buildNotRead(ChatGroup chatGroup) {
    return CircleAvatar(
      radius: 5,
    );
  }
}
