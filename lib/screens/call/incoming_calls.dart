import 'dart:async';
import 'dart:developer';

import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'package:yourteam/call_constants_global.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/navigation_service.dart';
import 'package:yourteam/service/fcmcallservices/fcmcallservices.dart';
import 'package:yourteam/utils/SharedPreferencesUser.dart';

void showIncomingCall() async {
  CallKitParams callKitParams = CallKitParams(
    id: const Uuid().v4(),
    nameCaller: CALLERDATA != null
        ? CALLERDATA['name'] ?? "Nothing to show"
        : "Nothing to show",
    appName: 'Your Team',
    avatar: CALLERDATA != null
        ? (CALLERDATA['photoUrl'] == null)
            ? "Nothing to show"
            : CALLERDATA['photoUrl']
        : "Nothing to show",
    handle: '',
    type: VIDEO_OR_AUDIO_FLG == false ? 1 : 0,
    textAccept: 'Accept',
    textDecline: 'Decline',
    textMissedCall: 'Missed call',
    textCallback: 'Call back',
    duration: 30000,
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
        isCustomNotification: true,
        isCustomSmallExNotification: true,
        isShowLogo: true,
        isShowCallback: false,
        isShowMissedCallNotification: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#091C40',
        // backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call"),
    ios: IOSParams(
      // iconName: 'Your Team',
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);

  listenerEvent();
}

Future<void> listenerEvent() async {
  try {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      print('HOME: $event');
      switch (event!.event) {
        case Event.ACTION_CALL_INCOMING:
          // TODO: received an incoming call
          break;
        case Event.ACTION_CALL_START:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.ACTION_CALL_ACCEPT:
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
          // FcmCallServices.getcallerdata(event);
          SharedPrefrenceUser.setIsIncoming(true);

          FcmCallServices.respondToCall(true);
          // NavigationService.instance
          //     .pushNamedIfNotCurrent(AppRoute.callingPage, args: event.body);
          log("Incoming call");
          break;
        case Event.ACTION_CALL_DECLINE:

          // TODO: declined an incoming call
          SharedPrefrenceUser.setIsIncoming(false);

          FcmCallServices.respondToCall(false);
          break;
        case Event.ACTION_CALL_ENDED:
          // TODO: ended an incoming/outgoing call
          SharedPrefrenceUser.setIsIncoming(false);

          FcmCallServices.respondToCall(false);
          break;
        case Event.ACTION_CALL_TIMEOUT:
          // TODO: missed an incoming call
          break;
        // case Event.ACTION_CALL_CALLBACK:
        //   // TODO: only Android - click action `Call back` from missed call notification
        //   break;
        // case Event.ACTION_CALL_TOGGLE_HOLD:
        //   // TODO: only iOS
        //   break;
        // case Event.ACTION_CALL_TOGGLE_MUTE:
        //   // TODO: only iOS
        //   break;
        // case Event.ACTION_CALL_TOGGLE_DMTF:
        //   // TODO: only iOS
        //   break;
        // case Event.ACTION_CALL_TOGGLE_GROUP:
        //   // TODO: only iOS
        //   break;
        // case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
        //   // TODO: only iOS
        //   break;
        // case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
        //   // TODO: only iOS
        //   break;
      }
      // if (callback != null) {
      //   callback(event.toString());
      // }
    });
  } on Exception {}
}
