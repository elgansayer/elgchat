import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'models.dart';

double kMarginDepth = 55;

class ConvosationBubble extends StatelessWidget {
  final bool showAvatar;
  final String avatarUrl;
  final ElgChatMessage chatMessage;
  final double radius;
  final bool owner;
  final bool showNip;
  final Function onTap;
  final Function onLongPress;
  final Function onDoubleTap;
  final void Function(String) onGotReaction;

  ConvosationBubble(
      {Key key,
      @required this.showAvatar,
      @required this.chatMessage,
      @required this.radius,
      @required this.owner,
      @required this.showNip,
      this.onTap,
      this.onLongPress,
      this.onDoubleTap,
      this.onGotReaction,
      this.avatarUrl})
      : super(key: key);

  final LayerLink layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    var hasReactions = this.chatMessage.reactions != null &&
        this.chatMessage.reactions.length > 0;

    var reactionMargin = owner
        ? EdgeInsets.only(left: kMarginDepth * 1.5, bottom: 0, top: 0)
        : EdgeInsets.only(right: kMarginDepth * 1.5, bottom: 0, top: 0);

    OverlayEntry overlayEntry;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: Row(children: [
        showAvatar
            ? buildAvatar()
            : SizedBox(
                width: radius * 2,
              ),
        Expanded(
          child: GestureDetector(
            onTap: this.onTap,
            onDoubleTap: () {
              overlayEntry = this.buildReactionsList(layerLink, () {
                overlayEntry?.remove();
              }, (String code) {
                overlayEntry?.remove();
                if (this.onGotReaction != null) {
                  this.onGotReaction(code);
                }
              });
              Overlay.of(context).insert(overlayEntry);
              if (this.onDoubleTap != null) {
                this.onDoubleTap();
              }
            },
            onLongPress: () {
              if (this.onLongPress != null) {
                this.onLongPress();
              }
            },
            child: CompositedTransformTarget(
              link: layerLink,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: hasReactions
                        ? const EdgeInsets.only(bottom: 10)
                        : const EdgeInsets.only(bottom: 0),
                    child: Bubble(
                        style: getStyle(showAvatar, owner, showNip),
                        child: getBubbleContent(chatMessage, showNip, owner)),
                  ),
                  hasReactions
                      ? Positioned.fill(
                          child: Container(
                              margin: reactionMargin,
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                  children: this
                                          .chatMessage
                                          .reactions
                                          ?.map((reactionUCode) =>
                                              Text(reactionUCode))
                                          ?.toList() ??
                                      [])),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  buildAvatar() {
    Widget avatar = CircleAvatar(
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: avatarUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            )
          : Container(),
    );

    return avatar;
  }

  OverlayEntry buildReactionsList(
      layerLink, Function onTap, Function(String) onButtonTapped) {
    return OverlayEntry(
        builder: (context) => GestureDetector(
              onTap: onTap,
              child: Stack(
                children: <Widget>[
                  Container(color: Colors.transparent),
                  Container(
                    child: CompositedTransformFollower(
                      link: layerLink,
                      showWhenUnlinked: false,
                      offset: Offset(0, 0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4.0,
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          constraints: BoxConstraints(
                            maxHeight: IconTheme.of(context).size * 2.5,
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(8),
                            shrinkWrap: true,
                            children: <Widget>[
                              this.buildReactionIconButton('\ud83d\ude01',
                                  (String code) {
                                onButtonTapped(code);
                              }),
                              this.buildReactionIconButton('\ud83d\ude2d',
                                  (String code) {
                                onButtonTapped(code);
                              }),
                              this.buildReactionIconButton('\ud83d\ude20',
                                  (String code) {
                                onButtonTapped(code);
                              }),
                              this.buildReactionIconButton('\ud83d\ude0d',
                                  (String code) {
                                onButtonTapped(code);
                              }),
                              this.buildReactionIconButton('\ud83d\udc4d',
                                  (String code) {
                                onButtonTapped(code);
                              }),
                              this.buildReactionIconButton('\ud83d\udc4e',
                                  (String code) {
                                onButtonTapped(code);
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget buildReactionIconButton(String iconUnicode, Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
          child: Center(
            child: Text(
              iconUnicode,
              style: TextStyle(fontSize: 24),
            ),
          ),
          onTap: () {
            onTap(iconUnicode);
          }),
    );
  }

  Widget getDeletedMessageText(ElgChatMessage currentChatMsg) {
    return Text('User deleted their message',
        style: TextStyle(fontStyle: FontStyle.italic));
  }

  Widget getMessageText(ElgChatMessage currentChatMsg) {
    return Text(currentChatMsg?.message ?? '');
  }

  getBubbleContent(ElgChatMessage currentChatMsg, bool showNip, bool owner) {
    Widget message = currentChatMsg.deleted
        ? getDeletedMessageText(currentChatMsg)
        : getMessageText(currentChatMsg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("message", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(child: message),
            Icon(Icons.done_all, size: 15)
          ],
        ),
      ],
    );
  }

  getAlignment(bool owner) {
    if (owner) {
      return Alignment.bottomRight;
    } else {
      return Alignment.topLeft;
    }
  }

  getStyle(bool showAvatar, bool owner, bool ownedLastMsg) {
    BubbleEdges margin = owner
        ? BubbleEdges.only(left: kMarginDepth)
        : BubbleEdges.only(right: kMarginDepth, left: !showAvatar ? 0.0 : 0);

    BubbleStyle styleMe = BubbleStyle(
      nip: getNipStyle(owner, ownedLastMsg),
      color: Color.fromARGB(255, 225, 255, 199),
      margin: margin,
      alignment: getAlignment(owner),
    );

    return styleMe;
  }

  getNipStyle(bool owner, bool ownedLastMsg) {
    if (owner == true) {
      return ownedLastMsg ? BubbleNip.rightTop : BubbleNip.no;
    } else {
      return ownedLastMsg ? BubbleNip.leftTop : BubbleNip.no;
    }
  }
}
