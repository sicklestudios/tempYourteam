import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceUser {
  //setCalling username
  static Future<bool> setCallerName(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("caller_name", userId);
  }

  //gettCalling username
  static Future<String> getCallerName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("caller_name") ?? '';
  }

  static Future<bool> setIsIncoming(bool status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("is_from_call", status);
  }

  static Future<bool> getIsIncoming() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_from_call") ?? false;
  }

  static Future<bool> setLoggedIn(bool status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("logged_in", status);
  }

  static Future<bool> getLogedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("logged_in") ?? false;
  }

  static Future<bool> setUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("user_id", userId);
  }

  static Future<bool> setUserType(type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("user_type", type);
  }

  static Future<bool> setCallData(type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("call_data", type);
  }

  static Future<String> getCallData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("call_data") ?? '';
  }

  static Future<bool> isbackgrounornot(type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("is_background", type);
  }

  static Future<bool> getisbackgrounornot() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_background") ?? false;
  }

  static Future<String> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_type") ?? '';
  }

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id") ?? '';
  }
}
