import 'dart:math';

import 'package:appbar_textfield/appbar_textfield.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'bloc/conversation_bloc.dart';
import 'bloc/conversation_event.dart';
import 'models.dart';

typedef LoadChatMessagesCallback = Future<List<ChatMessage>> Function();
typedef LoadMoreChatMessagesCallback = Future<List<ChatMessage>> Function();

class ConversationList extends StatefulWidget {
  final ConversationListState Function() stateCreator;
  final ConversationListLogic Function() logicCreator;

  final List<Widget> trailingActions;
  final List<Widget> leadingActions;
  final List<ChatMessage> chatMessages;
  final List<ChatMessage> chatMessagesRef;

  final Contact contact;
  final Function onNewChatMessage;
  ConversationList(
      {Key key,
      this.stateCreator,
      this.logicCreator,
      this.trailingActions,
      this.leadingActions,
      this.contact,
      this.chatMessages = const [],
      this.chatMessagesRef,
      this.onNewChatMessage})
      : super(key: key);

  @override
  ConversationListState createState() {
    if (stateCreator == null) {
      return ConversationListState();
    } else {
      return this.stateCreator();
    }
  }
}

class ConversationListState extends State<ConversationList> {
  ScrollController scrollController = new ScrollController();
  ConversationListLogic bloc;
  GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  static ConversationListState creator() {
    return new ConversationListState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollControllerListener);
  }

  void scrollControllerListener() {
    if (scrollController.position.atEdge &&
        scrollController.position.pixels > 1) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logicCreator == null && bloc == null) {
      bloc = ConversationListLogic();
    } else if (bloc == null) {
      bloc = widget.logicCreator();
    }

    //
    bloc.dispatch
        .add(SetChatMessagesEvent(widget.chatMessages, widget.chatMessagesRef));

    return StreamBuilder<ConversationCallbackEvent>(
        stream: this.bloc.callbackEventControllerStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            handleCallbackEvent(snapshot.data);
          }
          return buildScaffold();
        });
  }

  handleCallbackEvent(ConversationCallbackEvent event) {
    if (event is ShowToastCallbackEvent) {
      showToast(event.message);
    }
  }

  showToast(String message) {
    if (_globalKey.currentState == null) {
      return;
    }

    SnackBar snackBar = SnackBar(
        content: Expanded(
            child: Text(
      message,
      overflow: TextOverflow.fade,
    )));

    _globalKey.currentState.hideCurrentSnackBar();
    _globalKey.currentState.showSnackBar(snackBar);
  }

  buildScaffold() {
    return StreamBuilder<ConversationState>(
        stream: this.bloc.stateStream,
        builder: (context, snapshot) {
          return Scaffold(
              // resizeToAvoidBottomPadding: true,
              // resizeToAvoidBottomInset: true,
              key: _globalKey,
              bottomNavigationBar: buildBottomBar(),
              floatingActionButton: FloatingActionButton(onPressed: () {
                widget.onNewChatMessage();
              }),
              appBar: buildScaffoldAppBar(snapshot.data),
              body: buildScaffoldBody(snapshot.data));
        });
  }

  buildScaffoldAppBar(ConversationState state) {
    if (state == null) {
      return AppBar(
        title: Text('widget.title'),
      );
    }

    if (state != ConversationState.selection) {
      return buildListAppBar();
    }

    return buildSelectionAppbar();
  }

  buildSelectionAppbar() {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            this.bloc.dispatch.add(SetStateEvent(ConversationState.list));
          }),
      actions: <Widget>[
        replyButton(),
        deleteButton(),
        starButton(),
        copyButton()
      ],
    );
  }

  Widget buildBottomBar() {
    return StreamBuilder<ChatMessage>(
        stream: bloc.replyingWithCMControllerStream,
        builder: (context, snapshot) {
          return Container(
            // color: Colors.yellow,
            // constraints: BoxConstraints.expand(),
            // width: double.infinity,
            padding: EdgeInsets.all(2),
            // height: 220,
            // decoration:
            // BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    // fit: FlexFit.loose,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: snapshot.hasData
                            ? BorderRadius.only(
                                topRight: const Radius.circular(9.0),
                                topLeft: const Radius.circular(9.0),
                                bottomLeft: const Radius.circular(30.0),
                                bottomRight: const Radius.circular(30.0),
                              )
                            : BorderRadius.all(const Radius.circular(30.0)),
                        //   // borderRadius:
                        //   // new BorderRadius.all(const Radius.circular(30.0)),
                        //   // border: Border.all(width: 1.0, color: Colors.lightBlue),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          snapshot.hasData
                              ? Padding(
                                  padding: EdgeInsets.all(5),
                                  child: getQuote(snapshot.data))
                              : Container(),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.all(
                                    const Radius.circular(30.0))
                                //   // borderRadius:
                                //   // new BorderRadius.all(const Radius.circular(30.0)),
                                //   // border: Border.all(width: 1.0, color: Colors.lightBlue),
                                ),
                            // width: double.infinity,
                            // height: 40,
                            // constraints: BoxConstraints.loose(
                            // Size(double.infinity, 100)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.tag_faces),
                                    onPressed: null),
                                Expanded(
                                  // constraints: BoxConstraints.lerp(
                                  //     BoxConstraints.loose(Size(50, 30)),
                                  //     BoxConstraints.loose(Size(100, 100)),
                                  //     0),
                                  // height: 35,
                                  // width: double.infinity,
                                  child: Container(
                                    // color: Colors.red,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(0),
                                        // contentPadding: EdgeInsets.only(
                                        //     top:
                                        //         kdefaultDecorationHeightOffset),
                                        hintText: 'Type a message..',
                                      ),
                                      // scrollPadding: ,
                                      minLines: 1,
                                      maxLines: 8,
                                      expands: false,
                                      keyboardType: TextInputType.multiline,
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.camera), onPressed: null)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3.0, 0, 2.0, 0),
                      child: CircleAvatar(
                        child: Icon(
                          Icons.send,
                          size: 30,
                        ),
                        radius: 24.5,
                      ),
                    ),
                  )
                  // IconButton(
                  //     iconSize: 45,
                  //     icon: CircleAvatar(child: Icon(Icons.send)),
                  //     onPressed: null)
                ]),
          );
        });
  }

  getQuote(ChatMessage chatMessage) {
    if (chatMessage == null) {
      return Container();
    }

    return Container(
        // color: Colors.red,

        // padding: EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 3.0, color: Colors.indigo),
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 4, 2, 4),
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.only(
                bottomRight: const Radius.circular(6.0),
                topRight: const Radius.circular(6.0)),
            color: Colors.black38,
          ),
          // padding: EdgeInsets.only(left: 2),
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'owner',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                        child: Icon(Icons.close, size: 10),
                        onTap: () {
                          this
                              .bloc
                              .dispatch
                              .add(RemoveReplyWithSelectedEvent());
                        })
                  ],
                ),
                Text(chatMessage?.message ?? ''),
              ],
            ),
          ),
        ));
  }

  replyButton() {
    return Tooltip(
        message: 'Reply',
        child:
            IconButton(icon: Icon(Icons.reply), onPressed: replyWithSelected));
  }

  deleteButton() {
    return Tooltip(
        message: 'Delete',
        child: IconButton(icon: Icon(Icons.delete), onPressed: deleteSelected));
  }

  starButton() {
    return Tooltip(
        message: 'Star',
        child: IconButton(icon: Icon(Icons.star), onPressed: starSelected));
  }

  copyButton() {
    return Tooltip(
        message: 'Copy',
        child: IconButton(
            icon: Icon(Icons.content_copy), onPressed: copySelected));
  }

  buildListAppBar() {
    return AppBarTextField(
      title: Text('widget.title'),
      onChanged: (String phrase) {
        this.bloc.dispatch.add(SetSearchString(phrase));
      },
      onBackPressed: () {
        this.bloc.dispatch.add(ClearSearchString());
      },
      onClearPressed: () {
        this.bloc.dispatch.add(ClearSearchString());
      },
      leadingActionButtons: widget.leadingActions,
      trailingActionButtons: widget.trailingActions,
    );
  }

  starSelected() {
    this.bloc.dispatch.add(MuteSelectedEvent());
  }

  copySelected() {
    this.bloc.dispatch.add(CopySelectedEvent());
  }

  replyWithSelected() {
    this.bloc.dispatch.add(ReplyWithSelectedEvent());
  }

  deleteSelected() {
    this.bloc.dispatch.add(DeleteSelectedEvent());
  }

  markSelectedUnread() {
    this.bloc.dispatch.add(MarkSelectedUnreadEvent());
  }

  buildScaffoldBody(ConversationState state) {
    switch (state) {
      case ConversationState.list:
      case ConversationState.selection:
        return buildChatMessageList();
        break;
      case ConversationState.loading:
      default:
        return buildLoading();
    }
  }

  buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  buildChatMessageList() {
    // return ListView.builder(
    //   controller: scrollController,
    //   itemCount: this.widget.chatMessages.length,
    //   itemBuilder: (context, index) {
    //     return buildChatMessageTile(this.widget.chatMessages[index]);
    //   },
    // );

    return StreamBuilder<List<ChatMessage>>(
        stream: this.bloc.visibleChatMessagesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(child: Text("No chats found")),
            );
          }

          List<ChatMessage> visibleChats = snapshot.data;

          double pixelRatio = MediaQuery.of(context).devicePixelRatio;
          double px = 1 / pixelRatio;

          BubbleStyle styleMe = BubbleStyle(
            nip: BubbleNip.no,
            color: Color.fromARGB(255, 3, 125, 199),
            elevation: 4 * px,
            // margin: margin,
            alignment: Alignment.center,
          );

          return Stack(
            children: <Widget>[
              Container(
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(8.0),
                      itemCount: visibleChats.length,
                      itemBuilder: (BuildContext context, int i) {
                        ChatMessage lastChatMsg =
                            visibleChats.elementAt(max(i - 1, 0));
                        ChatMessage currentChatMsg = visibleChats.elementAt(i);
                        ChatMessage nextChatMsg = visibleChats
                            .elementAt(min(i + 1, visibleChats.length - 1));

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

          // return Column(
          //   children: <Widget>[
          //     Expanded(
          //       child: ListView.builder(
          //         controller: scrollController,
          //         itemCount: visibleChats.length,
          //         itemBuilder: (context, index) {
          //           return buildChatMessageTile(visibleChats[index]);
          //         },
          //       ),
          //     ),
          //   ],
          // );
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
          child: InkWell(
            onLongPress: () {
              this.bloc.dispatch.add(ToggleSelectedEvent(currentChatMsg));
            },
            child: Bubble(
                style: getStyle(showAvatar, owner, showNip),
                child: getBubbleContent(currentChatMsg, showNip, owner)),
          ),
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

  buildChatMessageTile(ChatMessage chatMessage) {
    return Container(
      child: ListTile(
          onTap: () {
            this.bloc.dispatch.add(ToggleSelectedEvent(chatMessage));
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chatMessage.message,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )),
    );
  }
}
