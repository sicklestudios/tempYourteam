// import 'dart:async';
// import 'dart:math';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:yourteam/screens/call/call_notification_sent.dart';
// import '../../constants/constants.dart';

// class call_rtc extends StatefulWidget {
//   const call_rtc({super.key});

//   @override
//   _call_rtcState createState() => _call_rtcState();
// }

// class _call_rtcState extends State<call_rtc> {
//   final _users = <int>[];
//   final _infoStrings = <String>[];

//   late RtcEngine engine;
//   bool muted = false;
//   bool speaker = false;
//   bool isinit = false;
//   // bool initornot=false;
//   String totalcalltime = '00:00:00';
//   int totalminutecall = 0;
//   int totalsecondscall = 0;
//   int totalhourscall = 0;
//   Timer? timer;
//   Timer? timer2;
//   Timer? timer3;
//   int firsttime = 1;
//   var starttime = DateTime.now();
//   var endtime = DateTime.now();

//   var user;
//   @override
//   void dispose() {
//     timer?.cancel();
//     timer2?.cancel();
//     timer3?.cancel();

//     _users.clear();
//     _dispose();
//     super.dispose();
//   }

//   Future<void> _handleCameraAndMic(Permission permission) async {
//     var granted = await permission.isGranted;
//     if (!granted) await permission.request();
//   }

//   Future<void> _dispose() async {
//     // destroy sdk
//     // await engine.leaveChannel();
//     // await engine.destroy();
//   }

//   @override
//   void initState() {
//     // print(TOKEN+" "+CHANNEL_NAME);
//     super.initState();
//     initialize();
//   }

//   Future<void> initialize() async {
// //    await Workmanager().registerPeriodicTask("call_task", "call_task", frequency: Duration(minutes: 15));
// // if(mounted)
// //   setState(() {
// //
// //   });
//     // _addAgoraEventHandlers();
//     await _handleCameraAndMic(Permission.camera);
//     await _handleCameraAndMic(Permission.microphone);
//     await agorainit();
//   }

//   Future<void> agorainit() async {
//     // await gettoken();
//     //  await _handleCameraAndMic(Permission.camera);
//     //  await _handleCameraAndMic(Permission.microphone);
//     if (appId.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }

//     isinit = true;
//     setState(() {});

//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     configuration.dimensions = const VideoDimensions(width: 1920, height: 1080);
//     await engine.setVideoEncoderConfiguration(configuration);

//     await engine.leaveChannel();
//     await engine.joinChannel(TOKEN, CHANNEL_NAME, null, 0);

//     //var usertype=await SharedPrefrenceUser.getUserType();
//     // if(usertype=='user') {
//     //   await firsttimecheckcoins();
//     //   await checkcoins();
//     // }
//     await calltimecalculate();
//     //await delleavecallstatus();
//   }

//   Future<void> _initAgoraRtcEngine() async {
//     // engine = await RtcEngine.create(appId);
//     // if (VIDEO_OR_AUDIO_FLG == false)
//     await engine.enableVideo();
//     await engine.setEnableSpeakerphone(speaker);
//     await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await engine.setClientRole(role);
//   }

//   void _addAgoraEventHandlers() {
//     engine.setEventHandler(RtcEngineEventHandler(
//       error: (code) {
//         setState(() {
//           final info = 'onError: $code';
//           _infoStrings.add(info);
//         });
//       },
//       joinChannelSuccess: (channel, uid, elapsed) {
//         setState(() {
//           final info = 'onJoinChannel: $channel, uid: $uid';
//           starttime = DateTime.now();
//           _infoStrings.add(info);
//         });
//       },
//       leaveChannel: (stats) {
//         setState(() {
//           _infoStrings.add('onLeaveChannel');
//           _users.clear();
//         });

//         // _onCallEnd(context);
//       },
//       userJoined: (uid, elapsed) {
//         setState(() {
//           //  print("jfjfjdfijfffffffffffffffffff");
//           final info = 'userJoined: $uid';
//           _infoStrings.add(info);
//           _users.add(uid);
//         });
//         if (mounted) setState(() {});
//       },
//       userOffline: (uid, elapsed) {
//         setState(() {
//           final info = 'userOffline: $uid';
//           _infoStrings.add(info);
//           _onCallEnd(context);

//           _users.remove(uid);
//         });
//       },
//       firstRemoteVideoFrame: (uid, width, height, elapsed) {
//         setState(() {
//           final info = 'firstRemoteVideo: $uid ${width}x $height';
//           _infoStrings.add(info);
//         });
//       },
//       rtcStats: (stats) {
//         //updates every two seconds
//         log(stats.duration);
//       },
//     ));
//   }

//   List<Widget> _getRenderViews() {
//     final List<StatefulWidget> list = [];
//     if (role == ClientRole.Broadcaster) {
//       list.add(const RtcLocalView.SurfaceView());
//     }
//     _users.forEach((int uid) =>
//         list.add(RtcRemoteView.SurfaceView(channelId: CHANNEL_NAME, uid: uid)));
//     return list;
//   }

//   Widget _videoView(view) {
//     return Expanded(child: Container(child: view));
//   }

//   Widget _expandedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Expanded(
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }

//   Widget _viewRows() {
//     final views = _getRenderViews();
//     switch (views.length) {
//       case 1:
//         return Column(
//           children: <Widget>[_videoView(views[0])],
//         );
//       case 2:
//         return Column(
//           children: <Widget>[
//             _expandedVideoRow([views[0]]),
//             _expandedVideoRow([views[1]])
//           ],
//         );
//       case 3:
//         return Column(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 3))
//           ],
//         );
//       case 4:
//         return Column(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 4))
//           ],
//         );
//       default:
//     }
//     return Container();
//   }

//   Widget _toolbar() {
//     if (role == ClientRole.Audience) return Container();
//     return Container(
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           RawMaterialButton(
//             onPressed: () async {
//               speaker = speaker == true ? false : true;
//               setState(() {});
//               await engine.setEnableSpeakerphone(speaker);
//             },
//             shape: const CircleBorder(),
//             elevation: 2.0,
//             fillColor: speaker ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//             child: Icon(
//               Icons.speaker,
//               color: speaker ? Colors.white : Colors.blueAccent,
//               size: 20.0,
//             ),
//           ),
//           RawMaterialButton(
//             onPressed: () => _onCallEnd(context),
//             shape: const CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.redAccent,
//             padding: const EdgeInsets.all(15.0),
//             child: const Icon(
//               Icons.call_end,
//               color: Colors.white,
//               size: 35.0,
//             ),
//           ),
//           RawMaterialButton(
//             onPressed: _onToggleMute,
//             shape: const CircleBorder(),
//             elevation: 2.0,
//             fillColor: muted ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//             child: Icon(
//               muted ? Icons.mic_off : Icons.mic,
//               color: muted ? Colors.white : Colors.blueAccent,
//               size: 20.0,
//             ),
//           ),
//           if (!VIDEO_OR_AUDIO_FLG)
//             RawMaterialButton(
//               onPressed: _onSwitchCamera,
//               shape: const CircleBorder(),
//               elevation: 2.0,
//               fillColor: Colors.white,
//               padding: const EdgeInsets.all(12.0),
//               child: const Icon(
//                 Icons.switch_camera,
//                 color: Colors.blueAccent,
//                 size: 20.0,
//               ),
//             )
//         ],
//       ),
//     );
//   }

//   Future<void> _onCallEnd(BuildContext context) async {
//     Navigator.pop(context);
//     var msg = {
//       'call_type': VIDEO_OR_AUDIO_FLG == false
//           ? "miss_video_channel"
//           : "miss_call_channel",
//       'uid': userInfo.uid
//     };
//     // if (user != null && user['pickcall'] != null && user['pickcall'] == false)
//     await send_fcm_misscall(
//         token: CALLERDATA['token'],
//         name: userInfo == null ? "" : userInfo.username,
//         title: "Miss Call !",
//         msg: msg,
//         btnstatus: VIDEO_OR_AUDIO_FLG == false
//             ? "miss_video_channel"
//             : "miss_call_channel");

//     // await setcallhistore();
//     // await  setleavecallstatus();
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     engine.muteLocalAudioStream(false);
//   }

//   void _onSwitchCamera() {
//     engine.switchCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           (VIDEO_OR_AUDIO_FLG == false) ? Colors.black : Colors.white,
//       body: (isinit == false)
//           ? Container()
//           : Center(
//               child: Stack(
//                 children: <Widget>[
//                   if (VIDEO_OR_AUDIO_FLG == false) _viewRows(),
//                   Padding(
//                     padding: const EdgeInsets.all(30.0),
//                     child: Text(
//                       totalcalltime,
//                       style: TextStyle(
//                           color: (VIDEO_OR_AUDIO_FLG == false)
//                               ? Colors.white
//                               : Colors.black),
//                     ),
//                   ),
//                   if (VIDEO_OR_AUDIO_FLG == true)
//                     Positioned(
//                       top: MediaQuery.of(context).size.height / 3,
//                       left: MediaQuery.of(context).size.width / 2.9,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 65,
//                             backgroundColor: const Color(0xff27D59E),
//                             child: CircleAvatar(
//                                 radius: 62,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(100),
//                                   child: Image.network(
//                                     CALLERDATA != null
//                                         ? (CALLERDATA['photoUrl'] == null)
//                                             ? ""
//                                             : CALLERDATA['photoUrl']
//                                         : '',
//                                     fit: BoxFit.cover,
//                                     height: 200,
//                                     width: 200,
//                                     errorBuilder: (BuildContext context,
//                                         exception, stackTrace) {
//                                       return const Icon(Icons.person);
//                                     },
//                                     loadingBuilder: (BuildContext context,
//                                         child,
//                                         ImageChunkEvent? loadingProgress) {
//                                       if (loadingProgress == null) {
//                                         return child;
//                                       }
//                                       return Center(
//                                         child: CircularProgressIndicator(
//                                           value: loadingProgress
//                                                       .expectedTotalBytes !=
//                                                   null
//                                               ? loadingProgress
//                                                       .cumulativeBytesLoaded /
//                                                   int.parse(loadingProgress
//                                                       .expectedTotalBytes
//                                                       .toString())
//                                               : null,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 )),
//                           ),
//                           Text(CALLERDATA != null
//                               ? CALLERDATA['name'] ?? ""
//                               : ""),
//                         ],
//                       ),
//                     ),
//                   _toolbar(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Future<void> calltimecalculate() async {
//     timer2 = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
//       var doc = await firebaseFirestore
//           .collection('users')
//           .doc(firebaseAuth.currentUser?.uid)
//           .get();
//       user = doc;
//       if (user['rejectcall'] != null &&
//           user['rejectcall'] == true &&
//           doc['pickcall'] == false) {
//         await firebaseFirestore
//             .collection('users')
//             .doc(firebaseAuth.currentUser?.uid)
//             .update({'rejectcall': false});
//         _onCallEnd(context);
//       }
//       if (doc['pickcall'] != null && doc['pickcall']) {
//         if (totalsecondscall == 60) {
//           totalminutecall = totalminutecall + 1;
//           totalsecondscall = 0;
//         }

//         if (totalminutecall == 60) {
//           totalhourscall = totalhourscall + 1;
//           totalsecondscall = 0;
//           totalminutecall = 0;
//         } else {
//           totalsecondscall = totalsecondscall + 1;
//         }

//         totalcalltime =
//             "${totalhourscall < 10 ? "0$totalhourscall" : totalhourscall}:${totalminutecall < 10 ? "0$totalminutecall" : totalminutecall}:${totalsecondscall < 10 ? "0$totalsecondscall" : totalsecondscall}";
//         if (mounted) setState(() {});
//       }
//     });
//   }
// }
