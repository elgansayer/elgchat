import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models.dart';

class ConversationScreen extends StatefulWidget {
  ConversationScreen({Key key, this.contact}) : super(key: key);
  final Contact contact;

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<ChatMessage> chatMessages = new List<ChatMessage>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  buildAppBar() {
    return AppBar(
      title: Text(widget.contact.username),
      actions: <Widget>[
        IconButton(icon: Icon(Icons.more_vert), onPressed: () {})
      ],
    );
  }

  buildBody(context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double px = 1 / pixelRatio;

    BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      // elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );

    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: this.chatMessages.length,
              itemBuilder: (BuildContext context, int i) {
                ChatMessage lastChatMsg =
                    this.chatMessages.elementAt(max(i - 1, 0));
                ChatMessage currentChatMsg = this.chatMessages.elementAt(i);
                ChatMessage nextChatMsg = this
                    .chatMessages
                    .elementAt(min(i + 1, chatMessages.length - 1));

                return buildChatTitle(currentChatMsg, lastChatMsg, nextChatMsg);
              }),
        ),
        Card(child: TextField(
          onSubmitted: (String value) {
            var genChat = ((String userId) {
              ChatMessage chatMessage = new ChatMessage(
                  id: Random().nextInt(1000).toString(),
                  message: value,
                  userId: userId,
                  creationDate: DateTime.now());

              chatMessages.add(chatMessage);
            });
            genChat('1');
          },
        )),
        Row(
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                genChat('1');
              },
            ),
            RaisedButton(
              onPressed: () {
                genChat('2');
              },
            ),
            RaisedButton(
              onPressed: () {
                genChat('3');
              },
            ),
            RaisedButton(
              onPressed: () {
                genChat('4');
              },
            ),
          ],
        )

        // Card(child: TextField(
        //   onSubmitted: (String value) {
        //     var genChat = ((String userId) {
        //       ChatMessage chatMessage = new ChatMessage(
        //           id: Random().nextInt(1000).toString(),
        //           message: value,
        //           userId: userId,
        //           creationDate: DateTime.now());

        //       chatMessages.add(chatMessage);
        //     });
        //     genChat('2');
        //   },
        // )),
        // Card(child: TextField(
        //   onSubmitted: (String value) {
        //     var genChat = ((String userId) {
        //       ChatMessage chatMessage = new ChatMessage(
        //           id: Random().nextInt(1000).toString(),
        //           message: value,
        //           userId: userId,
        //           creationDate: DateTime.now());

        //       chatMessages.add(chatMessage);
        //     });
        //     genChat('3');
        //   },
        // )),
      ],
    );
  }

  genChat(String userId) {
    ChatMessage chatMessage = new ChatMessage(
        id: Random().nextInt(1000).toString(),
        message: faker.lorem.sentence(),
        userId: userId,
        creationDate: DateTime.now());

    setState(() {
      chatMessages.add(chatMessage);
    });
  }

  Widget buildChatTitle(ChatMessage currentChatMsg, ChatMessage lastChatMsg,
      ChatMessage nextChatMsg) {
    bool sameLastMsg = currentChatMsg.id == lastChatMsg.id;

    bool showNip =
        !sameLastMsg ? currentChatMsg.userId != lastChatMsg.userId : true;

    bool owner = currentChatMsg.userId == widget.contact.id;

    bool ownsNextMsg = currentChatMsg.userId == nextChatMsg.userId;
    bool sameNextMsg = currentChatMsg.id == nextChatMsg.id;

    bool showAvatar = !owner && (!ownsNextMsg || ownsNextMsg && sameNextMsg);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: Row(children: [
        // dense: true,
        // contentPadding: EdgeInsets.all(0),
        // leading: showAvatar ? CircleAvatar() : SizedBox(),
        // trailing: showNip && owner ? CircleAvatar() : SizedBox(),
        showAvatar
            ? CircleAvatar(child: Text(currentChatMsg.userId.toString()))
            : SizedBox(
                width: 40,
              ),
        Expanded(
          child: Bubble(
              style: getStyle(showAvatar, owner, showNip),
              // alignment: getAlignment(e, owner),
              // color: Color.fromARGB(255, 212, 234, 244),
              // elevation: 1 * px,
              // margin: showAvatar ? BubbleEdges.only(left: 5, top:  50.0) : null,
              child: getBubbleContent(currentChatMsg, showNip, owner)),
        ),
      ]),
    );

    // return Dismissible(
    //   key: GlobalKey(),
    //   child: ListTile(
    //     dense: true,
    //     contentPadding: EdgeInsets.all(0),
    //     leading: showAvatar ? CircleAvatar() : SizedBox(),
    //     // trailing: showNip && owner ? CircleAvatar() : SizedBox(),
    //     title: Bubble(
    //       style: getStyle(showAvatar, owner, showNip),
    //       // alignment: getAlignment(e, owner),
    //       // color: Color.fromARGB(255, 212, 234, 244),
    //       // elevation: 1 * px,
    //       // margin: BubbleEdges.only(top: 8.0),
    //       child: Text(currentChatMsg.message, style: TextStyle(fontSize: 10)),
    //     ),
    //   ),
    // );
  }

  getBubbleContent(ChatMessage currentChatMsg, bool showNip, bool owner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("message", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(currentChatMsg.message)
      ],
    );

    // return Text(currentChatMsg.message, style: TextStyle(fontSize: 10));
  }

  getAlignment(bool owner) {
    if (owner) {
      return Alignment.bottomRight;
    } else {
      return Alignment.topLeft;
    }
  }

  getStyle(bool showAvatar, bool owner, bool ownedLastMsg) {
    BubbleStyle styleMe = BubbleStyle(
      nip: getNipStyle(owner, ownedLastMsg),
      color: Color.fromARGB(255, 225, 255, 199),
      // elevation: 1 * px,
      margin:
          BubbleEdges.only(right: !owner ? 55 : 0, left: !showAvatar ? 0.0 : 0),
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
