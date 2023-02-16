import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yourteam/call_constants_global.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/get_call_token.dart';
import 'package:yourteam/screens/call/calls_ui/constants.dart';
import 'package:yourteam/screens/call/calls_ui/size_config.dart';
import 'package:yourteam/utils/SharedPreferencesUser.dart';

import 'components/body.dart';

class DialScreen extends StatelessWidget {
  const DialScreen({super.key});
  void getAndSet() async {
    bool value = await SharedPrefrenceUser.getIsIncoming();
    appValueNotifier.isCallAccepted.value = value;
    if (value) {
      var tempdata = await SharedPrefrenceUser.getCallData();

      var calldata = await jsonDecode(tempdata);
      (calldata['body']['call_type'] == 'call_channel')
          ? VIDEO_OR_AUDIO_FLG = true
          : VIDEO_OR_AUDIO_FLG = false;
      TOKEN = calldata['body']['token']['token'];
      CHANNEL_NAME = calldata['body']['token']['channelname'];
      CALLERDATA = calldata['body']['user_info'];
      SharedPrefrenceUser.setCallerName(CALLERDATA['name']);
      log("Caller  name  " + CALLERDATA['name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    getAndSet();

    SizeConfig().init(context);
    return const Scaffold(
      backgroundColor: kBackgoundColor,
      body: Body(),
    );
  }
}
