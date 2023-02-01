import 'dart:developer';

import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/notification_model.dart';
import 'package:yourteam/models/user_model.dart';

class FirestoreMethods {
  setNotificationHistory(String receiver, String senderId,
      String notificationTitle, String notificationSubtitle) async {
    NotificationModel model = NotificationModel(
        notificationTitle: notificationTitle,
        datePublished: DateTime.now(),
        uid: senderId,
        notificationSubtitle: notificationSubtitle);
    await firebaseFirestore
        .collection('users')
        .doc(receiver)
        .collection('notifications')
        .doc()
        .set(model.toJson());
  }

  Future<List<NotificationModel>> getNotificationsList() {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('notifications')
        .orderBy('datePublished', descending: true)
        .get()
        .then((event) async {
      List<NotificationModel> contacts = [];
      for (var document in event.docs) {
        try {
          var chatContact = NotificationModel.fromSnap(document);
          contacts.add(chatContact);
        } catch (e) {
          log(e.toString());
        }
      }
      return contacts;
    });
  }

  void setUserStateCall(bool isInCall) async {
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({
      'isInCall': isInCall,
    });
  }

  // //adding an appointment
  // Future<String> addAppoinment(AppointmentModel model) async {
  //   String res = "Some error occurred";
  //   try {
  //     //if the fields are not empty than registering the user
  //     await firebaseFirestore
  //         .collection("appointment")
  //         .doc()
  //         .set(model.toJson());
  //     res = "Success";
  //   } on FirebaseAuthException catch (err) {
  //     res = err.message.toString();
  //   }
  //   return res;
  // }

  // //adding a record
  // Future<String> addRecord(String name, RecordsModel model) async {
  //   String res = "Some error occurred";
  //   try {
  //     //if the fields are not empty than registering the user
  //     await firebaseFirestore
  //         .collection("users")
  //         .doc(firebaseAuth.currentUser!.uid)
  //         .collection("records")
  //         .doc(name)
  //         .set(model.toJson());
  //     res = "Success";
  //   } on FirebaseAuthException catch (err) {
  //     res = err.message.toString();
  //   }
  //   return res;
  // }

  // //getting records of user
  // Future getRecords() async {
  //   try {
  //     //if the fields are not empty than registering the user
  //     return await firebaseFirestore
  //         .collection("users")
  //         .doc(firebaseAuth.currentUser!.uid)
  //         // .doc("NzmMDTyLPBXm6WMG03TQTwPBsub2")
  //         .collection("records")
  //         .get();
  //   } on FirebaseAuthException catch (err) {
  //     return err;
  //   }
  // }

  // //getting records of user
  // Future<String> deleteRecord(String recordId) async {
  //   String res = "Some error occurred";

  //   try {
  //     //if the fields are not empty than registering the user
  //     await firebaseFirestore
  //         .collection("users")
  //         .doc(firebaseAuth.currentUser!.uid)
  //         // .doc("NzmMDTyLPBXm6WMG03TQTwPBsub2")
  //         .collection("records")
  //         .doc(recordId)
  //         .delete()
  //         .then((value) => res = "Success");
  //   } on FirebaseAuthException catch (err) {
  //     return err.message.toString();
  //   }
  //   return res;
  // }

  // Future<String> getRecordNumber() async {
  //   int num = 0;
  //   await firebaseFirestore
  //       .collection("users")
  //       .doc(firebaseAuth.currentUser!.uid)
  //       .collection("records")
  //       .get()
  //       .then((value) {
  //     value.docs.forEach((element) {
  //       int temp = int.parse(element.id);
  //       if (num < temp) {
  //         num = temp;
  //       }
  //     });
  //     num++;
  //   });
  //   return num.toString();
  // }

//adding the image url to firestore
  Future<String> addPhotoToFirestore({
    required String url,
  }) async {
    String res = "Some error occurred";
    try {
      //if the fields are not empty than registering the user
      if (url.isNotEmpty) {
        firebaseFirestore
            .collection("users")
            .doc(firebaseAuth.currentUser?.uid)
            .update({
          'photoUrl': url,
        });
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //adding the image url to firestore
  Future<String> updateProfile({
    required String name,
    required String contact,
    required String bio,
    required String loc,
  }) async {
    String res = "Some error occurred";
    try {
      //if the fields are not empty than registering the user
      {
        firebaseFirestore
            .collection("users")
            .doc(firebaseAuth.currentUser?.uid)
            .update({
          'name': name,
          'contact': contact,
          'bio': bio,
          'location': loc,
        });
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //searching the user in the database
  Future<String> searchUser({
    required String text,
  }) async {
    String res = "Some error occurred";
    // try {
    //   //if the fields are not empty than registering the user
    //   if (email.isNotEmpty && password.isNotEmpty) {
    //     UserCredential credential = await _firebaseAuth
    //         .createUserWithEmailAndPassword(email: email, password: password);
    //     UserModel user = UserModel(
    //       uid: credential.user!.uid,
    //       username: username.trim(),
    //       email: email.trim(),
    //       photoUrl: "",
    //       bio: "",
    //       contact: "",
    //       location: "",
    //       isOnline: false,
    //       blockList: [],
    //       contacts: [],
    //     );
    //     await _fireStore
    //         .collection("users")
    //         .doc(credential.user!.uid)
    //         .set(user.toJson());
    //     res = "Success";
    //   }
    // } on FirebaseAuthException catch (err) {
    //   res = err.message.toString();
    // }
    return res;
  }

  //get online status
  Future<UserModel> getUserInformationOther(String receiverId) async {
    return await firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .get()
        .then((event) {
      return UserModel.getValuesFromSnap(event);
    });
  }
}
