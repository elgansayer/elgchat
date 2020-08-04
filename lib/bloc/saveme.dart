import 'dart:math';
import 'package:bubble/bubble.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models.dart';

class ConversationScreen extends StatefulWidget {
  ConversationScreen({Key key, this.contact}) : super(key: key);
  final Contact contact;

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<ChatMessage> chatMessages = new List<ChatMessage>();
  ScrollController _scrollController = new ScrollController();
  bool _show = false;
  int lastMsgCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_goneDidScrolling);
  }

  _goneDidScrolling() {
    var distanceFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.offset;

    var halfScreenHeight = MediaQuery.of(context).size.height * 0.5;

    if (distanceFromBottom > halfScreenHeight) {
      setState(() {
        _show = true;
      });
    } else {
      setState(() {
        _show = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((void d) {
      if (_show != true && chatMessages.length > lastMsgCount) {
        lastMsgCount = chatMessages.length;
        scrollToBottom();
      }
    });

    return Scaffold(
        appBar: buildAppBar(),
        body: buildBody(context),
        bottomNavigationBar: Row(
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
        ),
        // persistentFooterButtons: <Widget>[RaisedButton(onPressed: null)],
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Visibility(
            visible: _show,
            child: Align(
              alignment: Alignment(1.05, 1),
              // padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              // child: CircleAvatar(
              //   radius: 15,
              //   child: IconButton(
              //       icon: Icon(Icons.arrow_downward), onPressed: null),
              // )
              child: Container(
                height: 30.0,
                width: 30.0,
                child: FloatingActionButton(
                    mini: true,
                    tooltip: 'Scroll to bottom',
                    child: Icon(
                      Icons.arrow_downward,
                      size: 15,
                    ),
                    onPressed: () {
                      this.scrollToBottom(milliseconds: 0);
                    }),
              ),
            )));
  }

  scrollToBottom({int milliseconds = 250}) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   curve: Curves.easeOut,
    //   duration: const Duration(milliseconds: 300),
    // );
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

    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.no,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 4 * px,
      // margin: margin,
      alignment: Alignment.center,
    );

    return Stack(
      children: <Widget>[
        Container(
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.0),
                itemCount: this.chatMessages.length,
                itemBuilder: (BuildContext context, int i) {
                  ChatMessage lastChatMsg =
                      this.chatMessages.elementAt(max(i - 1, 0));
                  ChatMessage currentChatMsg = this.chatMessages.elementAt(i);
                  ChatMessage nextChatMsg = this
                      .chatMessages
                      .elementAt(min(i + 1, chatMessages.length - 1));

                  return buildChatTitle(
                      currentChatMsg, lastChatMsg, nextChatMsg);
                }),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: 50,
                child: Bubble(
                    style: styleMe,
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.arrow_downward),
                          Container(child: Text('Unread'))
                        ],
                      ),
                    )))),
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
      lastMsgCount = chatMessages.length;
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
    double radius = 15;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: Row(children: [
        showAvatar
            ? CircleAvatar(
                child: Text(currentChatMsg.userId.toString()),
                radius: radius,
              )
            : SizedBox(
                width: radius * 2,
              ),
        Expanded(
          child: Bubble(
              style: getStyle(showAvatar, owner, showNip),
              child: getBubbleContent(currentChatMsg, showNip, owner)),
        ),
      ]),
    );
  }

  getBubbleContent(ChatMessage currentChatMsg, bool showNip, bool owner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("message", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(child: Text(currentChatMsg.message)),
            Icon(Icons.done_all, size: 15)
          ],
        ),
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
    BubbleEdges margin = owner
        ? BubbleEdges.only(left: 55)
        : BubbleEdges.only(right: 55, left: !showAvatar ? 0.0 : 0);

    BubbleStyle styleMe = BubbleStyle(
      nip: getNipStyle(owner, ownedLastMsg),
      color: Color.fromARGB(255, 225, 255, 199),
      // elevation: 1 * px,

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
