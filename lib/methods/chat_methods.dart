import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/constants/message_enum.dart';
import 'package:yourteam/constants/message_reply.dart';
import 'package:yourteam/methods/info_storage_methods.dart';
import 'package:yourteam/methods/storage_methods.dart';
import 'package:yourteam/models/chat_model.dart';
import 'package:yourteam/models/user_model.dart';
import 'package:yourteam/service/local_push_notification.dart';

class ChatMethods {
  void _saveContactMessageAfterDeletion(
    String text,
    DateTime timeSent,
    String lastMessageId,
    String recieverUserId,
  ) async {
    // users -> current user id  => chats -> reciever user id -> set data
    //  var timeSent = DateTime.now();
    UserModel? recieverUserData;
    var userDataMap =
        await firebaseFirestore.collection('users').doc(recieverUserId).get();
    recieverUserData = UserModel.getValuesFromSnap(userDataMap);

    var senderChatContact = ChatContactModel(
        name: recieverUserData.username,
        photoUrl: recieverUserData.photoUrl,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        lastMessageId: lastMessageId,
        lastMessageBy: firebaseAuth.currentUser!.uid,
        isSeen: true);

    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String lastMessageId,
    String recieverUserId,
  ) async {
// users -> reciever user id => chats -> current user id -> set data
    var recieverChatContact = ChatContactModel(
        // name: senderUserData.username,
        name: senderUserData.username,
        photoUrl: senderUserData.photoUrl,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        lastMessageId: lastMessageId,
        lastMessageBy: firebaseAuth.currentUser!.uid,
        isSeen: false);

    //checking if the receiver has blocked this user
    if (!await checkMessageAllowed(recieverUserId)) {
      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .set(
            recieverChatContact.toMap(),
          );
    }

    // users -> current user id  => chats -> reciever user id -> set data
    var senderChatContact = ChatContactModel(
        name: recieverUserData!.username,
        photoUrl: recieverUserData.photoUrl,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        lastMessageId: lastMessageId,
        lastMessageBy: firebaseAuth.currentUser!.uid,
        isSeen: false);

    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
    // }
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? recieverUserName,
  }) async {
    final message = Message(
      senderId: firebaseAuth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );

    // users -> sender id -> reciever id -> messages -> message id -> store message
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
    // users -> eeciever id  -> sender id -> messages -> message id -> store message
    if (!await checkMessageAllowed(recieverUserId)) {
      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
      DocumentSnapshot documentSnapshot =
          await firebaseFirestore.collection('users').doc(recieverUserId).get();
      //receivers token for sending notification to the user
      String token = documentSnapshot.get('token');
      sendNotification(recieverUserId, token, "You have a new message");
      //adding the message to the collection of infos
      if (message.type == MessageEnum.link) {
        InfoStorage().storeLink(timeSent, text, recieverUserId);
      } else if (message.type == MessageEnum.file) {
        String fileName = text.substring(0, text.indexOf("@@@"));
        String url = text.substring(text.indexOf("@@@") + 3, text.length);
        InfoStorage().storeFile(timeSent, url, fileName, recieverUserId,
            firebaseAuth.currentUser!.uid);
      } else if (message.type == MessageEnum.image) {
        InfoStorage().storeMedia(
            timeSent, text, recieverUserId, firebaseAuth.currentUser!.uid);
      }
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      {
        var userDataMap = await firebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.getValuesFromSnap(userDataMap);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        messageId,
        recieverUserId,
      );
      MessageEnum val;
      if (text.toLowerCase().startsWith("http:") ||
          text.toLowerCase().startsWith("https:")) {
        val = MessageEnum.link;
      } else {
        val = MessageEnum.text;
      }
      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: val,
        messageId: messageId,
        username: senderUser.username,
        messageReply: messageReply,
        recieverUserName: recieverUserData.username,
        senderUsername: senderUser.username,
      );
    } catch (e) {
      showFloatingFlushBar(context, "Error", e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await StorageMethods().storeFileToFirebase(
        'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
        file,
      );

      UserModel? recieverUserData;
      {
        var userDataMap = await firebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.getValuesFromSnap(userDataMap);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.link:
          contactMsg = 'Link';
          break;
        case MessageEnum.file:
          contactMsg = basename(file.path);
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        messageId,
        recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: messageEnum == MessageEnum.file
            ? "$contactMsg@@@$imageUrl"
            : imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.username,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserName: recieverUserData.username,
        senderUsername: senderUserData.username,
      );
    } catch (e) {
      showFloatingFlushBar(context, "Error", e.toString());
    }
  }

  void sendForwardedFileMessage({
    required BuildContext context,
    required String fileUrl,
    required String recieverUserId,
    required UserModel senderUserData,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      // String imageUrl = await StorageMethods().storeFileToFirebase(
      //   'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
      //   file,
      // );

      UserModel? recieverUserData;
      {
        var userDataMap = await firebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.getValuesFromSnap(userDataMap);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.link:
          contactMsg = 'Link';
          break;
        // case MessageEnum.file:
        //   contactMsg = fileUrl;
        //   break;
        default:
          contactMsg = 'GIF';
      }
      String fileName = "";
      if (messageEnum == MessageEnum.file) {
        fileName = fileUrl.substring(0, fileUrl.indexOf("@@@"));
      }

      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        messageEnum == MessageEnum.file ? fileName : contactMsg,
        timeSent,
        messageId,
        recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: fileUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.username,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserName: recieverUserData.username,
        senderUsername: senderUserData.username,
      );
    } catch (e) {
      showFloatingFlushBar(context, "Error", e.toString());
    }
  }

  // stremas
  Stream<List<ChatContactModel>> getChatContacts() {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<ChatContactModel> contacts = [];
      for (var document in event.docs) {
        try {
          var chatContact = ChatContactModel.fromMap(document.data());
          contacts.add(chatContact);
        } catch (e) {
          log(e.toString());
        }
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy(
          'timeSent',
        )
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  //get online status
  Stream<bool> getOnlineStream(String recieverUserId) {
    return firebaseFirestore
        .collection('users')
        .doc(recieverUserId)
        .snapshots()
        .map((event) {
      return UserModel.getValuesFromSnap(event).isOnline;
    });
  }

  //get online status
  Stream<UserModel> getBlockStatus() {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .snapshots()
        .map((event) {
      return UserModel.getValuesFromSnap(event);
    });
  }

  //to check if the receiving user has blocked or not
  //if the sender is blocked it will return true else false
  Future<bool> checkMessageAllowed(String recieverUserId) async {
    return await _getBlockInfo(recieverUserId).then((value) {
      if (value.blockList.contains(firebaseAuth.currentUser!.uid)) {
        log("blocked");
        return true;
      } else {
        log("noit blocked");
        return false;
      }
    });
  }

  //get online status
  Future<UserModel> _getBlockInfo(String receiverId) async {
    return await firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .get()
        .then((event) {
      return UserModel.getValuesFromSnap(event);
    });
  }

  void setTyping(String recieverUserId) async {
    // if (await checkMessageAllowed(recieverUserId))
    {
      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('messages')
          .doc(firebaseAuth.currentUser!.uid)
          .set(Message(
            senderId: firebaseAuth.currentUser!.uid,
            recieverid: recieverUserId,
            text: "Typing...",
            type: MessageEnum.text,
            timeSent: DateTime.now(),
            messageId: firebaseAuth.currentUser!.uid,
            isSeen: false,
            repliedMessage: "",
            repliedTo: "",
            repliedMessageType: MessageEnum.text,
          ).toMap());
      log("Setting type");
    }
  }

  void stopTyping(String recieverUserId) async {
    await firebaseFirestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('messages')
        .doc(firebaseAuth.currentUser!.uid)
        .delete();
  }

  void deleteSingleMessage(
      {required String recieverUserId, required String messageId}) async {
    //if it was the last message than delete the contact model
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .get()
        .then((value) {
      if (value.docs.length == 1) {
        //if there is only one message there than delete the contact model
        deleteContactMessage(recieverUserId);
      } else {
        updateContactMessage(value, messageId, recieverUserId);
      }
    });
  }

  void updateContactMessage(
      QuerySnapshot value, String messageId, String recieverUserId) async {
    //firstly getting the message reference
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .delete();

//going to the contact model and checking if the deleted message was the last message
//if it was the last message than update the contact model

    ChatContactModel? contactModel;
    Message? sendableMessage;
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .get()
        .then((value) async {
      contactModel = ChatContactModel.fromMap(value.data()!);
      if (contactModel!.lastMessageId == messageId) {
        await firebaseFirestore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('chats')
            .doc(recieverUserId)
            .collection('messages')
            .orderBy('timeSent', descending: true)
            .get()
            .then((value) {
          // DateTime time=DateTime();
          // value.docs.forEach((element) {
          // var message = Message.fromMap(element.data());
          //   if (message.timeSent.isAfter(time!)) {
          //     sendableMessage = message;
          //   }
          var message = Message.fromMap(value.docs[0].data());
          sendableMessage = message;
        });
        String contactMsg;
        switch (sendableMessage!.type) {
          case MessageEnum.text:
            contactMsg = sendableMessage!.text;
            break;
          case MessageEnum.image:
            contactMsg = '📷 Photo';
            break;
          case MessageEnum.video:
            contactMsg = '📸 Video';
            break;
          case MessageEnum.audio:
            contactMsg = '🎵 Audio';
            break;
          case MessageEnum.link:
            contactMsg = sendableMessage!.text;
            break;
          case MessageEnum.file:
            contactMsg = sendableMessage!.text
                .substring(0, sendableMessage!.text.indexOf("@@@"));
            break;
          default:
            contactMsg = 'GIF';
        }

        _saveContactMessageAfterDeletion(contactMsg, sendableMessage!.timeSent,
            sendableMessage!.messageId, recieverUserId);
      }
      // });
      // }
    });
  }

// streams
  Future<List<UserModel>> getContacts() {
    List<UserModel> contactUsers = [];

    return firebaseFirestore.collection('users').get().then((event) {
      // log(event.docs[0].data().toString());
      for (var document in event.docs) {
        try {
          var userVal = UserModel.getValuesFromSnap(document);
          if (userVal.uid != firebaseAuth.currentUser!.uid) {
            if (userInfo.contacts.contains(userVal.uid)) {
              contactUsers.add(userVal);
            }
          }
        } catch (e) {
          log(e.toString());
        }
      }
      return contactUsers;
    });
  }

  void deleteContactMessage(String recieverUserId) async {
    var ref = firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId);

    //deleting the subcollections
    ref.collection("messages").get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    ref.delete();
    // doc.update(
    //   {"showStatus": false},
    // );
  }

  void setChatMessageSeen(
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .update({'isSeen': true});

      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'isSeen': true});
    } catch (e) {
      // showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatContactMessageSeen(
    String recieverUserId,
  ) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .update({'isSeen': true});

      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'isSeen': true});
    } catch (e) {
      // showSnackBar(context: context, content: e.toString());
    }
  }

  blockUnblockUser(String receiverUid) async {
    var ref = firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser?.uid);

    DocumentSnapshot snapshot = await ref.get();
    if ((snapshot.data()! as dynamic)['blockList'].contains(receiverUid)) {
      await ref.update({
        'blockList': FieldValue.arrayRemove([receiverUid]),
      });
    } else {
      await ref.update({
        'blockList': FieldValue.arrayUnion([receiverUid]),
      });
    }
  }
}
