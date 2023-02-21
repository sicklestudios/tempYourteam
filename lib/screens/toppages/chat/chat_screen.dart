import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:yourteam/call_constants_global.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/constants/message_enum.dart';
import 'package:yourteam/constants/utils.dart';
import 'package:yourteam/methods/chat_methods.dart';
import 'package:yourteam/methods/get_call_token.dart';
import 'package:yourteam/models/chat_model.dart';
import 'package:yourteam/models/user_model.dart';
import 'package:yourteam/screens/bottom_pages.dart/todo_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yourteam/screens/call/call_notification_sent.dart';
import 'package:yourteam/screens/call/calls_ui/screens/dialScreen/dial_screen.dart';
import 'package:yourteam/screens/task/add_task.dart';
import 'package:yourteam/screens/toppages/chat/chat_profile_screen.dart';
import 'package:yourteam/screens/toppages/chat/forward_message_screen.dart';
import 'package:yourteam/screens/toppages/chat/widgets/message_reply_preview.dart';
import 'package:yourteam/screens/toppages/chat/widgets/my_message_card.dart';
import 'package:yourteam/screens/toppages/chat/widgets/sender_message_card.dart';
import 'package:yourteam/utils/SharedPreferencesUser.dart';

class ChatScreen extends StatefulWidget {
  final ChatContactModel contactModel;
  final List<Message>? message;
  const ChatScreen({super.key, this.message, required this.contactModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  UserModel? usermodel;
  var user;

  getdata() async {
    var doc = await firebaseFirestore
        .collection('users')
        .doc(widget.contactModel.contactId)
        .get();
    user = doc.data() as Map<dynamic, dynamic>;
    CALLERDATA = user;
    usermodel = UserModel.getValuesFromSnap(doc);
    if (mounted) setState(() {});
  }

  // Animation controller
  late AnimationController _animationController;

  // // This is used to animate the icon of the main FAB
  // late Animation<double> _buttonAnimatedIcon;

  // This is used for the child FABs
  late Animation<double> _translateButton;

  // This variable determnies whether the child FABs are visible or not
  bool _isExpanded = false;
  bool isBlocked = false;
  int pageIndex = 0;
  bool showOptions = false;
  int selectedNum = 1;

  _toggle() {
    if (_isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    log(_isExpanded.toString());
    _isExpanded = !_isExpanded;
  }

  Column _getFloatingButton() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform(
          transform: Matrix4.translationValues(
            0,
            _translateButton.value * 2,
            0,
          ),
          child: Container(
              height: 150,
              width: 130,
              decoration: BoxDecoration(
                  color: whiteColor, borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        log("profile");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatProfileScreen(
                                id: widget.contactModel.contactId)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            "Profile",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.person,
                              color: mainColor,
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _showDeleteDialog();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            "Delete",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        log("press");
                        _showBlockDialog();
                      },
                      child: StreamBuilder<UserModel>(
                          stream: ChatMethods().getBlockStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              isBlocked = snapshot.data!.blockList
                                  .contains(widget.contactModel.contactId);
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  isBlocked ? "Unblock" : "Block",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.block,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              )),
        )
      ],
    );
  }

  final ScrollController messageController =
      ScrollController(keepScrollOffset: true);
  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  void initState() {
    super.initState();
//getting the data of the user
    getdata();

    //setting the typing to false just in case it was left on true
    ChatMethods().stopTyping(widget.contactModel.contactId);

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 10))
      ..addListener(() {
        setState(() {});
      });

    _translateButton = Tween<double>(
      begin: -200,
      end: 80,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    ChatMethods().setChatContactMessageSeen(widget.contactModel.contactId);
    if (widget.message != null) {
      sendForwardedMessageToUser();
    }
    try {} catch (e) {}
    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        if (mounted) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        }
      } catch (e) {}
    });
  }

  void sendForwardedMessageToUser() {
    //iterating over all the messages in the list
    //and sending the messages to the user
    for (var element in widget.message!) {
      if (element.type == MessageEnum.link ||
          element.type == MessageEnum.text) {
        //forwarding the text message
        ChatMethods().sendTextMessage(
            context: context,
            text: element.text,
            recieverUserId: widget.contactModel.contactId,
            senderUser: userInfo,
            messageReply: null);
      } else {
        ChatMethods().sendForwardedFileMessage(
            context: context,
            fileUrl: element.text,
            recieverUserId: widget.contactModel.contactId,
            senderUserData: userInfo,
            messageEnum: element.type,
            messageReply: null);
      }
    }
  }

  void incrementSelectedNum() {
    setState(() {
      ++selectedNum;
    });
  }

  void decrementSelectedNum() {
    setState(() {
      --selectedNum;
      if (selectedNum == 0) {
        setStateToNormal();
      }
    });
  }

  void changeShowOptions() {
    if (!showOptions) {
      setState(() {
        showOptions = !showOptions;
      });
    }
  }

  void setStateToNormal() {
    setState(() {
      showOptions = false;
      selectedNum = 1;
      messageId = [];
      tempMessage = [];
      taskTitleTemp = "";
    });
  }

  bool isTyping = false;
  List<String> messageId = [];
  List<Message> tempMessage = [];
  final listViewKey = GlobalKey();
  String taskTitleTemp = "";

  bool _getBoolCreateCheck() {
    if (selectedNum == 1) {
      try {
        for (var element in tempMessage) {
          if (element.messageId == messageId[0]) {
            if (element.type == MessageEnum.text) {
              taskTitleTemp = element.text;
              return true;
            }
          }
        }
      } catch (e) {
        return false;
      }
      return false;
    } else {
      taskTitleTemp = "";
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_isExpanded) {
              _animationController.reverse();
              _isExpanded = !_isExpanded;
            }
          },
          child: Column(
            children: [
              ValueListenableBuilder(
                  valueListenable: appValueNotifier.globalisCallOnGoing,
                  builder: (context, value, widget) {
                    if (appValueNotifier.globalisCallOnGoing.value) {
                      return getCallNotifierWidget(context);
                    }
                    return Container();
                  }),
              Expanded(
                child: Scaffold(
                    backgroundColor: scaffoldBackgroundColor,
                    appBar: showOptions
                        ? AppBar(
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            title:
                                Row(mainAxisSize: MainAxisSize.max, children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setStateToNormal();
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          size: 25,
                                          color: Colors.black,
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      selectedNum.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                              if (_getBoolCreateCheck())
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => AddTask(
                                                    taskTitle: taskTitleTemp,
                                                  )));
                                    },
                                    icon: const Icon(
                                      Icons.create,
                                      size: 25,
                                      color: Colors.black,
                                    )),
                              IconButton(
                                  onPressed: () async {
                                    for (var id in messageId) {
                                      ChatMethods().deleteSingleMessage(
                                          recieverUserId:
                                              widget.contactModel.contactId,
                                          messageId: id);
                                    }
                                    setStateToNormal();
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 25,
                                    color: Colors.black,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    // Navigator.pop(context);
                                    String text = '';
                                    for (var i = 0;
                                        i < tempMessage.length;
                                        i++) {
                                      for (var element in messageId) {
                                        if (tempMessage[i].messageId ==
                                            element) {
                                          if (text != '') {
                                            text =
                                                "$text\n${tempMessage[i].text}";
                                          } else {
                                            text = "${tempMessage[i].text}";
                                          }
                                        }
                                      }
                                    }
                                    Clipboard.setData(ClipboardData(text: text))
                                        .then((_) {
                                      showToastMessage("Text Copied");
                                    });
                                    setStateToNormal();
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 25,
                                    color: Colors.black,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    // Navigator.pop(context);
                                    List<Message> messages = [];
                                    for (var i = 0;
                                        i < tempMessage.length;
                                        i++) {
                                      for (var element in messageId) {
                                        if (tempMessage[i].messageId ==
                                            element) {
                                          messages.add(tempMessage[i]);
                                        }
                                      }
                                    }
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForwardMessageScreen(
                                                    messageList: messages)));
                                  },
                                  icon: const Icon(
                                    Icons.send,
                                    size: 25,
                                    color: Colors.black,
                                  )),
                            ]),
                          )
                        : AppBar(
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 20,
                                          color: Colors.black,
                                        )),
                                    widget.contactModel.photoUrl != ""
                                        ? CircleAvatar(
                                            radius: 22,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              widget.contactModel.photoUrl,
                                              // maxWidth: 50,
                                              // maxHeight: 50,
                                            ))
                                        : const CircleAvatar(
                                            radius: 22,
                                            backgroundImage:
                                                AssetImage('assets/user.png')),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.contactModel.name,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        StreamBuilder<bool>(
                                            stream: ChatMethods()
                                                .getOnlineStream(widget
                                                    .contactModel.contactId),
                                            builder: (context, snapshot) {
                                              return Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: snapshot.data != null
                                                        ? snapshot.data!
                                                            ? Colors.green
                                                            : Colors.grey
                                                        : Colors.grey,
                                                    size: 14,
                                                  ),
                                                  Text(
                                                    snapshot.data != null
                                                        ? snapshot.data!
                                                            ? "Online"
                                                            : "Offline"
                                                        : "Offline",
                                                    style: TextStyle(
                                                        color: snapshot.data !=
                                                                null
                                                            ? snapshot.data!
                                                                ? Colors.green
                                                                : Colors.grey
                                                            : Colors.grey,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                                ValueListenableBuilder(
                                    valueListenable:
                                        appValueNotifier.globalisCallOnGoing,
                                    builder: (context, boolValue, widget) {
                                      return Row(
                                        children: [
                                          InkWell(
                                              onTap: !boolValue
                                                  ? () async {
                                                      appValueNotifier
                                                          .setToInitial();
                                                      callValueNotifiers
                                                          .setToInitial();
                                                      await callsetting(
                                                          calltype: true);
                                                      // CallMethods().makeCall(
                                                      //     context,
                                                      //     widget.contactModel.name,
                                                      //     widget.contactModel.contactId,
                                                      //     widget.contactModel.photoUrl);
                                                      // Navigator.of(context).push(MaterialPageRoute(
                                                      //     builder: (context) => const CallScreen(
                                                      //         // model: widget.contactModel,
                                                      //         // isAudioCall: true,
                                                      //         )));
                                                    }
                                                  : null,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.call,
                                                  size: 25,
                                                  color: boolValue
                                                      ? mainColorFaded
                                                      : mainColor,
                                                ),
                                              )),
                                          InkWell(
                                              onTap: !boolValue
                                                  ? () async {
                                                      appValueNotifier
                                                          .setToInitial();
                                                      callValueNotifiers
                                                          .setToInitial();

                                                      await callsetting(
                                                          calltype: false);
                                                      // Navigator.of(context).push(MaterialPageRoute(
                                                      //     builder: (context) => CallScreen(
                                                      //           model: widget.contactModel,
                                                      //           isAudioCall: false,
                                                      //         )));
                                                    }
                                                  : null,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.videocam,
                                                  size: 30,
                                                  color: boolValue
                                                      ? mainColorFaded
                                                      : mainColor,
                                                ),
                                              )),
                                          InkWell(
                                              onTap: _toggle,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.more_vert,
                                                  size: 25,
                                                  color: Colors.black,
                                                ),
                                              )),
                                        ],
                                      );
                                    })
                              ],
                            ),
                          ),
                    floatingActionButton: _getFloatingButton(),
                    body: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        _TabSwitch(
                          value: pageIndex,
                          callBack: () {
                            setState(() {
                              if (pageIndex == 0) {
                                pageIndex = 1;
                              } else {
                                pageIndex = 0;
                              }
                            });
                          },
                        ),
                        // pageIndex == 0
                        //     ? Expanded(
                        //         child: Column(
                        //           children: [
                        //             Expanded(
                        //                 child: ChatList(
                        //               chatModel: widget.contactModel,
                        //               changeState: changeShowOptions,
                        //             )),
                        //             MyTextField(model: widget.contactModel),
                        //           ],
                        //         ),
                        //       )
                        //     : TodoScreen(id: widget.contactModel.contactId),
                        pageIndex == 0
                            ? Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                        child: showOptions
                                            ? ListView.builder(
                                                key: listViewKey,
                                                controller: messageController,
                                                itemCount:
                                                    tempMessage.length + 1,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder: ((context, index) {
                                                  var messageData;
                                                  if (index !=
                                                      tempMessage.length) {
                                                    messageData =
                                                        tempMessage[index];
                                                    if (messageData.messageId ==
                                                        messageData
                                                            .recieverid) {
                                                      isTyping = true;
                                                    } else {
                                                      var timeSent = DateFormat
                                                              .jm()
                                                          .format(messageData
                                                              .timeSent);
                                                      if (!messageData.isSeen &&
                                                          messageData
                                                                  .recieverid ==
                                                              firebaseAuth
                                                                  .currentUser!
                                                                  .uid) {
                                                        ChatMethods()
                                                            .setChatMessageSeen(
                                                          widget.contactModel
                                                              .contactId,
                                                          messageData.messageId,
                                                        );
                                                      }
                                                      if (messageData
                                                              .senderId ==
                                                          firebaseAuth
                                                              .currentUser!
                                                              .uid) {
                                                        return InkWell(
                                                          onTap: (() {
                                                            {
                                                              if (messageId.contains(
                                                                  messageData
                                                                      .messageId)) {
                                                                decrementSelectedNum();

                                                                messageId.remove(
                                                                    messageData
                                                                        .messageId);
                                                              } else {
                                                                incrementSelectedNum();

                                                                messageId.add(
                                                                    messageData
                                                                        .messageId);
                                                              }
                                                            }
                                                          }),
                                                          child: MyMessageCard(
                                                            message: messageData
                                                                .text,
                                                            date: timeSent,
                                                            isSeen: messageData
                                                                .isSeen,
                                                            type: messageData
                                                                .type,
                                                            isSelected: messageId
                                                                .contains(
                                                                    messageData
                                                                        .messageId),
                                                            repliedText: messageData
                                                                .repliedMessage,
                                                            username:
                                                                messageData
                                                                    .repliedTo,
                                                            repliedMessageType:
                                                                messageData
                                                                    .repliedMessageType,
                                                            longPress:
                                                                changeShowOptions,
                                                          ),
                                                        );
                                                      }
                                                      return InkWell(
                                                        onTap: (() {
                                                          {
                                                            if (messageId.contains(
                                                                messageData
                                                                    .messageId)) {
                                                              decrementSelectedNum();

                                                              messageId.remove(
                                                                  messageData
                                                                      .messageId);
                                                            } else {
                                                              incrementSelectedNum();

                                                              messageId.add(
                                                                  messageData
                                                                      .messageId);
                                                            }
                                                          }
                                                        }),
                                                        child:
                                                            SenderMessageCard(
                                                          photoUrl: widget
                                                              .contactModel
                                                              .photoUrl,
                                                          message:
                                                              messageData.text,
                                                          date: timeSent,
                                                          type:
                                                              messageData.type,
                                                          username: messageData
                                                              .repliedTo,
                                                          isSelected: messageId
                                                              .contains(
                                                                  messageData
                                                                      .messageId),
                                                          repliedMessageType:
                                                              messageData
                                                                  .repliedMessageType,
                                                          longPress: () {},
                                                          repliedText: messageData
                                                              .repliedMessage,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  return const SizedBox();
                                                }),
                                              )
                                            : StreamBuilder<List<Message>>(
                                                stream: ChatMethods()
                                                    .getChatStream(widget
                                                        .contactModel
                                                        .contactId),
                                                builder: (context, snapshot) {
                                                  isTyping = false;

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container();
                                                  }
                                                  if (!showOptions) {
                                                    SchedulerBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      messageController.jumpTo(
                                                          messageController
                                                              .position
                                                              .maxScrollExtent);
                                                    });
                                                  } else {
                                                    SchedulerBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      messageController.jumpTo(
                                                          messageController
                                                              .offset);
                                                    });
                                                  }
                                                  return ListView.builder(
                                                    key: listViewKey,
                                                    controller:
                                                        messageController,
                                                    itemCount:
                                                        snapshot.data!.length +
                                                            1,
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      tempMessage =
                                                          snapshot.data!;
                                                      var messageData;
                                                      if (index !=
                                                          snapshot
                                                              .data!.length) {
                                                        messageData = snapshot
                                                            .data![index];
                                                        if (messageData
                                                                .messageId ==
                                                            messageData
                                                                .recieverid) {
                                                          isTyping = true;
                                                        } else {
                                                          var timeSent = DateFormat
                                                                  .jm()
                                                              .format(messageData
                                                                  .timeSent);
                                                          if (!messageData
                                                                  .isSeen &&
                                                              messageData
                                                                      .recieverid ==
                                                                  firebaseAuth
                                                                      .currentUser!
                                                                      .uid) {
                                                            ChatMethods()
                                                                .setChatMessageSeen(
                                                              widget
                                                                  .contactModel
                                                                  .contactId,
                                                              messageData
                                                                  .messageId,
                                                            );
                                                          }
                                                          if (messageData
                                                                  .senderId ==
                                                              firebaseAuth
                                                                  .currentUser!
                                                                  .uid) {
                                                            return InkWell(
                                                              onLongPress: () {
                                                                changeShowOptions();
                                                                messageId.add(
                                                                    messageData
                                                                        .messageId);
                                                              },

                                                              // onTap: (() {
                                                              //   if (showOptions) {
                                                              //     if (messageId.contains(
                                                              //         messageData
                                                              //             .messageId)) {
                                                              //       incrementSelectedNum();
                                                              //       messageId.remove(
                                                              //           messageData
                                                              //               .messageId);
                                                              //     } else {
                                                              //       decrementSelectedNum();
                                                              //       messageId.add(
                                                              //           messageData
                                                              //               .messageId);
                                                              //     }
                                                              //   }
                                                              // }),
                                                              child:
                                                                  MyMessageCard(
                                                                message:
                                                                    messageData
                                                                        .text,
                                                                date: timeSent,
                                                                isSeen:
                                                                    messageData
                                                                        .isSeen,
                                                                type:
                                                                    messageData
                                                                        .type,
                                                                repliedText:
                                                                    messageData
                                                                        .repliedMessage,
                                                                username:
                                                                    messageData
                                                                        .repliedTo,
                                                                repliedMessageType:
                                                                    messageData
                                                                        .repliedMessageType,
                                                                longPress:
                                                                    changeShowOptions,
                                                              ),
                                                            );
                                                          }
                                                          return InkWell(
                                                            onLongPress: () {
                                                              changeShowOptions();
                                                              messageId.add(
                                                                  messageData
                                                                      .messageId);
                                                            },
                                                            child:
                                                                SenderMessageCard(
                                                              photoUrl: widget
                                                                  .contactModel
                                                                  .photoUrl,
                                                              message:
                                                                  messageData
                                                                      .text,
                                                              date: timeSent,
                                                              type: messageData
                                                                  .type,
                                                              username:
                                                                  messageData
                                                                      .repliedTo,
                                                              repliedMessageType:
                                                                  messageData
                                                                      .repliedMessageType,
                                                              longPress:
                                                                  changeShowOptions,
                                                              repliedText:
                                                                  messageData
                                                                      .repliedMessage,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                      if (index ==
                                                              snapshot.data!
                                                                  .length &&
                                                          isTyping) {
                                                        return SenderMessageCard(
                                                          photoUrl: "",
                                                          message: "Typing...",
                                                          date: "null",
                                                          type:
                                                              MessageEnum.text,
                                                          username: "",
                                                          repliedMessageType:
                                                              MessageEnum.text,
                                                          longPress: () {},
                                                          repliedText: '',
                                                        );
                                                      }
                                                      return const SizedBox();
                                                    }),
                                                  );
                                                })),
                                    MyTextField(model: widget.contactModel),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: TodoScreen(
                                    id: widget.contactModel.contactId)),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showBlockDialog() {
    showDialog(
        context: context,
        builder: (ctxt) => AlertDialog(
              title: const Text("Alert"),
              content: Text(isBlocked
                  ? "You are about to unblock ${widget.contactModel.name}"
                  : "Are you sure you want to block this user?"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      ChatMethods()
                          .blockUnblockUser(widget.contactModel.contactId);
                      Navigator.pop(context);
                    },
                    child: const Text("Continue")),
              ],
            ));
  }

  _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (ctxt) => AlertDialog(
              title: const Text("Alert"),
              content: const Text("Are you sure you want to delete this chat?"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      ChatMethods()
                          .deleteContactMessage(widget.contactModel.contactId);
                      Navigator.pop(context);
                    },
                    child: const Text("Continue")),
              ],
            ));
  }

  Future<void> callsetting({required bool calltype}) async {
    setState(() {
      appValueNotifier.globalisCallOnGoing.value = true;
    });
    CHANNEL_NAME =
        widget.contactModel.contactId + firebaseAuth.currentUser!.uid;
    // var response = await get_call_token();
    // CHANNEL_NAME = response['channelname'];
    // TOKEN = response['token'];
    callValueNotifiers.setSpeakerValue(!calltype);
    callValueNotifiers.setIsVideoOn(!calltype);
    VIDEO_OR_AUDIO_FLG = calltype;
    // CALLERDATA = user;
    // new UserModel().pickcall;
    var msg = {
      'token': {'token': TOKEN, 'channelname': CHANNEL_NAME},
      'call_type':
          VIDEO_OR_AUDIO_FLG == false ? "video_channel" : "call_channel",
      'user_info': userInfo,
      'uid': userInfo.uid,
    };
    print(msg);

    // await firebaseFirestore
    //     .collection('users')
    //     .doc(userInfo.uid)
    //     .update({'pickcall': false, 'rejectcall': false});
    // clickbtn = true;
    setState(() {});
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DialScreen()));
    //starting the call using the call kit
    //starting a call
    SharedPrefrenceUser.setCallerName(CALLERDATA['name']);

    CallKitParams params = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: CALLERDATA != null
          ? CALLERDATA['name'] ?? "Nothing to show"
          : "Nothing to show",
      handle: '',
      type: VIDEO_OR_AUDIO_FLG == false ? 1 : 0,
      extra: <String, dynamic>{},
      android: const AndroidParams(
          isCustomNotification: true,
          isCustomSmallExNotification: true,
          isShowLogo: true,
          isShowCallback: false,
          isShowMissedCallNotification: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#091C40',
          // backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call"),
      ios: IOSParams(
        // iconName: 'Your Team',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.startCall(params);

    await send_fcm_call(
        token: usermodel?.token,
        name: userInfo == null ? "" : userInfo.username,
        title: "Call",
        msg: msg,
        btnstatus:
            VIDEO_OR_AUDIO_FLG == false ? "video_channel" : "call_channel");
  }
}

class MyTextField extends StatefulWidget {
  final ChatContactModel model;

  const MyTextField({required this.model, super.key});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isShowSendButton = false;
  int pageIndex = 0;
  bool isShowEmojiContainer = false;
  RecorderController? _controller;
  bool isRecorderInit = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  bool isBlocked = false;
  @override
  void initState() {
    super.initState();
    getBlock();
    _controller = RecorderController();
    _controller!.updateFrequency =
        const Duration(milliseconds: 100); // Update speed of new wave
    _controller!.androidEncoder =
        AndroidEncoder.aac; // Changing android encoder
    _controller!.androidOutputFormat =
        AndroidOutputFormat.mpeg4; // Changing android output format
    _controller!.iosEncoder =
        IosEncoder.kAudioFormatMPEG4AAC; // Changing ios encoder
    _controller!.sampleRate = 44100; // Updating sample rate
    _controller!.bitRate = 48000; // Updating bitrate
    // _controller!.currentScrolledDuration; // Current duration position notifier
    openAudio();
  }

  getBlock() async {
    isBlocked = await ChatMethods().checkMessageAllowed(widget.model.contactId);
    setState(() {});
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // throw RecordingPermissionException('Mic permission not allowed!');
    }
    // await _controller!.openRecorder();
    // isRecorderInit = true;
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _controller!.dispose();
    isRecorderInit = false;
    ChatMethods().stopTyping(widget.model.contactId);
  }

  void sendTextMessage() async {
    if (isShowSendButton) {
      if (_messageController.text.isNotEmpty) {
        ChatMethods().sendTextMessage(
            context: context,
            text: _messageController.text.trim(),
            recieverUserId: widget.model.contactId,
            senderUser: userInfo,
            messageReply: null);
        setState(() {
          _messageController.text = '';
          ChatMethods().stopTyping(widget.model.contactId);
        });
      }
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      // if (!isRecorderInit) {
      //   return;
      // }
      if (isRecording) {
        final path = await _controller!.stop();
        showToastMessage("Sending Recording");
        sendFileMessage(File(path!), MessageEnum.audio);
      } else {
        await _controller!.record(path: path);
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
    if (!isShowSendButton) {
      // ChatMethods()
      //     .updateTyping(widget.model.contactId, true);
      setState(() {
        isShowSendButton = true;
      });
    } else {
      // ChatMethods().updateTyping(widget.model.contactId, false);
      setState(() {
        isShowSendButton = false;
      });
    }
  }

  void cancelRecording() {
    _controller!.stop();
    showToastMessage("Recording Cancelled");
    setState(() {
      isRecording = !isRecording;
    });
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ChatMethods().sendFileMessage(
        context: context,
        file: file,
        recieverUserId: widget.model.contactId,
        messageEnum: messageEnum,
        senderUserData: userInfo,
        messageReply: null);
  }

  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      showToastMessage("Sending File");
      sendFileMessage(file, MessageEnum.file);
    } else {
      // User canceled the picker
    }
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      showToastMessage("Sending Image");
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      showToastMessage("Sending Video");
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: ChatMethods().getBlockStatus(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 15, left: 15),
              child: snapshot.data!.blockList.contains(widget.model.contactId)
                  ? const Text("You have blocked this user")
                  : Column(
                      children: [
                        if (messageReply != null)
                          MessageReplyPreview(
                              photoUrl: widget.model.photoUrl,
                              messageReply: messageReply),
                        Row(
                          children: [
                            if (isRecording)
                              AudioWaveforms(
                                size: Size(
                                    MediaQuery.of(context).size.width / 1.95,
                                    30.0),
                                recorderController: _controller!,
                                enableGesture: false,
                                padding: const EdgeInsets.all(20),
                                waveStyle: const WaveStyle(
                                  waveColor: mainColor,
                                  waveThickness: 5,
                                  backgroundColor: Colors.black,
                                  showDurationLabel: true,
                                  spacing: 8.0,
                                  durationStyle: TextStyle(color: mainColor),
                                  showBottom: true,
                                  extendWaveform: true,
                                  durationLinesColor: mainColor,
                                  showMiddleLine: false,
                                  //   gradient: ui.Gradient.linear(
                                  //     const Offset(70, 50),
                                  //     // Offset(MediaQuery.of(context).size.width / 2, 0),
                                  //     [Colors.red, Colors.green],
                                  // ),
                                ),
                              ),
                            if (!isRecording)
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        focusNode: focusNode,
                                        controller: _messageController,
                                        autofocus: false,
                                        maxLines: 10,
                                        minLines: 1,
                                        // onFieldSubmitted: (val) {
                                        //   if (_messageController
                                        //       .text.isNotEmpty) {
                                        //     sendTextMessage();
                                        //   }
                                        // },
                                        onChanged: (val) {
                                          if (!isBlocked) {
                                            // log(isBlocked.toString());
                                            ChatMethods().setTyping(
                                                widget.model.contactId);
                                          }

                                          _messageController.selection =
                                              TextSelection.collapsed(
                                                  offset: _messageController
                                                      .text.length);

                                          if (val.isNotEmpty) {
                                            if (!isShowSendButton) {
                                              // ChatMethods()
                                              //     .updateTyping(widget.model.contactId, true);
                                              setState(() {
                                                isShowSendButton = true;
                                              });
                                            }
                                          } else {
                                            // ChatMethods().updateTyping(widget.model.contactId, false);
                                            setState(() {
                                              isShowSendButton = false;
                                            });
                                            ChatMethods().stopTyping(
                                                widget.model.contactId);
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Message',
                                          prefixIcon: IconButton(
                                            onPressed:
                                                toggleEmojiKeyboardContainer,
                                            icon: const Icon(
                                              Icons.emoji_emotions,
                                              color: mainColor,
                                            ),
                                          ),
                                          suffixIcon: SizedBox(
                                            width: isShowSendButton ? 0 : 100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: selectFile,
                                                  color: Colors.grey,
                                                  icon: const Icon(
                                                      Icons.attach_file),
                                                ),
                                                if (!isShowSendButton)
                                                  IconButton(
                                                    onPressed: selectImage,
                                                    color: Colors.grey,
                                                    icon: const Icon(
                                                        Icons.camera_alt),
                                                  )
                                              ],
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: mainColor,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: mainColor,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (isRecording)
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      cancelRecording();
                                    },
                                    child: const CircleAvatar(
                                      radius: 28,
                                      child: Icon(
                                        Icons.close,
                                        // ? Icons.close
                                        // : Icons.mic,

                                        size: 35,
                                        color: Colors.red,
                                      ),
                                    )),
                              ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () {
                                  sendTextMessage();
                                },
                                child: CircleAvatar(
                                  radius: 28,
                                  child: Icon(
                                    isShowSendButton
                                        ? Icons.send
                                        : isRecording
                                            ? Icons.send
                                            : Icons.mic,
                                    // ? Icons.close
                                    // : Icons.mic,

                                    size: 35,
                                  ),
                                ))
                          ],
                        ),
                        isShowEmojiContainer
                            ? SizedBox(
                                height: 310,
                                child: EmojiPicker(
                                  onEmojiSelected: ((category, emoji) {
                                    setState(() {
                                      _messageController.text =
                                          _messageController.text + emoji.emoji;
                                      _messageController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: _messageController
                                                      .text.length));
                                    });
                                    //       TextSelection(
                                    //           baseOffset:
                                    //               (_messageController.text +
                                    //                       emoji.emoji)
                                    //                   .length,
                                    //           extentOffset:
                                    //               (_messageController.text +
                                    //                       emoji.emoji)
                                    //                   .length);
                                    // });

                                    if (!isShowSendButton) {
                                      setState(() {
                                        isShowSendButton = true;
                                      });
                                    }
                                  }),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 25, right: 15, left: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    if (isRecording)
                      AudioWaveforms(
                        size: Size(
                            MediaQuery.of(context).size.width / 1.95, 30.0),
                        recorderController: _controller!,
                        enableGesture: false,
                        padding: const EdgeInsets.all(20),
                        waveStyle: const WaveStyle(
                          waveColor: mainColor,
                          waveThickness: 5,
                          backgroundColor: Colors.black,
                          showDurationLabel: true,
                          spacing: 8.0,
                          durationStyle: TextStyle(color: mainColor),
                          showBottom: true,
                          extendWaveform: true,
                          durationLinesColor: mainColor,
                          showMiddleLine: false,
                          //   gradient: ui.Gradient.linear(
                          //     const Offset(70, 50),
                          //     // Offset(MediaQuery.of(context).size.width / 2, 0),
                          //     [Colors.red, Colors.green],
                          // ),
                        ),
                      ),
                    // if (messageReply != null)

                    if (!isRecording)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxHeight: 100, maxWidth: 100),
                                child: TextFormField(
                                  focusNode: focusNode,
                                  controller: _messageController,
                                  autofocus: false,
                                  onFieldSubmitted: (val) {
                                    if (_messageController.text.isNotEmpty) {
                                      sendTextMessage();
                                    }
                                  },
                                  onChanged: (val) {
                                    if (val.isNotEmpty) {
                                      if (!isShowSendButton) {
                                        setState(() {
                                          isShowSendButton = true;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isShowSendButton = false;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Message',
                                    prefixIcon: IconButton(
                                      onPressed: toggleEmojiKeyboardContainer,
                                      icon: const Icon(
                                        Icons.emoji_emotions,
                                        color: mainColor,
                                      ),
                                    ),
                                    suffixIcon: SizedBox(
                                      width: isShowSendButton ? 0 : 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: selectFile,
                                            color: Colors.grey,
                                            icon: const Icon(Icons.attach_file),
                                          ),
                                          if (!isShowSendButton)
                                            IconButton(
                                              onPressed: selectImage,
                                              color: Colors.grey,
                                              icon:
                                                  const Icon(Icons.camera_alt),
                                            )
                                        ],
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: mainColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: mainColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (isRecording)
                      Expanded(
                        child: InkWell(
                            onTap: () {
                              cancelRecording();
                            },
                            child: const CircleAvatar(
                              radius: 28,
                              child: Icon(
                                Icons.close,
                                // ? Icons.close
                                // : Icons.mic,

                                size: 35,
                                color: Colors.red,
                              ),
                            )),
                      ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () {
                          sendTextMessage();
                        },
                        child: CircleAvatar(
                          radius: 28,
                          child: Icon(
                            isShowSendButton
                                ? Icons.send
                                : isRecording
                                    ? Icons.send
                                    : Icons.mic,
                            // ? Icons.close
                            // : Icons.mic,

                            size: 35,
                          ),
                        ))
                  ],
                ),
                isShowEmojiContainer
                    ? SizedBox(
                        height: 310,
                        child: EmojiPicker(
                          onEmojiSelected: ((category, emoji) {
                            setState(() {
                              _messageController.text =
                                  _messageController.text + emoji.emoji;
                            });

                            if (!isShowSendButton) {
                              setState(() {
                                isShowSendButton = true;
                              });
                            }
                          }),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          );
        });
  }
}

class _TabSwitch extends StatefulWidget {
  int value;
  VoidCallback callBack;
  _TabSwitch({Key? key, required this.value, required this.callBack})
      : super(key: key);

  @override
  State<_TabSwitch> createState() => _TabSwitchState();
}

class _TabSwitchState extends State<_TabSwitch> {
  bool isChat = true;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (widget.value == 0) {
      isChat = true;
    } else {
      isChat = false;
    }
    return GestureDetector(
      onTap: widget.callBack,
      child: Container(
        height: 50,
        width: size.width / 1.2,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(35)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isChat ? 0 : size.width / 1.2 * 0.5,
              child: Container(
                height: 50,
                width: size.width / 1.2 * 0.5,
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(35)),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Chats",
                      style: TextStyle(
                          color: isChat ? Colors.white : mainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "To Do's",
                      style: TextStyle(
                          color: isChat ? mainColor : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
