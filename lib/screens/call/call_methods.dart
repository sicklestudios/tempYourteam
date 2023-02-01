import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/call_model.dart';

class CallMethods {
  Future<List<CallModel>> getCallsList() {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('calls')
        .orderBy(
          'timeSent',
        )
        .get()
        .then((event) {
      List<CallModel> messages = [];
      for (var document in event.docs) {
        messages.add(CallModel.fromMap(document.data()));
      }
      return messages;
    });
  }

  void storeCallInfo(String reciverId, String reciverName,
      String reciverPhotoUrl, bool isAudioCall) async {
    CallModel callModelReceiver = CallModel(
        receiverId: userInfo.uid,
        receiverName: userInfo.username,
        receiverPic: userInfo.photoUrl,
        isIncoming: true,
        timeSent: DateTime.now(),
        isAudioCall: isAudioCall);

//storing the call info in the database for both users

    await firebaseFirestore
        .collection('users')
        .doc(reciverId)
        .collection('calls')
        .doc()
        .set(callModelReceiver.toMap());

    CallModel callModelSender = CallModel(
        receiverId: reciverId,
        receiverName: reciverName,
        receiverPic: reciverPhotoUrl,
        isIncoming: false,
        timeSent: DateTime.now(),
        isAudioCall: isAudioCall);

    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('calls')
        .doc()
        .set(callModelSender.toMap());
  }

  // void makeCall(
  //   BuildContext context,
  //   String receiverName,
  //   String receiverUid,
  //   String receiverProfilePic,
  // ) {
  //   String callId = const Uuid().v1();
  // CallModel senderCallData = CallModel(
  //     callerId: firebaseAuth.currentUser!.uid,
  //     callerName: userInfo!.username,
  //     callerPic: userInfo.photoUrl,
  //     receiverId: receiverUid,
  //     receiverName: receiverName,
  //     receiverPic: receiverProfilePic,
  //     callId: callId,
  //     isIncoming: true,
  //     timeSent: DateTime.now(),
  //     isAudioCall: true);

  //   CallModel recieverCallData = CallModel(
  //       callerId: firebaseAuth.currentUser!.uid,
  //       callerName: userInfo!.username,
  //       callerPic: userInfo.photoUrl,
  //       receiverId: receiverUid,
  //       receiverName: receiverName,
  //       receiverPic: receiverProfilePic,
  //       callId: callId,
  //       isIncoming: false,
  //       isAudioCall: true,
  //       timeSent: DateTime.now());
  //   _makeCall(senderCallData, context, recieverCallData);
  // }

  // void endCall(
  //   String callerId,
  //   String receiverId,
  //   BuildContext context,
  // ) async {
  //   try {
  //     await firebaseFirestore.collection('call').doc(callerId).delete();
  //     await firebaseFirestore.collection('call').doc(receiverId).delete();
  //   } catch (e) {
  //     // showSnackBar(context: context, content: e.toString());
  //   }
  // }

  // void _makeCall(
  //   CallModel senderCallData,
  //   BuildContext context,
  //   CallModel receiverCallData,
  // ) async {
  //   try {
  //     await firebaseFirestore
  //         .collection('call')
  //         .doc(senderCallData.callerId)
  //         .set(senderCallData.toMap());
  //     await firebaseFirestore
  //         .collection('call')
  //         .doc(senderCallData.receiverId)
  //         .set(receiverCallData.toMap());

  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => CallScreen(
  //     //       channelId: senderCallData.callId,
  //     //       call: senderCallData,
  //     //       isGroupChat: false,
  //     //     ),
  //     //   ),
  //     // );
  //   } catch (e) {
  //     // showSnackBar(context: context, content: e.toString());
  //   }
  // }

}
//