import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:yourteam/call_constants_global.dart';
import 'package:yourteam/call_ongoing_notification.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/get_call_token.dart';
import 'package:yourteam/screens/call/calls_ui/components/dial_user_pic.dart';
import 'package:yourteam/screens/call/calls_ui/components/rounded_button.dart';
import 'package:yourteam/screens/call/calls_ui/constants.dart';
import 'package:yourteam/screens/call/calls_ui/size_config.dart';
import 'package:yourteam/utils/SharedPreferencesUser.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  int currentUserUid = 0;
  bool isinit = false;
  bool _isJoined = false;
  int? _remoteUid;
  @override
  void initState() {
    super.initState();
    log("Token = " + TOKEN);
    // userId = random.nextInt(50);
    startForegroundTask();
    if (engine == null) {
      // playing the audio of dialing the call
      startAudio();
      initialize();
    } else {
      log("The agora engine is already initalized");
    }
  }

  void startAudio() async {
    if (!appValueNotifier.isCallAccepted.value &&
        !(await SharedPrefrenceUser.getIsIncoming())) {
      if (player.state != PlayerState.playing) {
        _playAudio();
        if (timer == null) {
          timer = Timer(const Duration(seconds: 32), () {
            //checking if the user is dialing a call
            if (appValueNotifier.globalisCallOnGoing.value &&
                !appValueNotifier.isCallAccepted.value) {
              appValueNotifier.setIsCallNotAnswered();
              SharedPrefrenceUser.setCallerName("");
            }
          });
        }
      }
      currentUserUid = 0;
    }
    // await getToken(CHANNEL_NAME);
    await SharedPrefrenceUser.setIsIncoming(false);
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    var granted = await permission.isGranted;
    if (!granted) {
      await permission.request();
    }
  }

  Future<void> initialize() async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    await agorainit();
  }

  Future<void> agorainit() async {
    if (agoraAppId.isEmpty) {
      setState(() {
        infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    isinit = true;
    setState(() {});

    await _initAgoraRtcEngine();
    // _addAgoraEventHandlers();
  }

  // Future<void> _initAgoraRtcEngine() async {
  //   engine = await RtcEngine.create(agoraAppId);
  // await engine!.enableVideo();
  // await engine!.enableAudio();
  // await engine!.setDefaultAudioRouteToSpeakerphone(
  //     callValueNotifiers.isSpeakerOn.value);
  //   await engine!.setChannelProfile(ChannelProfile.LiveBroadcasting);
  //   await engine!.setClientRole(ClientRole.Broadcaster);
  //   VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
  //   configuration.dimensions = const VideoDimensions(width: 1280, height: 720);
  //   await engine!.setVideoEncoderConfiguration(configuration);
  //   await engine!.joinChannel(
  //     TOKEN,
  //     CHANNEL_NAME,
  //     null,
  //     userId,
  //   );
  // }

  Future<void> _initAgoraRtcEngine() async {
    log("Initalizing agora");
    engine = createAgoraRtcEngine();
    await engine!.initialize(RtcEngineContext(appId: agoraAppId));
    VideoEncoderConfiguration configuration = const VideoEncoderConfiguration(
        orientationMode: OrientationMode.orientationModeFixedPortrait);
    await engine!.setVideoEncoderConfiguration(configuration);
    await engine!.enableVideo();
    await engine!.enableAudio();
    await engine!.setDefaultAudioRouteToSpeakerphone(
        callValueNotifiers.isSpeakerOn.value);
    try {
      // await engine!.setEnableSpeakerphone(callValueNotifiers.isSpeakerOn.value);
      await engine!.leaveChannel();
    } catch (e) {
      log(e.toString());
    }
    await getToken(CHANNEL_NAME);

    await engine!.joinChannelWithUserAccount(
        token: TOKEN,
        channelId: CHANNEL_NAME,
        userAccount: firebaseAuth.currentUser!.uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ));
    // await engine!.joinChannel(
    //     token: TOKEN,
    //     channelId: CHANNEL_NAME,
    //     uid: userId,
    //     options: const ChannelMediaOptions(
    //       clientRoleType: ClientRoleType.clientRoleBroadcaster,
    //       channelProfile: ChannelProfileType.channelProfileCommunication1v1,
    //     ));

    // Register the event handler
    engine!.registerEventHandler(
      RtcEngineEventHandler(
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          infoStrings.add('onLeaveChannel');
          users.clear();
        });
      }, onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (callValueNotifiers.isVideoOn.value) {
          engine!.enableVideo();
          callValueNotifiers.setSpeakerValue(true);
          // Wakelock.toggle(enable: false);
        }
        engine!.setEnableSpeakerphone(callValueNotifiers.isSpeakerOn.value);
        log("joinSuccess");
        setState(() {
          _isJoined = true;
        });
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        _remoteUid = remoteUid;
        appValueNotifier.isCallAccepted.value = true;
        setState(() {
          final info = 'userJoined: $remoteUid';
          infoStrings.add(info);
          users.add(remoteUid);
        });
        if (mounted) setState(() {});
      }, onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
        setState(() {
          final info = 'userOffline: $remoteUid';
          infoStrings.add(info);
          // _onCallEnd(context);
          users.remove(remoteUid);
          setState(() {
            FlutterCallkitIncoming.endAllCalls();
            appValueNotifier.globalisCallOnGoing.value = false;
          });
          try {
            timer!.cancel();
            timer = null;
            closeAgora();
          } catch (e) {}
          appValueNotifier.setToInitial();
          Navigator.pop(context);
        });
      }, onRtcStats: (RtcConnection connection, RtcStats stats) {
        //updates every two seconds
        {
          log(stats.duration.toString());
          if (mounted) setState(() {});
        }
      }, onTokenPrivilegeWillExpire: (connection, token) async {
        await getToken(CHANNEL_NAME);
        await engine!.renewToken(token);
      }),
    );
  }

  // void _addAgoraEventHandlers() {
  //   engine!.setEventHandler(RtcEngineEventHandler(error: (code) {
  //     setState(() {
  //       final info = 'onError: $code';
  //     });
  //   }, joinChannelSuccess: (channel, uid, elapsed) {
  //     setState(() {
  //       final info = 'onJoinChannel: $channel, uid: $uid';
  //       // starttime = DateTime.now();
  //     });
  //     log("join success");

  //     engine!.setEnableSpeakerphone(callValueNotifiers.isSpeakerOn.value);
  //   }, leaveChannel: (stats) {
  //     setState(() {
  //       users.clear();
  //     });
  //     // _onCallEnd(context);
  //   }, userJoined: (uid, elapsed) {
  //     _remoteUid = uid;
  //     setState(() {
  //       final info = 'userJoined: $uid';
  //       infoStrings.add(info);
  //       users.add(uid);
  //     });
  //     if (mounted) setState(() {});
  //   }, userOffline: (uid, elapsed) {
  //     setState(() {
  //       final info = 'userOffline: $uid';
  //       infoStrings.add(info);
  //       // _onCallEnd(context);
  //       users.remove(uid);
  //       setState(() {
  //         FlutterCallkitIncoming.endAllCalls();
  //         appValueNotifier.globalisCallOnGoing.value = false;
  //       });
  //       try {
  //         timer!.cancel();
  //         timer = null;
  //         closeAgora();
  //       } catch (e) {}
  //       appValueNotifier.setToInitial();
  //       Navigator.pop(context);
  //     });
  //   }, rtcStats: (stats) {
  //     //updates every two seconds
  //     {
  //       log(stats.duration.toString());
  //       setState(() {});
  //     }
  //   }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
  //     setState(() {
  //       final info = 'firstRemoteVideo: $uid ${width}x $height';
  //     });
  //   }));
  // }
  //  Future<void> _onCallEnd(BuildContext context) async {
  //   Navigator.pop(context);
  //   var msg=
  //   {'call_type':VIDEO_OR_AUDIO_FLG==false?"miss_video_channel":"miss_call_channel",'uid':userInfo.uid};
  //   if(user!=null&&user['pickcall']!=null&&user['pickcall']==false)
  //   await send_fcm_misscall(token: CALLERDATA['token'],name:userInfo==null?"":userInfo.username,title: "Miss Call !",msg:msg,btnstatus:VIDEO_OR_AUDIO_FLG==false?"miss_video_channel":"miss_call_channel" );

  //   // await setcallhistore();
  //  // await  setleavecallstatus();

  // }

  void _playAudio() async {
    AudioContext audioContext = const AudioContext(
      android: AudioContextAndroid(
          // audioMode: AndroidAudioMode.,
          isSpeakerphoneOn: false,
          usageType: AndroidUsageType.voiceCommunicationSignalling),
    );
    // await player.play(AssetSource('call_outgoing.mp3'));
    audioCache = AudioCache(prefix: 'assets/');
    player.setReleaseMode(ReleaseMode.loop);
    player.setAudioContext(audioContext);
    log(audioContext.android.isSpeakerphoneOn.toString());
    await player
        .play(BytesSource(await audioCache!.loadAsBytes("call_outgoing.mp3")));
    // player.setPlayerMode(PlayerMode.lowLatency);
    // player
  }

  @override
  void dispose() {
    super.dispose();
    if (!appValueNotifier.globalisCallOnGoing.value) {
      try {
        closeAgora();
      } catch (e) {}

      player.release();
      player.dispose();
    }
  }

  // List<Widget> _getRenderViews() {
  //   final List<StatefulWidget> list = [];
  //   if (role == ClientRole.Broadcaster) {
  //     list.add(const RtcLocalView.SurfaceView());
  //   }
  //   users.forEach((int uid) => list
  //       .add(RtcRemoteView.SurfaceView(channelId: CHANNEL_NAME, uid: userId)));
  //   return list;
  // }

  // Widget _videoView(view) {
  //   return Expanded(child: Container(child: view));
  // }

  // Widget _expandedVideoRow(List<Widget> views) {
  //   final wrappedViews = views.map<Widget>(_videoView).toList();
  //   return Expanded(
  //     child: Row(
  //       children: wrappedViews,
  //     ),
  //   );
  // }

  // Widget _viewRows() {
  //   final views = _getRenderViews();
  //   switch (views.length) {
  //     case 1:
  //       return Column(
  //         children: <Widget>[_videoView(views[0])],
  //       );
  //     case 2:
  //       return Column(
  //         children: <Widget>[
  //           _expandedVideoRow([views[0]]),
  //           _expandedVideoRow([views[1]])
  //         ],
  //       );
  //     case 3:
  //       return Column(
  //         children: <Widget>[
  //           _expandedVideoRow(views.sublist(0, 2)),
  //           _expandedVideoRow(views.sublist(2, 3))
  //         ],
  //       );
  //     case 4:
  //       return Column(
  //         children: <Widget>[
  //           _expandedVideoRow(views.sublist(0, 2)),
  //           _expandedVideoRow(views.sublist(2, 4))
  //         ],
  //       );
  //     default:
  //   }
  //   return Container();
  // }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Stack(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !callValueNotifiers.isVideoOn.value
                    ? Center(child: getAudioCall())
                    : getVideoCall(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    // alignment: WrapAlignment.spaceBetween,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: getProportionateScreenWidth(80),
                        child: ValueListenableBuilder(
                          valueListenable: callValueNotifiers.isSpeakerOn,
                          builder: (context, isSpeakerOn, child) {
                            return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSpeakerOn
                                      ? Colors.white
                                      : Colors.transparent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: getProportionateScreenWidth(20),
                                  ),
                                ),
                                onPressed: () async {
                                  callValueNotifiers.setSpeakerValue(
                                      !callValueNotifiers.isSpeakerOn.value);
                                  await engine!.setEnableSpeakerphone(
                                      callValueNotifiers.isSpeakerOn.value);
                                },
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  color:
                                      isSpeakerOn ? Colors.black : Colors.white,
                                ));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: getProportionateScreenWidth(80),
                          child: ValueListenableBuilder(
                            valueListenable: callValueNotifiers.isMicOff,
                            builder: (context, isMicOff, child) {
                              return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMicOff
                                        ? Colors.white
                                        : Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: getProportionateScreenWidth(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    callValueNotifiers.setMicValue(
                                        !callValueNotifiers.isMicOff.value);
                                    engine!.muteLocalAudioStream(
                                        callValueNotifiers.isMicOff.value);
                                  },
                                  child: Icon(
                                    isMicOff ? Icons.mic_off : Icons.mic,
                                    color:
                                        isMicOff ? Colors.black : Colors.white,
                                  ));
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: getProportionateScreenWidth(80),
                        child: ValueListenableBuilder(
                          valueListenable: callValueNotifiers.isVideoOn,
                          builder: (context, isVideoOn, child) {
                            return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isVideoOn
                                      ? Colors.white
                                      : Colors.transparent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: getProportionateScreenWidth(20),
                                  ),
                                ),
                                onPressed: () async {
                                  callValueNotifiers.setIsVideoOn(
                                      !callValueNotifiers.isVideoOn.value);
                                  if (isVideoOn == false) {
                                    await engine!.enableVideo();
                                  } else {
                                    await engine!.disableVideo();
                                  }
                                  // VIDEO_OR_AUDIO_FLG =
                                  //     !callValueNotifiers.isVideoOn.value;

                                  setState(() {});
                                },
                                child: Icon(
                                  isVideoOn
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                  color:
                                      isVideoOn ? Colors.black : Colors.white,
                                ));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: RoundedButton(
                          iconSrc: "assets/icons/call_end.svg",
                          press: () async {
                            setState(() {
                              FlutterCallkitIncoming.endAllCalls();
                              appValueNotifier.globalisCallOnGoing.value =
                                  false;
                            });
                            try {
                              player.release();
                              player.dispose();
                              timer!.cancel();
                              timer = null;
                              closeAgora();
                            } catch (e) {}
                            appValueNotifier.setToInitial();
                            callValueNotifiers.setToInitial();
                            Navigator.pop(context);
                          },
                          color: kRedColor,
                          iconColor: Colors.white,
                        ),
                      )

                      // DialButton(
                      //   iconSrc: Icons.mic_outlined,
                      //   text: "Microphone",
                      //   press: () {},
                      // ),
                      // DialButton(
                      //   iconSrc: Icons.videocam_off,
                      //   text: "Video",
                      //   press: () {},
                      // ),
                    ],
                  ),
                ),
                // const VerticalSpacing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ValueListenableBuilder<bool> getVideoCall() {
    return ValueListenableBuilder(
      valueListenable: appValueNotifier.isCallAccepted,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: appValueNotifier.isCallDeclined,
          builder: (context, value2, child) {
            return ValueListenableBuilder(
              valueListenable: appValueNotifier.isCallNotAnswered,
              builder: (context, notAnswered, child) {
                if (value2 || notAnswered) {
                  try {
                    player.release();
                    player.dispose();
                  } catch (e) {}
                  Future.delayed(const Duration(seconds: 2), () {
                    closeAgora;

                    appValueNotifier.globalisCallOnGoing.value = false;
                    try {
                      timer!.cancel();
                      timer = null;
                    } catch (e) {}

                    appValueNotifier.setToInitial();
                    FlutterCallkitIncoming.endAllCalls();
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (mounted) Navigator.pop(context);
                    });
                  });
                }
                if (value) {
                  try {
                    timer!.cancel();
                    timer = null;
                  } catch (e) {}
                  player.release();
                  player.dispose();
                }
                log(currentUserUid.toString());
                return (engine != null)
                    ? Column(
                        children: [
                          if (_isJoined) getLocalView(),
                          Expanded(
                              child: AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: engine!,
                              canvas: VideoCanvas(uid: _remoteUid),
                              connection:
                                  RtcConnection(channelId: CHANNEL_NAME),
                            ),
                          ))
                        ],
                      )
                    : Column(
                        children: [
                          const Spacer(),
                          DialUserPic(
                              image: CALLERDATA != null
                                  ? (CALLERDATA['photoUrl'] == null)
                                      ? staticPhotoUrl
                                      : CALLERDATA['photoUrl']
                                  : staticPhotoUrl),
                          const Spacer(),
                        ],
                      );
              },
            );
          },
        );
      },
    );
  }

  getLocalView() {
    try {
      return Expanded(
          child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine!,
          canvas: VideoCanvas(uid: currentUserUid),
        ),
      ));
    } catch (e) {
      log("Local video: " + e.toString());
    }
  }

  // Widget getVideoCall() {
  //   return Column(
  //     children: [],
  //   );
  // }

  Widget getAudioCall() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const VerticalSpacing(),
        const VerticalSpacing(),
        Text(
          CALLERDATA != null
              ? CALLERDATA['name'] ?? "Nothing to show"
              : "Nothing to show",
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.white),
        ),
        const VerticalSpacing(),
        ValueListenableBuilder(
          valueListenable: appValueNotifier.isCallAccepted,
          builder: (context, value, child) {
            return ValueListenableBuilder(
              valueListenable: appValueNotifier.isCallDeclined,
              builder: (context, value2, child) {
                return ValueListenableBuilder(
                  valueListenable: appValueNotifier.isCallNotAnswered,
                  builder: (context, notAnswered, child) {
                    if (value2 || notAnswered) {
                      try {
                        player.release();
                        player.dispose();
                      } catch (e) {}
                      Future.delayed(const Duration(seconds: 2), () {
                        closeAgora;

                        appValueNotifier.globalisCallOnGoing.value = false;
                        try {
                          timer!.cancel();
                          timer = null;
                        } catch (e) {}

                        appValueNotifier.setToInitial();
                        FlutterCallkitIncoming.endAllCalls();
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          if (mounted) Navigator.pop(context);
                        });
                      });
                    }
                    if (value) {
                      try {
                        timer!.cancel();
                        timer = null;
                      } catch (e) {}
                      player.release();
                      player.dispose();
                    }

                    return Text(
                      notAnswered
                          ? "Not Answered"
                          : value2
                              ? "Call Ended"
                              : value
                                  ? "Ongoing Call"
                                  : "Calling…",
                      style: const TextStyle(color: Colors.white60),
                    );
                  },
                );
              },
            );
          },
        ),
        const Spacer(),
        DialUserPic(
            image: CALLERDATA != null
                ? (CALLERDATA['photoUrl'] == null)
                    ? staticPhotoUrl
                    : CALLERDATA['photoUrl']
                : staticPhotoUrl),
        const Spacer(),
      ],
    );
  }

  closeAgora() async {
    try {
      // Wakelock.toggle(enable: false);
      await engine!.leaveChannel();
      await engine!.release();
      appValueNotifier.setToInitial();
      callValueNotifiers.setToInitial();
    } catch (e) {
      log(e.toString());
    }

    stopForegroundTask();
    engine = null;
    log("closing agora");
  }
}
