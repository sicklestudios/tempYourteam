import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationTitle;
  final String notificationSubtitle;
  final DateTime datePublished;
  final String uid;

  NotificationModel({
    required this.notificationTitle,
    required this.notificationSubtitle,
    required this.datePublished,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'notificationTitle': notificationTitle,
        'notificationSubtitle': notificationSubtitle,
        'datePublished': datePublished,
        'uid': uid,
      };

  factory NotificationModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationTitle: snapshot['notificationTitle'],
      notificationSubtitle: snapshot['notificationSubtitle'],
      datePublished: snapshot['datePublished'].toDate(),
      uid: snapshot['uid'],
    );
  }
}



// class NotificationModel {
//   final String receiverId;
//   final String receiverName;
//   final String receiverPhotoUrl;
//   final DateTime timeSent;
//   final bool isIncoming;
//   final bool onlineStatus;
//   final bool isAudioCall;

//   NotificationModel({
//     required this.receiverId,
//     required this.receiverName,
//     required this.receiverPhotoUrl,
//     required this.timeSent,
//     required this.isIncoming,
//     required this.onlineStatus,
//     required this.isAudioCall,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'receiverId': receiverId,
//       'receiverName': receiverName,
//       'receiverPhotoUrl': receiverPhotoUrl,
//       'timeSent': timeSent.millisecondsSinceEpoch,
//       'isIncoming': isIncoming,
//       'onlineStatus': onlineStatus,
//       'isAudioCall': isAudioCall,
//     };
//   }

//   factory NotificationModel.fromMap(Map<String, dynamic> map) {
//     return NotificationModel(
//       receiverId: map['receiverId'],
//       receiverName: map['receiverName'],
//       receiverPhotoUrl: map['receiverPhotoUrl'],
//       timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
//       isIncoming: map['isIncoming'],
//       onlineStatus: map['onlineStatus'],
//       isAudioCall: map['isAudioCall'],
//     );
//   }
// }