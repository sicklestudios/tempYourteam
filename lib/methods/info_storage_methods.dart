import 'dart:developer';

import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/file_link_docs_model.dart';

class InfoStorage {
  storeLink(DateTime dateTime, String url, String receiverId) async {
    await firebaseFirestore
        .collection("users")
        .doc(receiverId)
        .collection('links')
        .doc()
        .set(LinkModel(fileUrl: url, timeSent: dateTime).toMap());
  }

  Future<List<LinkModel>> getLink() async {
    List<LinkModel> contactUsers = [];

    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('links')
        .orderBy('timeSent', descending: true)
        .get()
        .then((event) {
      for (var document in event.docs) {
        var userInfo = LinkModel.fromMap(document.data());
        contactUsers.add(userInfo);
      }
      return contactUsers;
    });
  }

  storeMedia(
      DateTime dateTime, String url, String receiverId, String senderId) async {
    await firebaseFirestore
        .collection("users")
        .doc(receiverId)
        .collection('media')
        .doc()
        .set(MediaModel(senderId: senderId, photoUrl: url, timeSent: dateTime)
            .toMap());
  }

  Future<List<MediaModel>> getMedia(String? id) async {
    List<MediaModel> contactUsers = [];
    if (id != null && id != firebaseAuth.currentUser!.uid) {
      await firebaseFirestore
          .collection('users')
          .doc(id)
          .collection('media')
          .where("senderId", isEqualTo: firebaseAuth.currentUser!.uid)
          .get()
          .then((event) {
        for (var document in event.docs) {
          log("inOther");
          var userInfo = MediaModel.fromMap(document.data());
          contactUsers.add(userInfo);
        }
        // return contactUsers;
      });
      return firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          // .doc("LTKgBuRItJT2cIHuFx77yu0Zsqo2")
          .collection('media')
          .where("senderId", isEqualTo: id)
          .get()
          .then((event) {
        for (var document in event.docs) {
          var userInfo = MediaModel.fromMap(document.data());
          contactUsers.add(userInfo);
        }
        return contactUsers;
      });
    } else {
      return firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          // .doc("LTKgBuRItJT2cIHuFx77yu0Zsqo2")
          .collection('media')
          .where("senderId", isEqualTo: id)
          .get()
          .then((event) {
        for (var document in event.docs) {
          var userInfo = MediaModel.fromMap(document.data());
          contactUsers.add(userInfo);
        }
        return contactUsers;
      });
    }
  }

  storeFile(DateTime dateTime, String url, String name, String receiverId,
      String senderId) async {
    await firebaseFirestore
        .collection("users")
        .doc(receiverId)
        .collection('docs')
        .doc()
        .set(DocsModel(
                senderId: senderId,
                fileName: name,
                fileUrl: url,
                timeSent: dateTime)
            .toMap());
  }

  Future<List<DocsModel>> getFile() async {
    List<DocsModel> contactUsers = [];
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('docs')
        .get()
        .then((event) {
      for (var document in event.docs) {
        var userInfo = DocsModel.fromMap(document.data());
        contactUsers.add(userInfo);
      }
      return contactUsers;
    });
  }
}
