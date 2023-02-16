import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

String baseUrl = "https://tired-necklace-colt.cyclic.app";

String? token;

Future<void> getToken(String channelId) async {
  final res = await http.get(
    Uri.parse(
        '$baseUrl/rtc/$channelId/publisher/userAccount/${firebaseAuth.currentUser!.uid}/'),
  );

  if (res.statusCode == 200) {
    token = res.body;
    token = jsonDecode(token!)['rtcToken'];
    TOKEN = token!;
    log("Got the token successfully");
  } else {
    log('Failed to fetch the token');
  }
}
