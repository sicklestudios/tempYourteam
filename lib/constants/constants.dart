import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yourteam/constants/colors.dart';

String appName = "Your Team";
var firebaseAuth = FirebaseAuth.instance;
var firebaseFirestore = FirebaseFirestore.instance;
var userInfo;
String staticPhotoUrl =
    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png";
// String agoraAppId = "b2f84a50565243f2a23a384c7fbb229c";
// String agoraAppCertificate = "478b46cf1f6948058dfa2222f76e77f7";
// String agoraTempToken =
//     "007eJxTYJC/M332L4nehdIb3W5vXH22ZM2HJsfVfpH3jdy5WXIyDigoMCQZpVmYJJoamJqZGpkYpxklGhknGluYJJunJSUZGVkmn3dbn9wQyMiwWICFmZEBAkF8VoaMxKLMYgYGAHZ0HzA=";
// String appSign =
//     "72a17f4f87bd732ec0f267a0cd6352e81f4349efd8c5b6d0602ffaf32cc598d0";
void showFloatingFlushBar(
    BuildContext context, String upMessage, String downMessage) {
  Flushbar(
    borderRadius: BorderRadius.circular(8),
    duration: const Duration(seconds: 1),
    backgroundGradient: const LinearGradient(
      colors: [mainColor, mainColorFaded],
      stops: [0.6, 1],
    ),
    boxShadows: const [
      BoxShadow(
        color: Colors.white,
        offset: Offset(3, 3),
        blurRadius: 3,
      ),
    ],
    titleColor: Colors.white,
    messageColor: Colors.white,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    title: upMessage,
    message: downMessage,
  ).show(context);
}

showToastMessage(String toastText) {
  Fluttertoast.showToast(
      msg: toastText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: mainColor,
      textColor: Colors.white,
      fontSize: 16.0);
}
