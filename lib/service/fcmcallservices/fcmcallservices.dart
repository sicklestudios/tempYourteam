import 'dart:convert';
import 'dart:developer';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/call_constants_global.dart';
import 'package:yourteam/call_ongoing_notification.dart';
import 'package:yourteam/methods/get_call_token.dart';
import 'package:yourteam/navigation_service.dart';
import 'package:yourteam/screens/call/call_notification_sent.dart';
import 'package:yourteam/screens/call/calls_ui/screens/dialScreen/dial_screen.dart';
import 'package:yourteam/screens/call/incoming_calls.dart';
import 'package:yourteam/service/local_push_notification.dart';
import 'package:yourteam/utils/SharedPreferencesUser.dart';
import '../../constants/constants.dart';
import '../../firebase_options.dart';
import '../../screens/call/call_rtc.dart';

class FcmCallServices {
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling a background message');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //await fcmcallservices.initnotifiy();
    // var notification = message.data;
    // var data = await jsonDecode(notification['content']);
    // if (data['body'] != "oye its a message" &&
    //     data['body'] != "oye its a task") {
    //   log('SHowing notification from fcmCall');
    await FcmCallServices.showFlutterNotification(message);
    // }
  }

  // static Future<void> setupFlutterNotifications() async {

  //   AwesomeNotifications().initialize(
  //       null,
  //       [
  //         NotificationChannel(
  //           channelGroupKey: 'video_channel',
  //           channelKey: 'video_channel',
  //           channelName: 'video_channel',
  //           channelDescription: 'This channel is for video call notificaion.',
  //           // channelShowBadge: true,
  //           importance: NotificationImportance.High,
  //           locked: true,
  //           defaultRingtoneType: DefaultRingtoneType.Ringtone,
  //           enableVibration: true,
  //           enableLights: true,
  //           onlyAlertOnce: false,
  //           playSound: true,
  //           // soundSource: 'resource://raw/res_morph_power_rangers',
  //         ),
  //         NotificationChannel(
  //           channelGroupKey: 'call_channel',
  //           channelKey: 'call_channel',
  //           channelName: 'call_channel',
  //           channelDescription: 'This is for audio call',
  //           // channelShowBadge: true,
  //           importance: NotificationImportance.High,
  //           locked: true,
  //           defaultRingtoneType: DefaultRingtoneType.Ringtone,
  //           enableLights: true,
  //           onlyAlertOnce: false,
  //           enableVibration: true,
  //           playSound: true,
  //           // soundSource: 'resource://raw/res_morph_power_rangers',
  //         ),
  //         NotificationChannel(
  //           channelGroupKey: 'miss_video_channel',
  //           channelKey: 'miss_video_channel',
  //           channelName: 'miss_video_channel',
  //           channelDescription: 'This is for miss call video notification',
  //           //channelShowBadge: true,
  //           defaultRingtoneType: DefaultRingtoneType.Notification,
  //           enableLights: true,
  //           //   importance: NotificationImportance.High,
  //           // soundSource: 'resource://raw/res_morph_power_rangers',
  //         ),
  //         NotificationChannel(
  //           channelGroupKey: 'miss_call_channel',
  //           channelKey: 'miss_call_channel',
  //           channelName: 'miss_call_channel',
  //           channelDescription: 'This is for miss call voice notification',
  //           //channelShowBadge: true,
  //           enableLights: true,
  //           defaultRingtoneType: DefaultRingtoneType.Notification,
  //           //  importance: NotificationImportance.High,
  //           // soundSource: 'resource://raw/res_morph_power_rangers',
  //         ),
  //       ],
  //       channelGroups: [
  //         NotificationChannelGroup(
  //           channelGroupKey: 'video_channel',
  //           channelGroupName: 'video_channel',
  //         ),
  //         NotificationChannelGroup(
  //           channelGroupKey: 'call_channel',
  //           channelGroupName: 'call_channel',
  //         ),
  //         NotificationChannelGroup(
  //           channelGroupKey: 'miss_video_channel',
  //           channelGroupName: 'miss_video_channel',
  //         ),
  //         NotificationChannelGroup(
  //           channelGroupKey: 'miss_call_channel',
  //           channelGroupName: 'miss_call_channel',
  //         ),
  //       ],
  //       debug: true);
  // }

  static void dataAction(notification, bool isInitial) async {
    var data = await jsonDecode(notification['content']);
    // log(data['body']);
    if (data['body'] == "oye its a message" ||
        data['body'] == "oye its a task") {
      // LocalNotificationService.display(message);
    } else if (data['body']['call_accepted'] == true && !isInitial) {
      appValueNotifier.setCallAccepted();
    } else if (data['body']['call_accepted'] == false && !isInitial) {
      appValueNotifier.setCallDeclined();
    } else {
      await FcmCallServices.onSelectNotification(notification);
    }
  }

  static Future<void> showFlutterNotification(RemoteMessage message) async {
    var notification = message.data;
    if (message.notification != null) {
      // await SharedPrefrenceUserlogin.isbackgrounornot(true);

      //checking if the message was for chat or calls notification
      // log(data['body']['call_accepted']);
      if (message != null) {
        var data = await jsonDecode(notification['content']);
        log(data['body'].toString());
        if (data['body'] == "oye its a message" ||
            data['body'] == "oye its a task") {
          log('SHowing notification from fcm 133');
          LocalNotificationService.display(
            message,
          );
        } else {
          dataAction(notification, false);
        }
      }
    }
  }

  static Future<void> forgroundnotify() async {
    //await FlutterRingtonePlayer.stop();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('Got a message whilst in the foreground!');
      if (message.notification != null) {
        var notification = message.data;

        if (message != null) {
          var data = await jsonDecode(notification['content']);
          // log(data['body']);
          if (data['body'] == "oye its a message" ||
              data['body'] == "oye its a task") {
            log(data['body']);
          } else {
            log("Not going");
            dataAction(notification, false);
          }

          // var data = await jsonDecode(notification['content']);

          // if (data['body'] == "oye its a message") {
          //   //Dont do anything in the foreground
          // } else if (data['body'] == "oye its a task") {
          //   // LocalNotificationService.display(message);
          // } else if (data['body']['call_accepted'] == true) {
          //   appValueNotifier.setCallAccepted();
          // } else if (data['body']['call_accepted'] == false) {
          //   appValueNotifier.setCallDeclined();
          // } else {
          //   await FcmCallServices.onSelectNotification(notification);
          // }
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        var notification = message.data;
        if (message != null) {
          dataAction(notification, false);
        }
      }
      //  flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      var notification = message?.data;
      if (message != null) {
        dataAction(notification, true);
      }
      //  flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
    });
  }

  static onSelectNotification(payload) async {
    // await AwesomeNotifications()
    //     .cancelNotificationsByChannelKey('video_channel');
    // await AwesomeNotifications()
    //     .cancelNotificationsByChannelKey('call_channel');
    //await FlutterRingtonePlayer.stop();

    // var data = await jsonDecode(payload['content']);
    // LocalNotificationService.display(
    //     payload,
    //   );
    // if (data['channelKey'] == 'miss_video_channel' ||
    //     data['channelKey'] == 'miss_call_channel' &&
    //         firebaseAuth.currentUser != null) {
    //   // await ClearAllNotifications.clear();
    //   await SharedPrefrenceUser.setCallData('');

    //   AwesomeNotifications().createNotification(
    //       content: NotificationContent(
    //     id: 2,
    //     body: (data['channelKey'] == 'miss_video_channel')
    //         ? 'Video miss call !'
    //         : 'Voice miss call !',
    //     title: data['uname'],
    //     channelKey: data['channelKey'],
    //     groupKey: data['channelKey'],
    //     autoDismissible: true,
    //     fullScreenIntent: true,
    //   ));
    //   // await ClearAllNotifications.clear();
    // } else if (data['channelKey'] == 'video_channel' ||
    //     data['channelKey'] == 'call_channel') {
//
// await FlutterRingtonePlayer.playRingtone();

    await SharedPrefrenceUser.setCallData(payload['content']);
    var calldata = await jsonDecode(payload['content']);
    (calldata['body']['call_type'] == 'call_channel')
        ? VIDEO_OR_AUDIO_FLG = true
        : VIDEO_OR_AUDIO_FLG = false;
    TOKEN = calldata['body']['token']['token'];
    CHANNEL_NAME = calldata['body']['token']['channelname'];
    CALLERDATA = calldata['body']['user_info'];
    log(TOKEN + "This is token");
    // if(ISOPEN)
//Navigator.push(CURRENT_CONTEXT, MaterialPageRoute(builder: (context)=>call_rtc()));
    // await Future.delayed(Duration(milliseconds: 100), () {
    //   Navigator.push(
    //       CURRENT_CONTEXT, MaterialPageRoute(builder: (context) => call_rtc()));
    // });

    //getting the data from
    showIncomingCall();
    // AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //       id: 1,
    //       body: (data['channelKey'] == 'video_channel')
    //           ? 'Video call !'
    //           : 'Voice call !',
    //       title: data['uname'],
    //       channelKey: data['channelKey'],
    //       groupKey: data['channelKey'],
    //       category: NotificationCategory.Call,
    //       wakeUpScreen: true,
    //       fullScreenIntent: true,
    //       autoDismissible: false,
    //     ),
    //     actionButtons: [
    //       NotificationActionButton(
    //           key: 'ACCEPT',
    //           label: 'Accept Call',
    //           enabled: true,
    //           color: Colors.green,
    //           autoDismissible: true),
    //       NotificationActionButton(
    //           key: 'REJECT',
    //           label: 'Reject',
    //           enabled: true,
    //           isDangerousOption: true,
    //           autoDismissible: true),
    //     ]);

// Get.to(()=>callscreen());
    // }
  }

//   static Future<void> getcallerdata(event) async {
//     var calldata;
//     var tempdata = await SharedPrefrenceUser.getCallData();

//     // if (tempdata != '') {
//     //   calldata = await jsonDecode(tempdata);

//     //   try {
//     //     (calldata['body']['call_type'] == 'call_channel')
//     //         ? VIDEO_OR_AUDIO_FLG = true
//     //         : VIDEO_OR_AUDIO_FLG = false;
//     //     //if (calldata != null) {
//     //     print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
//     //     log(tempdata.toString());
//     //     print("***********************************************");
//     //     TOKEN = calldata['body']['token']['token'];
//     //     CHANNEL_NAME = calldata['body']['token']['channelname'];
//     //     var doc = FirebaseFirestore.instance
//     //         .collection('users')
//     //         .doc(calldata['body']['uid']);

//     //     // await doc.update({"pickcall": true});

//     //     var data = await doc.get();
//     //     CALLERDATA = data.data() as Map<dynamic, dynamic>;
//     NavigationService.instance
//         .pushNamedIfNotCurrent(AppRoute.callingPage, args: event.body);
//     // Navigator.push(CURRENT_CONTEXT,
//     //     MaterialPageRoute(builder: (context) => const DialScreen()));
//     // await FirebaseFirestore.instance
//     //     .collection('users')
//     //     .doc(firebaseAuth.currentUser?.uid)
//     //     .update({"pickcall": true});
//     // //CALLERDATA =calldata['body'];
//     // await SharedPrefrenceUser.setCallData('');
//     // if(ISOPEN)
// //Navigator.push(CURRENT_CONTEXT, MaterialPageRoute(builder: (context)=>call_rtc()));
//     // await Future.delayed(const Duration(milliseconds: 100), () {});

//     // }
//     // print("***********************************************");
//     // log(calldata['body'].toString());
//     // print("***********************************************");

//     // else
//     //   GetMaterialApp(
//     //       debugShowCheckedModeBanner: false,
//     //       theme: ThemeData(
//     //         primarySwatch: mainMaterialColor,
//     //         textSelectionTheme: const TextSelectionThemeData(
//     //           // cursorColor: Colors.red,
//     //           // selectionColor: Colors.black,
//     //           selectionHandleColor: Colors.black,
//     //         ),
//     //       ),
//     //       home:call_rtc())
//     //   } catch (e) {
//     //     // print("***********************************************");
//     //     // print(e);
//     //     // print("***********************************************");
//     //   } finally {}
//     // }
//   }

  static Future<void> respondToCall(bool value) async {
    try {
      var tempdata = await SharedPrefrenceUser.getCallData();

      var calldata = await jsonDecode(tempdata);

      var msg = {
        'call_accepted': value,
      };

      sendCallResponse(
          token: calldata['body']['user_info']["token"],
          msg: msg,
          btnstatus:
              VIDEO_OR_AUDIO_FLG == false ? "video_channel" : "call_channel");
    } catch (e) {
    } finally {}
  }

  static notificationstream() {
    // AwesomeNotifications()
    //     .setListeners(onActionReceivedMethod: notificationactionlistener);
  }

  // static Future<void> notificationactionlistener(ReceivedAction event) async {
  //   //   print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
  //   // print(event.body);
  //   //   print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
  //   //await FlutterRingtonePlayer.stop();
  //   //AwesomeNotifications().actionStream.listen((event) async {
  //   //  if(event.channelKey=='call_channel'){

  //   // if(event.buttonKeyPressed=='REJECT')
  //   //
  //   //     await rejectcall();
  //   //
  //   //
  //   //
  //   //          if(event.buttonKeyPressed=='ACCEPT')
  //   //            await getcallerdata();

  //   // }
  //   //else if(event.channelKey=='video_channel'){
  //   // print("***************************************");
  //   // print(event.channelKey);
  //   // print("***************************************");
  //   if (event.buttonKeyPressed == 'REJECT') {
  //     await rejectcall();
  //   }

  //   if (event.buttonKeyPressed == 'ACCEPT') {
  //     await getcallerdata();
  //   }

  //   /// }

  //   // else if(receivedNotification.channelKey=='video_channel'){
  //   //   print("vido channel");
  //   // }
  //   // });
  //   // AwesomeNotifications().actionStream.listen(
  //   //         (ReceivedNotification receivedNotification){
  //   //
  //   //       if(receivedNotification.channelKey=='call_channel'){
  //   //         print("voice channel"+receivedNotification.id.toString());
  //   //         print(receivedNotification.body);
  //   //
  //   //          if(receivedNotification.id==1)
  //   //          Get.to(()=>CallPage());
  //   //       }
  //   //
  //   //       else if(receivedNotification.channelKey=='video_channel'){
  //   //         print("vido channel");
  //   //       }
  //   //
  //   //
  //   //     },
  //   // );
  // }
}

class AppRoute {
  static const callingPage = '/calling_page';

  static Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case callingPage:
        return MaterialPageRoute(
            builder: (_) => const DialScreen(), settings: settings);
      default:
        return null;
    }
  }
}
