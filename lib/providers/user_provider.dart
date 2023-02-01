import 'package:flutter/cupertino.dart';
import 'package:yourteam/methods/auth_methods.dart';
import 'package:yourteam/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? uid;
  final AuthMethods _authMethods = AuthMethods();
  UserModel get getUser => uid!;

  set user(UserModel value) {
    uid = value;
  }

  Future<void> refreshUser() async {
    UserModel user = (await _authMethods.getUserInfo());
    uid = user;
    notifyListeners();
  }
}
