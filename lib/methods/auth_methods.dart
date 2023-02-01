import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/user_model.dart';

class AuthMethods {
  final FirebaseAuth _firebaseAuth = firebaseAuth;
  final FirebaseFirestore _fireStore = firebaseFirestore;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount() async {
    //deleting the user information from the database than delete
    await _fireStore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .delete();
    await _firebaseAuth.currentUser!.delete();
  }

  //GetUserInfo
  Future<UserModel> getUserInfo() async {
    User currentUser = _firebaseAuth.currentUser!;
    DocumentSnapshot documentSnapshot =
        await _fireStore.collection('users').doc(currentUser.uid).get();
    return UserModel.getValuesFromSnap(documentSnapshot);
  }

  // //signingIn with google
  // Future<String> signInWithGoogle() async {
  //   String res = "Some error occurred";
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
  //     UserCredential userCredential =
  //         await _firebaseAuth.signInWithCredential(credential);
  //     User? user = userCredential.user;
  //     if (user != null) {
  //       if (userCredential.additionalUserInfo!.isNewUser) {
  //         UserModel userModel = UserModel(
  //           uid: user.uid,
  //           name: user.displayName!,
  //           email: user.email!,
  //           photoUrl: "",
  //           dob: "",
  //           contact: "",
  //           location: "",
  //           favourites: [],
  //         );
  //         _fireStore.collection('users').doc(user.uid).set(userModel.toJson());
  //       }
  //       res = "Success";
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     log('google signin error occured');
  //     res = e.message.toString();
  //   }
  //   return res;
  // }

  // //signingIn with google
  // Future<String> signInWithFacebook() async {
  //   String res = "Some error occurred";
  //   try {
  //     final facebookLoginResult = await FacebookAuth.instance.login();

  //     log(facebookLoginResult.message.toString());
  //     final userData = await FacebookAuth.instance.getUserData();

  //     final credential = FacebookAuthProvider.credential(
  //         facebookLoginResult.accessToken!.token);
  //     UserCredential userCredential =
  //         await _firebaseAuth.signInWithCredential(credential);

  //     User? user = userCredential.user;
  //     if (user != null) {
  //       if (userCredential.additionalUserInfo!.isNewUser) {
  //         UserModel userModel = UserModel(
  //           uid: user.uid,
  //           name: user.displayName!,
  //           email: user.email!,
  //           photoUrl: userData['picture']['data']['url'],
  //           dob: "",
  //           contact: "",
  //           location: "",
  //           favourites: [],
  //         );
  //         _fireStore.collection('users').doc(user.uid).set(userModel.toJson());
  //       }
  //       res = "Success";
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     log('google signin error occured');
  //     res = e.message.toString();
  //   }
  //   return res;
  // }

  //SignupUser
  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      //if the fields are not empty than registering the user
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        UserModel user = UserModel(
          uid: credential.user!.uid,
          username: username.trim(),
          email: email.trim(),
          photoUrl: staticPhotoUrl,
          bio: "",
          contact: "",
          contactEmail: "",
          location: "",
          isOnline: false,
          isInCall: false,
          token: '',
          blockList: [],
          contacts: [],
        );
        await _fireStore
            .collection("users")
            .doc(credential.user!.uid)
            .set(user.toJson());
        res = "Success";
      }
    } on FirebaseAuthException catch (err) {
      res = err.message.toString();
    }
    return res;
  }

  // _getUserEmail(username) {
  //   String email = "";
  //   _fireStore
  //       .collection('users')
  //       .where('username', isEqualTo: username)
  //       .get()
  //       .then((value) {
  //     email= UserModel.getValuesFromSnap(value.docs[0]).email;
  //   });
  // }

  //loginUser
  Future<String> loginUser(
      {required String email,
      required String password,
      required BuildContext context}) async {
    String res = "Some error occurred";
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      res = "Success";
    } on FirebaseAuthException catch (err) {
      res = err.message.toString();
    }
    return res;
  }

  Future<String> resetPassword({required String email}) async {
    String result = "";
    await firebaseAuth
        .sendPasswordResetEmail(email: email)
        .then((value) => result = "sent")
        .catchError((e) => result = e.toString());
    return result;
  }

  // Future<String> changePassword({required String pass}) async {
  //   String result = "";
  //   await firebaseAuth.currentUser!
  //       .updatePassword(pass)
  //       .then((value) => result = "done")
  //       .catchError((e) => result = e.toString());
  //   return result;
  // }

  void setUserState(bool isOnline) async {
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({
      'isOnline': isOnline,
    });
  }
}
