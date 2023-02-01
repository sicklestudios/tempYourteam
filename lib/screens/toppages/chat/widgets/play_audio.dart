import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';

class PlayAudio extends StatefulWidget {
  final String audioUrl;
  final bool isSender;
  final String photoUrl;
  const PlayAudio(
      {required this.audioUrl,
      required this.isSender,
      required this.photoUrl,
      super.key});

  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  bool isPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    audioPlayer.setSourceUrl(widget.audioUrl);
    audioPlayer.onPlayerComplete.listen((it) {
      setState(() {
        isPlaying = false;
        audioPlayer.seek(Duration.zero);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSender
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: widget.photoUrl == ""
                          ? const AssetImage(
                              'assets/user.png',
                            )
                          : CachedNetworkImageProvider(
                              widget.photoUrl,
                            ) as ImageProvider,
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                          setState(() {
                            isPlaying = false;
                          });
                        } else {
                          await audioPlayer.play(UrlSource(widget.audioUrl));
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: widget.isSender ? Colors.white : Colors.black,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: StreamBuilder<Duration>(
                          stream: audioPlayer.onPositionChanged,
                          builder: (context, snapshot) {
                            return StreamBuilder<Duration>(
                                stream: audioPlayer.onDurationChanged,
                                builder: (context, snapshots) {
                                  return ProgressBar(
                                    thumbRadius: 8,
                                    timeLabelTextStyle:
                                        const TextStyle(color: Colors.white),
                                    baseBarColor: Colors.white,
                                    progress: snapshot.data ?? Duration.zero,
                                    buffered: Duration.zero,
                                    total: snapshots.data ?? Duration.zero,
                                    onSeek: (duration) {
                                      audioPlayer.seek(duration);
                                    },
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              )
            ],
          )
        : Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.play(UrlSource(widget.audioUrl));
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: widget.isSender ? Colors.white : Colors.black,
                    size: 35,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: StreamBuilder<Duration>(
                          stream: audioPlayer.onPositionChanged,
                          builder: (context, snapshot) {
                            return StreamBuilder<Duration>(
                                stream: audioPlayer.onDurationChanged,
                                builder: (context, snapshots) {
                                  return ProgressBar(
                                    thumbRadius: 8,
                                    timeLabelTextStyle:
                                        const TextStyle(color: mainColor),
                                    baseBarColor: mainColor.withOpacity(0.5),
                                    progress: snapshot.data ?? Duration.zero,
                                    buffered: Duration.zero,
                                    total: snapshots.data ?? Duration.zero,
                                    onSeek: (duration) {
                                      audioPlayer.seek(duration);
                                    },
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: widget.photoUrl == ""
                      ? const AssetImage(
                          'assets/user.png',
                        )
                      : CachedNetworkImageProvider(
                          widget.photoUrl,
                        ) as ImageProvider,
                ),
              ),
            ],
          );
  }
}
