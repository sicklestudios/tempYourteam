// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:intl/intl.dart';
// import 'package:yourteam/constants/constant_utils.dart';
// import 'package:yourteam/constants/constants.dart';
// import 'package:yourteam/constants/message_enum.dart';
// import 'package:yourteam/constants/message_reply.dart';
// import 'package:yourteam/methods/chat_methods.dart';
// import 'package:yourteam/models/chat_model.dart';
// import 'package:yourteam/screens/toppages/chat/widgets/my_message_card.dart';
// import 'package:yourteam/screens/toppages/chat/widgets/sender_message_card.dart';

// class ChatList extends StatefulWidget {
//   final ChatContactModel chatModel;
//   final VoidCallback changeState;

//   const ChatList(
//       {super.key, required this.chatModel, required this.changeState});

//   @override
//   State<ChatList> createState() => _ChatListState();
// }

// class _ChatListState extends State<ChatList> {
//   final ScrollController messageController = ScrollController();
//   @override
//   void initState() {
//     super.initState();
//     ChatMethods().setChatContactMessageSeen(widget.chatModel.contactId);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     messageController.dispose();
//   }

//   bool isTyping = false;
//   void onMessageSwipe(
//     String message,
//     bool isMe,
//     MessageEnum messageEnum,
//   ) {
//     messageReply = MessageReply(
//       message,
//       isMe,
//       messageEnum,
//     );
//     setState(() {});
//   }

//   // void onLongPress(Message message) {
//   //   widget.changeState;
//   //   messages.add(message);
//   //   setState(() {});
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Message>>(
//         stream: ChatMethods().getChatStream(widget.chatModel.contactId),
//         builder: (context, snapshot) {
//           isTyping = false;

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Container();
//           }
//           SchedulerBinding.instance.addPostFrameCallback((_) {
//             messageController
//                 .jumpTo(messageController.position.maxScrollExtent);
//           });
//           return ListView.builder(
//             controller: messageController,
//             itemCount: snapshot.data!.length + 1,
//             shrinkWrap: true,
//             itemBuilder: ((context, index) {
//               var messageData;
//               if (index != snapshot.data!.length) {
//                 messageData = snapshot.data![index];
//                 if (messageData.messageId == messageData.recieverid) {
//                   isTyping = true;
//                 } else {
//                   var timeSent = DateFormat.jm().format(messageData.timeSent);
//                   if (!messageData.isSeen &&
//                       messageData.recieverid == firebaseAuth.currentUser!.uid) {
//                     ChatMethods().setChatMessageSeen(
//                       widget.chatModel.contactId,
//                       messageData.messageId,
//                     );
//                   }
//                   if (messageData.senderId == firebaseAuth.currentUser!.uid) {
//                     return MyMessageCard(
//                       message: messageData.text,
//                       date: timeSent,
//                       isSeen: messageData.isSeen,
//                       type: messageData.type,
//                       repliedText: messageData.repliedMessage,
//                       username: messageData.repliedTo,
//                       repliedMessageType: messageData.repliedMessageType,
//                       longPress: () => onLongPress(
//                         messageData,
//                       ),
//                     );
//                   }
//                   return SenderMessageCard(
//                     message: messageData.text,
//                     date: timeSent,
//                     type: messageData.type,
//                     username: messageData.repliedTo,
//                     repliedMessageType: messageData.repliedMessageType,
//                     onRightSwipe: () => onMessageSwipe(
//                       messageData.text,
//                       false,
//                       messageData.type,
//                     ),
//                     repliedText: messageData.repliedMessage,
//                   );
//                 }
//               }
//               if (index == snapshot.data!.length && isTyping) {
//                 return SenderMessageCard(
//                   message: "Typing...",
//                   date: "null",
//                   type: MessageEnum.text,
//                   username: "",
//                   repliedMessageType: MessageEnum.text,
//                   onRightSwipe: () {},
//                   repliedText: '',
//                 );
//               }
//               return const SizedBox();
//             }),
//           );
//         });
//   }
// }
