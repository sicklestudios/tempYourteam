// import 'package:agora_uikit/agora_uikit.dart';
// import 'package:flutter/material.dart';

// import 'package:yourteam/config/config.dart';

// class CallScreen extends StatefulWidget {
//   const CallScreen({super.key});

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   AgoraClient? client;
//   String baseUrl = 'https://agoratokenyourteam-production.up.railway.app';

//   @override
//   void initState() {
//     super.initState();
//     client = AgoraClient(
//       agoraConnectionData: AgoraConnectionData(
//         appId: AgoraConfig.appId,
//         channelName: "haris",
//         tokenUrl: baseUrl,
//         // tempToken: AgoraConfig.token
//       ),
//     );
//     initAgora();
//   }

//   void initAgora() async {
//     await client!.initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: client == null
//           ? const CircularProgressIndicator()
//           : SafeArea(
//               child: Stack(
//                 children: [
//                   AgoraVideoViewer(client: client!),
//                   AgoraVideoButtons(
//                     client: client!,
//                     disconnectButtonChild: IconButton(
//                       onPressed: () async {
//                         await client!.engine.leaveChannel();
//                         Navigator.pop(context);
//                       },
//                       icon: const Icon(Icons.call_end),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:yourteam/config/config.dart';
// import 'package:yourteam/models/chat_model.dart';

// class CallScreen extends StatefulWidget {
//   final bool isAudioCall;
//   final ChatContactModel model;
//   const CallScreen({required this.model, required this.isAudioCall, super.key});

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   String baseUrl = 'https://agoratokenyourteam-production.up.railway.app';

//   int uid = 0; // uid of the local user

//   int? _remoteUid; // uid of the remote user
//   bool _isJoined = false; // Indicates if the local user has joined the channel
//   late RtcEngine agoraEngine; // Agora engine instance

//   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

//   showMessage(String message) {
//     scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
//       content: Text(message),
//     ));
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Set up an instance of Agora engine
//     setupVoiceSDKEngine();
//   }

// // Build UI
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('Get started with Video Calling'),
//           ),
//           body: ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             children: [
//               // Container for the local video
//               Container(
//                 height: 240,
//                 decoration: BoxDecoration(border: Border.all()),
//                 child: Center(child: _localPreview()),
//               ),
//               const SizedBox(height: 10),
//               //Container for the Remote video
//               Container(
//                 height: 240,
//                 decoration: BoxDecoration(border: Border.all()),
//                 child: Center(child: _remoteVideo()),
//               ),
//               // Button Row
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _isJoined ? null : () => {join()},
//                       child: const Text("Join"),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _isJoined ? () => {leave()} : null,
//                       child: const Text("Leave"),
//                     ),
//                   ),
//                 ],
//               ),
//               // Button Row ends
//             ],
//           )),
//     );
//   }

// // Display local video preview
//   Widget _localPreview() {
//     if (_isJoined) {
//       return AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: agoraEngine,
//           canvas: VideoCanvas(uid: uid),
//         ),
//       );
//     } else {
//       return const Text(
//         'Join a channel',
//         textAlign: TextAlign.center,
//       );
//     }
//   }

// // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: agoraEngine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: "zk"),
//         ),
//       );
//     } else {
//       String msg = '';
//       if (_isJoined) msg = 'Waiting for a remote user to join';
//       return Text(
//         msg,
//         textAlign: TextAlign.center,
//       );
//     }
//   }

//   void join() async {
//     await agoraEngine.startPreview();

//     // Set channel options including the client role and channel profile
//     ChannelMediaOptions options = const ChannelMediaOptions(
//       clientRoleType: ClientRoleType.clientRoleBroadcaster,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     );

//     await agoraEngine.joinChannel(
//       token: AgoraConfig.token,
//       channelId: 'zk',
//       options: options,
//       uid: uid,
//     );
//   }

//   void leave() {
//     setState(() {
//       _isJoined = false;
//       _remoteUid = null;
//     });
//     agoraEngine.leaveChannel();
//   }

//   Widget _status() {
//     String statusText;

//     if (!_isJoined) {
//       statusText = 'Join a channel';
//     } else if (_remoteUid == null) {
//       statusText = 'Waiting for a remote user to join...';
//     } else {
//       statusText = 'Connected to remote user, uid:$_remoteUid';
//     }

//     return Text(
//       statusText,
//     );
//   }

//   Future<void> setupVoiceSDKEngine() async {
//     // retrieve or request microphone permission
//     await [Permission.microphone].request();

//     //create an instance of the Agora engine
//     agoraEngine = createAgoraRtcEngine();
//     await agoraEngine.initialize(RtcEngineContext(appId: AgoraConfig.appId));
//     await agoraEngine.enableVideo();
//     // Register the event handler
//     agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           showMessage(
//               "Local user uid:${connection.localUid} joined the channel");
//           setState(() {
//             _isJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           showMessage("Remote user uid:$remoteUid joined the channel");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           showMessage("Remote user uid:$remoteUid left the channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//       ),
//     );
//   }
// }

