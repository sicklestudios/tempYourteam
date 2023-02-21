import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/utils/SharedPreferencesUser.dart';

ReceivePort? _receivePort;

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    String caller = await SharedPrefrenceUser.getCallerName();
    FlutterForegroundTask.updateService(
      notificationTitle: 'Ongoing call',
      notificationText: caller,
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

// void initalizeNotification() {
//   final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
//   awesomeNotifications.initialize(
//       // set the icon to null if you want to use the default app icon
//       null,
//       [
//         NotificationChannel(
//             channelKey: 'message',
//             channelName: 'message_notification',
//             channelDescription: 'A channel for message notifications',
//             defaultColor: mainColorFaded,
//             importance: NotificationImportance.Default),
//         // NotificationChannel(
//         //     channelKey: 'my_foreground',
//         //     channelName: 'MY FOREGROUND SERVICE',
//         //     channelDescription:
//         //         'This channel is used for important notifications.',
//         //     defaultColor: mainColor,
//         //     importance: NotificationImportance.Min)
//       ],
//       debug: false);
// }

// void showMessageNotification(String message) async {
//   await AwesomeNotifications().dismissAllNotifications();
//   AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: Random().nextInt(1000),
//       channelKey: "message",
//       title: appName,
//       body: message,
//     ),
//   );
// }

void initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'notification_channel_id',
      channelName: 'Foreground Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.MIN,
      priority: NotificationPriority.MIN,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
      // buttons: [
      //   const NotificationButton(id: 'sendButton', text: 'Send'),
      //   const NotificationButton(id: 'testButton', text: 'Test'),
      // ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      isOnceEvent: true,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

Future<bool> startForegroundTask() async {
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // onNotificationPressed function to be called.
  //
  // When the notification is pressed while permission is denied,
  // the onNotificationPressed function is not called and the app opens.
  //
  // If you do not use the onNotificationPressed or launchApp function,
  // you do not need to write this code.
  if (!await FlutterForegroundTask.canDrawOverlays) {
    final isGranted =
        await FlutterForegroundTask.openSystemAlertWindowSettings();
    if (!isGranted) {
      print('SYSTEM_ALERT_WINDOW permission denied!');
      return false;
    }
  }

  // You can save data using the saveData function.
  await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

  bool reqResult;
  if (await FlutterForegroundTask.isRunningService) {
    reqResult = await FlutterForegroundTask.restartService();
  } else {
    reqResult = await FlutterForegroundTask.startService(
      notificationTitle: 'Ongoing Call',
      notificationText: 'Tap to return to the app',
      callback: startCallback,
    );
  }

  ReceivePort? receivePort;
  if (reqResult) {
    receivePort = await FlutterForegroundTask.receivePort;
  }

  return _registerReceivePort(receivePort);
}

bool _registerReceivePort(ReceivePort? receivePort) {
  _closeReceivePort();

  if (receivePort != null) {
    _receivePort = receivePort;
    _receivePort?.listen((message) {
      if (message is int) {
        print('eventCount: $message');
      } else if (message is String) {
        if (message == 'onNotificationPressed') {
          Navigator.of(CURRENT_CONTEXT).pushNamed('/resume-route');
        }
      } else if (message is DateTime) {
        print('timestamp: ${message.toString()}');
      }
    });

    return true;
  }

  return false;
}

void _closeReceivePort() {
  _receivePort?.close();
  _receivePort = null;
}

Future<bool> stopForegroundTask() async {
  return await FlutterForegroundTask.stopService();
}

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: onStart,

//       // auto start service
//       autoStart: false,
//       isForegroundMode: true,
//       // notificationChannelId: 'my_foreground',
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       autoStart: true,
//       // this will be executed when app is in foreground in separated isolate
//       onForeground: onStart,
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );

//   service.startService();
// }

// // to ensure this is executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.reload();
//   final log = preferences.getStringList('log') ?? <String>[];
//   log.add(DateTime.now().toIso8601String());
//   await preferences.setStringList('log', log);

//   return true;
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();

//   // For flutter prior to version 3.0.0
//   // We have to register the plugin manually

//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.setString("hello", "world");

//   // /// OPTIONAL when use custom notification
//   // final AwesomeNotification flutterLocalNotificationsPlugin =
//   //     FlutterLocalNotificationsPlugin();

//   final AwesomeNotifications awesomeNotifications = AwesomeNotifications();

//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });

//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });

//   // bring to foreground
//   Timer.periodic(const Duration(seconds: 1), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         /// OPTIONAL for use custom notification
//         /// the notification id must be equals with AndroidConfiguration when you call configure() method.
//         awesomeNotifications.createNotification(
//             content: NotificationContent(
//                 id: 888,
//                 channelKey: "my_foreground",
//                 // title: "Your Team ${DateTime.now()}",
//                 title: "Haris Khan ${DateTime.now()}",
//                 body: "Ongoing Voice Call ",
//                 largeIcon: "asset://assets/user.png",
//                 // icon: "asset://assets/image.png",
//                 roundedLargeIcon: true,
//                 // criticalAlert: true,
//                 category: NotificationCategory.Call,
//                 notificationLayout: NotificationLayout.Default));

// //         // 888,
// //         // 'COOL SERVICE',
// //         // 'Awesome ${DateTime.now()}',
// //         // const NotificationDetails(
// //         //   android: AndroidNotificationDetails(
// //         //       'my_foreground', 'MY FOREGROUND SERVICE',
// //         //       icon: 'ic_bg_service_small',
// //         //       category: "call",
// //         //       ongoing: true,
// //         //       visibility: NotificationVisibility.public),
// //         // ),

// //         // if you don't using custom notification, uncomment this
// //         // service.setForegroundNotificationInfo(
// //         //   title: "My App Service",
// //         //   content: "Updated at ${DateTime.now()}",
// //         // );
//       }
//     }

// //     /// you can see this log in logcat
// //     print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

//     // test using external plugin
//     final deviceInfo = DeviceInfoPlugin();
//     String? device;
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfo.androidInfo;
//       device = androidInfo.model;
//     }

//     if (Platform.isIOS) {
//       final iosInfo = await deviceInfo.iosInfo;
//       device = iosInfo.model;
//     }

//     service.invoke(
//       'update',
//       {
//         "current_date": DateTime.now().toIso8601String(),
//         "device": device,
//       },
//     );
//   });
// }
// // void calculateCallTime(){
// //      if (totalsecondscall == 60) {
// //           totalminutecall = totalminutecall + 1;
// //           totalsecondscall = 0;
// //         }

// //         if (totalminutecall == 60) {
// //           totalhourscall = totalhourscall + 1;
// //           totalsecondscall = 0;
// //           totalminutecall = 0;
// //         }
// //         else
// //           totalsecondscall = totalsecondscall + 1;

// //         totalcalltime = "${totalhourscall < 10
// //             ? "0$totalhourscall"
// //             : totalhourscall}:${totalminutecall < 10
// //             ? "0$totalminutecall"
// //             : totalminutecall}:${totalsecondscall < 10
// //             ? "0$totalsecondscall"
// //             : totalsecondscall}";
// // }
