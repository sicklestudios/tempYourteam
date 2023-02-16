import 'package:dio/dio.dart';

import '../../constants/constants.dart';

Future<void> send_fcm_call({title, token, msg, name, btnstatus}) async {
  final data = {
    "to": token ?? "",
    "notification": {
      "body": (btnstatus == 'call_channel') ? "Voice Call !" : "Video Call !",
      "content_available": true,
      "priority": "high",
      "Title": "required",
      "channelKey": btnstatus
    },
    "data": {
      "content": {
        "id": 1,
        "channelKey": btnstatus,
        "channelName": btnstatus,
        "channelGroupKey": btnstatus,
        "title": title,
        "body": msg,
        "autoDismissible": false,
        "privacy": "Private",
        "fullScreenIntent": true,
        "wakeUpScreen": true,
        "uname": name
      },
      "actionButtons": [
        {"key": "ACCEPT", "label": "Accept Call", "autoDismissible": true},
        {
          "key": "REJECT",
          "label": "Reject",
          "autoDismissible": true,
          "isDangerousOption": true
        }
      ]
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': fcmServerKey
  };

  BaseOptions options = new BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 5000,
    headers: headers,
  );

  try {
    final response = await Dio(options).post(fcmPost, data: data);

    if (response.statusCode == 200) {
      print('successflly!');
    } else {
      print('notification sending failed');
// on failure do sth
    }
  } catch (e) {
    print('exception $e');
  }
}

Future<void> send_fcm_misscall({title, token, msg, name, btnstatus}) async {
  // var postUrl = "https://fcm.googleapis.com/fcm/send";
  final data = {
    "to": token ?? "",
    "notification": {
      "body": (btnstatus == 'miss_call_channel')
          ? "Voice miss Call !"
          : "Video miss Call !",
      "content_available": true,
      "priority": "high",
      "Title": "required",
      "channelKey": btnstatus
    },
    "data": {
      "content": {
        "id": 2,
        "channelKey": btnstatus,
        "channelName": btnstatus,
        "channelGroupKey": btnstatus,
        "title": title,
        "body": msg,
        "autoDismissible": true,
        "privacy": "Private",
        "uname": name
      },
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': fcmServerKey
  };

  BaseOptions options = BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 5000,
    headers: headers,
  );

  try {
    final response = await Dio(options).post(fcmPost, data: data);

    if (response.statusCode == 200) {
      print('successflly!');
    } else {
      print('notification sending failed');
// on failure do sth
    }
  } catch (e) {
    print('exception $e');
  }
}

Future<void> send_sms_notification({title, token, msg, name, btnstatus}) async {
  // var postUrl = "https://fcm.googleapis.com/fcm/send";
  final data = {
    "to": token ?? "",
    "notification": {
      "body": "Message",
      "content_available": true,
      "priority": "high",
      "Title": "required",
      "channelKey": "msg_channel"
    },
    "data": {
      "content": {
        "id": 1,
        "channelKey": "msg_channel",
        "channelName": "msg_channel",
        "channelGroupKey": "msg_channel",
        "title": title,
        "body": msg,
        "autoDismissible": true,
        "privacy": "Private",
        "uname": name
      },
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': fcmServerKey
  };

  BaseOptions options = new BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 5000,
    headers: headers,
  );

  try {
    final response = await Dio(options).post(fcmPost, data: data);

    if (response.statusCode == 200) {
      print('successflly!');
    } else {
      print('notification sending failed');
// on failure do sth
    }
  } catch (e) {
    print('exception $e');
  }
}

//sending the respone of call

Future<void> sendCallResponse({token, msg, btnstatus}) async {
  final data = {
    "to": token ?? "",
    "notification": {
      "body": (btnstatus == 'call_channel') ? "Voice Call !" : "Video Call !",
      "content_available": true,
      "priority": "high",
      "Title": "required",
      "channelKey": btnstatus
    },
    "data": {
      "content": {
        "id": 1,
        "channelKey": btnstatus,
        "channelName": btnstatus,
        "channelGroupKey": btnstatus,
        "body": msg,
        "autoDismissible": false,
        "privacy": "Private",
        "fullScreenIntent": true,
        "wakeUpScreen": true,
      },
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': fcmServerKey
  };

  BaseOptions options = BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 5000,
    headers: headers,
  );

  try {
    final response = await Dio(options).post(fcmPost, data: data);

    if (response.statusCode == 200) {
      print('successflly!');
    } else {
      print('notification sending failed');
// on failure do sth
    }
  } catch (e) {
    print('exception $e');
  }
}
