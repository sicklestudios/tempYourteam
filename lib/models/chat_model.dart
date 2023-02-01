import 'package:yourteam/constants/message_enum.dart';

class ChatContactModel {
  final String contactId;
  final String name;
  final String photoUrl;
  final DateTime timeSent;
  final String lastMessage;
  final String lastMessageBy;
  final String lastMessageId;
  final bool isSeen;

  ChatContactModel({
    required this.contactId,
    required this.name,
    required this.photoUrl,
    required this.timeSent,
    required this.lastMessage,
    required this.lastMessageBy,
    required this.lastMessageId,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'contactId': contactId,
      'senderName': name,
      'photoUrl': photoUrl,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'lastMessageBy': lastMessageBy,
      'lastMessageId': lastMessageId,
      'isSeen': isSeen,
    };
  }

  factory ChatContactModel.fromMap(Map<String, dynamic> map) {
    return ChatContactModel(
      contactId: map['contactId'],
      name: map['senderName'],
      photoUrl: map['photoUrl'],
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage: map['lastMessage'],
      lastMessageBy: map['lastMessageBy'],
      lastMessageId: map['lastMessageId'],
      isSeen: map['isSeen'],
    );
  }
}

// List<ChatContactModel> chatList = [
//   ChatContactModel(
//     contactId: "0",
//     name: "M. Haris Amer",
//     photoUrl:
//         "https://images.unsplash.com/photo-1605993439219-9d09d2020fa5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//     timeSent: DateTime.now(),
//     lastMessage: "Heyy",
//     isSeen: true,
//   ),
//   ChatContactModel(
//     contactId: "0",
//     name: "M. Haris Amer",
//     photoUrl:
//         "https://images.unsplash.com/photo-1605993439219-9d09d2020fa5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//     timeSent: DateTime.now(),
//     lastMessage: "Heyy",
//     isSeen: false,
//   ),
//   ChatContactModel(
//     contactId: "0",
//     name: "M. Haris Amer",
//     photoUrl:
//         "https://images.unsplash.com/photo-1605993439219-9d09d2020fa5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//     timeSent: DateTime.now(),
//     lastMessage: "Heyy",
//     isSeen: false,
//   ),
// ];

class Message {
  final String senderId;
  final String recieverid;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  Message({
    required this.senderId,
    required this.recieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recieverid': recieverid,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      recieverid: map['recieverid'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? false,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }
}
