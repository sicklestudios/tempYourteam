class CallModel {
  final String receiverId;
  final String receiverName;
  final String receiverPic;
  final DateTime timeSent;
  final bool isIncoming;
  final bool isAudioCall;

  CallModel({
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.timeSent,
    required this.isIncoming,
    required this.isAudioCall,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhotoUrl': receiverPic,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'isIncoming': isIncoming,
      'isAudioCall': isAudioCall,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      receiverId: map['receiverId'],
      receiverName: map['receiverName'],
      receiverPic: map['receiverPhotoUrl'],
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      isIncoming: map['isIncoming'],
      isAudioCall: map['isAudioCall'],
    );
  }
}

// List<CallModel> callList = [
//   CallModel(
//       receiverId: "0",
//       receiverName: "M. Haris Amer",
//       receiverPhotoUrl:
//           "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//       timeSent: DateTime.now(),
//       isIncoming: true,
//       onlineStatus: true,
//       isAudioCall: true),
//   CallModel(
//       receiverId: "0",
//       receiverName: "M. Haris Amer",
//       receiverPhotoUrl:
//           "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//       timeSent: DateTime.now(),
//       isIncoming: true,
//       onlineStatus: true,
//       isAudioCall: false),
//   CallModel(
//       receiverId: "0",
//       receiverName: "M. Haris Amer",
//       receiverPhotoUrl:
//           "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//       timeSent: DateTime.now(),
//       isIncoming: true,
//       onlineStatus: false,
//       isAudioCall: true),
//   CallModel(
//       receiverId: "0",
//       receiverName: "M. Haris Amer",
//       receiverPhotoUrl:
//           "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
//       timeSent: DateTime.now(),
//       isIncoming: false,
//       onlineStatus: true,
//       isAudioCall: false),
// ];
