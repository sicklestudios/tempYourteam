import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/firestore_methods.dart';

class StorageMethods {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Future<String> uploadImageToStorage(Uint8List file) async {
    //if the fields are not empty than adding the images
    Reference ref = _firebaseStorage
        .ref()
        .child("profile")
        .child(firebaseAuth.currentUser!.uid);
    //uploadTask info
    UploadTask uploadTask = ref.putData(file);
    //Taking the snapshot to fetch url of the image
    TaskSnapshot taskSnapshot = await uploadTask.snapshot;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    log("upload success");
    return downloadUrl;
  }

  Future<String> storeFileToFirebase(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
  // Future<String> uploadRecordImage(String name, Uint8List file) async {
  //   //if the fields are not empty than adding the images
  //   Reference ref = _firebaseStorage
  //       .ref()
  //       .child("records")
  //       .child(firebaseAuth.currentUser!.uid)
  //       .child(name);
  //   //uploadTask info
  //   UploadTask uploadTask = ref.putData(file);
  //   //Taking the snapshot to fetch url of the image
  //   TaskSnapshot taskSnapshot = await uploadTask.snapshot;
  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   log("upload success");
  //   return downloadUrl;
  // }

  // Future<String> uploadRecordFile(String name, File file) async {
  //   //if the fields are not empty than adding the images
  //   Reference ref = _firebaseStorage
  //       .ref()
  //       .child("records")
  //       .child(firebaseAuth.currentUser!.uid)
  //       .child(name);
  //   //uploadTask info
  //   UploadTask uploadTask = ref.putFile(file);
  //   //Taking the snapshot to fetch url of the image
  //   TaskSnapshot taskSnapshot = await uploadTask.snapshot;
  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   log("upload success");
  //   return downloadUrl;
  // }

  // Future<void> uploadTempToStorage(String name) async {
  //   final ByteData bytes = await rootBundle.load('assets/medicalrecords.png');
  //   final Uint8List tempImage = bytes.buffer.asUint8List();
  //   await StorageMethods().uploadRecordImage(
  //     name,
  //     tempImage,
  //   );
  // }

  Future<void> deleteImageFromStorage(String photoUrl) async {
    {
      Reference photoRef = await FirebaseStorage.instance.refFromURL(photoUrl);
      await photoRef.delete();
      FirestoreMethods().addPhotoToFirestore(url: staticPhotoUrl);
      showToastMessage("Profile Removed");
    }
  }
}
