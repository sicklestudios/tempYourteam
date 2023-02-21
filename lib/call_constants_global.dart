import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// bool globalisCallOnGoing = false;
// bool isCallAccepted = false;
// bool isCallDeclined = false;
AppValueNotifier appValueNotifier = AppValueNotifier();
CallValueNotifiers callValueNotifiers = CallValueNotifiers();
RtcEngine? engine;
Timer? timer;
final player = AudioPlayer();
AudioCache? audioCache;
final users = <int>[];
final infoStrings = <String>[];
bool isinit = false;

class CallValueNotifiers {
  ValueNotifier<bool> isSpeakerOn = ValueNotifier(false);
  ValueNotifier<bool> isMicOff = ValueNotifier(false);
  ValueNotifier<bool> isVideoOn = ValueNotifier(false);

  void setToInitial() {
    isSpeakerOn.value = false;
    isMicOff.value = false;
    isVideoOn.value = false;
  }

  void setSpeakerValue(bool value) {
    isSpeakerOn.value = value;
  }

  void setMicValue(bool value) {
    isMicOff.value = value;
  }

  void setIsVideoOn(bool value) {
    isVideoOn.value = value;
  }
  // void incrementNotifier() {
  //   valueNotifier.value++;
  // }
}

class AppValueNotifier {
  ValueNotifier<bool> isCallAccepted = ValueNotifier(false);
  ValueNotifier<bool> isCallDeclined = ValueNotifier(false);
  ValueNotifier<bool> isCallNotAnswered = ValueNotifier(false);
  ValueNotifier<bool> globalisCallOnGoing = ValueNotifier(false);

  void setToInitial() {
    isCallAccepted.value = false;
    isCallDeclined.value = false;
    isCallNotAnswered.value = false;
  }

  void setCallAccepted() {
    isCallAccepted.value = true;
  }

  void setCallDeclined() {
    isCallDeclined.value = true;
  }

  void setIsCallNotAnswered() {
    isCallNotAnswered.value = true;
  }
  // void incrementNotifier() {
  //   valueNotifier.value++;
  // }
}
