import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
// import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yourteam/constants/constants.dart';

class LocalNotificationService {
  static math.Random random = math.Random();
  static int notificationId = 0;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //initalizing the notifications
  static void initialize() {
    requestIOSPermissions();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"),
            iOS: IOSInitializationSettings(
              requestSoundPermission: true,
              requestBadgePermission: false,
              requestAlertPermission: true,
            ));

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  static onSelectNotification(String? payload) async {
    //Navigate to wherever you want
  }
  static requestIOSPermissions() {
    if (Platform.isIOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  //for showing the notification
  static Future<void> display(RemoteMessage message) async {
    log("Showing notifcation");
    try {
      // if()
      // notificationId=random.nextInt(1000);
      await _flutterLocalNotificationsPlugin.cancelAll();

      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "mychanel",
            "my chanel",
            // visibility: NotificationVisibility.public,
            importance: Importance.min,
            // groupKey: "group",
            // styleInformation: ,
            // setAsGroupSummary: true,
            priority: Priority.min,
          ),
          iOS: IOSNotificationDetails(
            threadIdentifier: "thread1",
          ));
      // print("my id is ${id.toString()}");
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

// Future<void> scheduleNotifications({id, title, body, time}) async {
//   try {
//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(time, tz.local),
//         const NotificationDetails(
//             android: AndroidNotificationDetails(
//                 'your channel id', 'your channel name',
//                 channelDescription: 'your channel description')),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime);
//   } catch (e) {
//     log(e.toString());
//   }
// }
}

sendNotification(String id, String token, String message) async {
  String myMessage = "oye its a message";
  if (message.endsWith("task")) {
    myMessage = "oye its a task";
  }
  final data = {
    "content": {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': id,
      'status': 'done',
      "body": myMessage,
      'message': message,
    }
  };

  try {
    http.Response response =
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAkDRUyUw:APA91bFM2OXKHfmMzKtdvqjnhwRSB75JWJXkvjV4N8qYsyCdbaneR2T8e2GtPTvo3xZxD53dEm0IgrsvmOD83njL-9m6FGXhh1117akvIZNxGsKxEVmim1UZ_ge_-M5zrl6yg9Xb1JLo'
            },
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{
                'title': appName,
                'body': message
              },
              // "data": {
              //   "content": {
              //     "id": 1,
              //     "body": "oye its a message",
              //   },

              // },
              'priority': 'high',
              'data': data,
              'to': token
            }));

    if (response.statusCode == 200) {
      print("Yeh notificatin is sended");
    } else {
      print("Error");
    }
  } catch (e) {}
}
