import 'dart:math';

import 'package:appbar_textfield/appbar_textfield.dart';
// import 'package:bubble/bubble.dart';
// import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'bloc/conversation_bloc.dart';
import 'bloc/conversation_event.dart';
import 'bubble.dart';
// import 'emoji_keyboard.dart';
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

  final Contact user;
  final void Function(ChatMessage) onNewChatMessage;

  final String title;

  // Any widget to appear above the input area
  final Widget aboveInputArea;
  // Any widget to appear below the input area
  // A typical example is a gif or emoji selection
  final Widget belowInputArea;
  // Any widgets to appear after the input textfield
  // for example a camera button
  final List<Widget> trailingInputActions;
  // Any widgets to appear in front of the input textfield
  // for example an emoji button
  final List<Widget> leadingInputActions;

  ConversationList(
      {Key key,
      this.stateCreator,
      this.logicCreator,
      this.trailingActions,
      this.leadingActions,
      this.user,
      this.chatMessages = const [],
      this.chatMessagesRef,
      this.onNewChatMessage,
      this.aboveInputArea,
      this.belowInputArea,
      this.trailingInputActions,
      this.leadingInputActions,
      this.title})
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
  TextEditingController textController = new TextEditingController();

  // final ItemScrollController itemScrollController = ItemScrollController();
  // final ItemPositionsListener itemPositionsListener =
  //     ItemPositionsListener.create();

  ConversationListLogic bloc;
  GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  // bool needScroll = true;
  // bool _showScrollToBottom = true;

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

    var distanceFromBottom =
        scrollController.position.maxScrollExtent - scrollController.offset;

    var halfScreenHeight = MediaQuery.of(context).size.height * 0.5;

    if (distanceFromBottom > halfScreenHeight &&
        this.bloc.scrollButtonValue != true) {
      // setState(() {
      // _showScrollToBottom = true;
      // });
      this.bloc.dispatch.add(SetScrollButtonValueEvent(true));
    } else if (distanceFromBottom < halfScreenHeight &&
        this.bloc.scrollButtonValue) {
      // setState(() {
      //   _showScrollToBottom = false;
      // });

      this.bloc.dispatch.add(SetScrollButtonValueEvent(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logicCreator == null && bloc == null) {
      bloc = ConversationListLogic();

      this.bloc.visibleChatMessagesStream.listen((_) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => this.animateScrollToBottom());
      });
    } else if (bloc == null) {
      bloc = widget.logicCreator();

      this.bloc.visibleChatMessagesStream.listen((_) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => this.animateScrollToBottom());
      });
    }
    //
    bloc.dispatch
        .add(SetChatMessagesEvent(widget.chatMessages, widget.chatMessagesRef));

    return StreamBuilder<ConversationCallbackEvent>(
        stream: this.bloc.callbackEventStream,
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
    return StreamBuilder<ConversationLogicState>(
        stream: this.bloc.stateStream,
        builder: (context, snapshot) {
          return Scaffold(
              // resizeToAvoidBottomPadding: true,
              // resizeToAvoidBottomInset: true,
              key: _globalKey,
              bottomNavigationBar: buildBottomBar(),
              // floatingActionButton: FloatingActionButton(onPressed: () {
              //   widget.onNewChatMessage();widget.onNewChatMessage();
              // }),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: StreamBuilder<bool>(
                  stream: this.bloc.showScrollBtnStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == false) {
                      return Container();
                    }

                    return Align(
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
                              this.requireScrollToBottom();
                            }),
                      ),
                    );
                  }),
              appBar: buildScaffoldAppBar(snapshot.data),
              body: buildScaffoldBody(snapshot.data));
        });
  }

  requireScrollToBottom() {
    this.animateScrollToBottom(force: true);
  }

  animateScrollToBottom({bool force}) {
    if (this.bloc.scrollButtonValue && !force) {
      return;
    }

    // needScroll = false;
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      scrollController
          .animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 300),
      )
          .then((value) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.linear,
          duration: const Duration(milliseconds: 300),
        );
      });
    });

    List<ChatMessage> msgs = widget.chatMessages != null
        ? widget.chatMessages
        : widget.chatMessagesRef;
    if (msgs == null || msgs.length <= 0) {
      return;
    }

    // itemScrollController.scrollTo(
    //     index: msgs.length - 1,
    //     duration: Duration(seconds: 2),
    //     curve: Curves.easeInOutCubic);

    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   curve: Curves.easeOut,
    //   duration: const Duration(milliseconds: 300),
    // );
  }

  buildScaffoldAppBar(ConversationLogicState state) {
    if (state == null) {
      return AppBar(
        title: Text(widget.title),
      );
    }

    if (state != ConversationLogicState.selection) {
      return buildListAppBar();
    }

    return buildSelectionAppbar();
  }

  buildSelectionAppbar() {
    return AppBar(
      title: Text('1'),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            this.bloc.dispatch.add(SetStateEvent(ConversationLogicState.list));
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
        stream: bloc.replyingWithChatMsgStream,
        builder: (context, snapshot) {
          return Container(
            // color: Colors.yellow,
            // constraints: BoxConstraints.expand(),
            // width: double.infinity,
            padding: EdgeInsets.all(2),
            // height: 220,
            // decoration:
            // BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                widget.aboveInputArea ?? Container(),
                Row(
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
                                    widget.leadingInputActions != null
                                        ? [...widget.leadingInputActions]
                                        : Container(),
                                    IconButton(
                                        icon: Icon(Icons.tag_faces),
                                        onPressed: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             EmojiKeyboard()));
                                        }),
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
                                          controller: this.textController,
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
                                    widget.trailingInputActions != null
                                        ? [...widget.trailingInputActions]
                                        : Container(),
                                    IconButton(
                                        icon: Icon(Icons.camera),
                                        onPressed: null)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          sendTapped();
                        },
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
                // Container(
                //   // fit: FlexFit.loose,
                //   child: EmojiPicker(
                //     rows: 5,
                //     columns: 5,
                //     recommendKeywords: ["racing", "horse"],
                //     numRecommended: 1,
                //     onEmojiSelected: (emoji, category) {
                //       print(emoji);
                //     },
                //   ),
                // ),
                widget.belowInputArea ?? Container(),
              ],
            ),
          );
        });
  }

  void sendTapped() {
    if (widget.onNewChatMessage != null) {
      // Must send a new chat message
      ChatMessage chatMessage = ChatMessage(
          reactions: [],
          starred: false,
          deleted: false,
          mediaUrls: [],
          id: null,
          message: this.textController.text,
          created: DateTime.now().toUtc(),
          senderId: this.widget.user.id
          );

      widget.onNewChatMessage(chatMessage);
    }

    this.textController.clear();
  }

  Widget getDeletedMessageText(ChatMessage currentChatMsg) {
    return Text('User deleted their message',
        style: TextStyle(fontStyle: FontStyle.italic));
  }

  Widget getMessageText(ChatMessage currentChatMsg) {
    return Text(currentChatMsg?.message ?? '');
  }

  getQuote(ChatMessage chatMessage) {
    if (chatMessage == null) {
      return Container();
    }

    Widget message = chatMessage.deleted
        ? getDeletedMessageText(chatMessage)
        : getMessageText(chatMessage);

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
                message,
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
      title: Text(widget.title),
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

  buildScaffoldBody(ConversationLogicState state) {
    switch (state) {
      case ConversationLogicState.list:
      case ConversationLogicState.selection:
        return buildChatMessageList();
        break;
      case ConversationLogicState.loading:
      default:
        return buildLoading();
    }
  }

  buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  buildChatMessageList() {
    return StreamBuilder<List<ChatMessage>>(
        stream: this.bloc.visibleChatMessagesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return noChatFound();
          }

          List<ChatMessage> visibleChats = snapshot.data;
          // List<ChatMessage> visibleChats = widget.chatMessages;

          // double pixelRatio = MediaQuery.of(context).devicePixelRatio;
          // double px = 1 / pixelRatio;

          // BubbleStyle styleMe = BubbleStyle(
          //   nip: BubbleNip.no,
          //   color: Color.fromARGB(255, 3, 125, 199),
          //   elevation: 4 * px,
          //   // margin: margin,
          //   alignment: Alignment.center,
          // );

          // if (!this._showScrollToBottom) {
          //   // lastMsgCount = chatMessages.length;
          //   // WidgetsBinding.instance
          //   //     .addPostFrameCallback((_) => this.animateScrollToBottom());
          // }

          return Stack(
            children: <Widget>[
              Scrollbar(
                controller: scrollController,
                // child: ScrollablePositionedList.builder(
                //   itemCount: visibleChats.length  ,
                //   itemBuilder: (context, i) {
                //     ChatMessage lastChatMsg =
                //         visibleChats.elementAt(max(i - 1, 0));
                //     ChatMessage currentChatMsg = visibleChats.elementAt(i);
                //     ChatMessage nextChatMsg = visibleChats
                //         .elementAt(min(i + 1, visibleChats.length - 1));

                //     return buildChatTitle(
                //         currentChatMsg, lastChatMsg, nextChatMsg);
                //   },
                //   itemScrollController: itemScrollController,
                //   itemPositionsListener: itemPositionsListener,
                // )),
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
              // Align(
              //     alignment: Alignment.bottomCenter,
              //     child: Container(
              //         height: 50,
              //         child: Bubble(
              //             style: styleMe,
              //             child: InkWell(
              //               onTap: () {
              //                 // floatingActionButton: FloatingActionButton(onPressed: () {
              //                 widget.onNewChatMessage();
              //                 widget.onNewChatMessage();
              //                 // }),
              //               },
              //               child: Row(
              //                 mainAxisSize: MainAxisSize.min,
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: <Widget>[
              //                   Icon(Icons.arrow_downward),
              //                   Container(child: Text('Unread'))
              //                 ],
              //               ),
              //             )
              //             )
              //             )
              //             ),
            ],
          );
        });
  }

  noChatFound() {
    return Container(
      child: Center(),
    );
  }

  Widget buildChatTitle(ChatMessage currentChatMsg, ChatMessage lastChatMsg,
      ChatMessage nextChatMsg) {
    bool sameLastMsg = currentChatMsg.id == lastChatMsg.id;

    bool showNip =
        !sameLastMsg ? currentChatMsg.senderId != lastChatMsg.senderId : true;

    bool owner = currentChatMsg.senderId == widget.user.id;

    bool ownsNextMsg = currentChatMsg.senderId == nextChatMsg.senderId;
    bool sameNextMsg = currentChatMsg.id == nextChatMsg.id;

    bool showAvatar = !owner && (!ownsNextMsg || ownsNextMsg && sameNextMsg);
    double radius = 15;

    return ConvosationBubble(
      chatMessage: currentChatMsg,
      avatarUrl: this.widget.user.photoUrl,
      owner: owner,
      radius: radius,
      showAvatar: showAvatar,
      showNip: showNip,
      onGotReaction: (String code) {
        this.bloc.dispatch.add(ToggleReactedEvent(
            chatMessage: currentChatMsg, uCode: code, contact: widget.user));
      },
      onLongPress: () {
        this.bloc.dispatch.add(ToggleSelectedEvent(currentChatMsg));
      },
    );
  }
}
