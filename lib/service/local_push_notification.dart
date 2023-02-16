import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
// import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yourteam/constants/constants.dart';

// class LocalNotificationService {
//   static math.Random random = math.Random();
//   static int notificationId = 0;
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   //initalizing the notifications
//   static void initialize() {
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//             iOS: IOSInitializationSettings(
//               requestSoundPermission: true,
//               requestBadgePermission: true,
//               requestAlertPermission: true,
//             ));

//     _flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: onSelectNotification);
//   }

//   static onSelectNotification(String? payload) async {
//     //Navigate to wherever you want
//   }
//   requestIOSPermissions() {
//     _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//   }

//   //for showing the notification
//   static Future<void> display(RemoteMessage message) async {
//     try {
//       // if()
//       // notificationId=random.nextInt(1000);
//       await _flutterLocalNotificationsPlugin.cancelAll();

//       const NotificationDetails notificationDetails = NotificationDetails(
//           android: AndroidNotificationDetails(
//             "mychanel",
//             "my chanel",
//             // visibility: NotificationVisibility.public,
//             importance: Importance.max,
//             // groupKey: "group",
//             // styleInformation: ,
//             // setAsGroupSummary: true,
//             priority: Priority.max,
//           ),
//           iOS: IOSNotificationDetails(
//             threadIdentifier: "thread1",
//           ));
//       // print("my id is ${id.toString()}");
//       await _flutterLocalNotificationsPlugin.show(
//         notificationId,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//       );
//     } on Exception catch (e) {
//       log(e.toString());
//     }
//   }

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
// }

sendNotification(String id, String token, String message) async {
  final data = {
    "content": {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': id,
      'status': 'done',
      "body": "oye its a message",
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
