import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/message_enum.dart';
import 'package:yourteam/screens/toppages/chat/widgets/play_audio.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:yourteam/screens/toppages/chat/widgets/show_file_preview.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String photoUrl;
  final String message;
  final MessageEnum type;
  final bool isSender;
  final String? date;
  DisplayTextImageGIF({
    Key? key,
    required this.photoUrl,
    required this.message,
    required this.type,
    required this.isSender,
    this.date,
  }) : super(key: key);

  bool isPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    final imageProvider = CachedNetworkImageProvider(message);

    return type == MessageEnum.link
        ? AnyLinkPreview(
            link: message,
            displayDirection: UIDirection.uiDirectionHorizontal,
            showMultimedia: true,
            bodyMaxLines: 5,
            bodyTextOverflow: TextOverflow.ellipsis,
            titleStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            placeholderWidget: Text(
              message,
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 141, 181, 250)),
            ),
            errorWidget: TextButton(
              onPressed: () {
                _launchUrl(message);
              },
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 141, 181, 250)),
              ),
            ),
            bodyStyle: const TextStyle(color: Colors.black, fontSize: 12),
            // errorBody: 'Show my custom error body',
            // errorTitle: 'Show my custom error title',
            // errorWidget: Container(
            //     color: Colors.grey[300],
            //     child: const Text('Oops!'),
            // ),
            // errorImage: "https://google.com/",
            cache: const Duration(days: 7),
            backgroundColor: Colors.white,
            borderRadius: 12,
            removeElevation: false,
            // boxShadow: [const BoxShadow(blurRadius: 3, color: Colors.white)],
            onTap: () {
              _launchUrl(message);
            }, // This disables tap event
          )
        : type == MessageEnum.text
            ? TextSelectionTheme(
                // primaryColor: Colors.red,
                data: TextSelectionThemeData(
                  // cursorColor: Colors.red,
                  selectionColor: isSender
                      ? (Colors.white.withOpacity(0.4))
                      : mainColor.withOpacity(0.4),
                  selectionHandleColor: Colors.red,
                ),
                child: Text(
                  message,

                  // cursorColor: Colors.white,
                  // showCursor: true,

                  // selectionControls: Se,
                  // toolbarOptions:
                  //     const ToolbarOptions(copy: true, selectAll: true),
                  style: TextStyle(
                      fontSize: 16,
                      color: date != null
                          ? date == "null"
                              ? Colors.grey
                              : isSender
                                  ? Colors.white
                                  : Colors.black
                          : isSender
                              ? Colors.white
                              : Colors.black),
                ),
              )
            : type == MessageEnum.audio
                ? PlayAudio(
                    photoUrl: photoUrl,
                    audioUrl: message,
                    isSender: isSender,
                  )
                : type == MessageEnum.file
                    ? ShowFilePreview(
                        url: message,
                        isSender: isSender,
                      )
                    // : type == MessageEnum.gif
                    //             ? CachedNetworkImage(
                    //                 imageUrl: message,
                    //               )
                    : InkWell(
                        onTap: () {
                          showImageViewer(context, imageProvider,
                              onViewerDismissed: () {
                            print("dismissed");
                          });
                        },
                        child: CachedNetworkImage(
                          imageUrl: message,
                          // placeholder: (context, url) =>
                          //     Image.asset("assets/placeholder.jpg"),
                          progressIndicatorBuilder: (context, url, progress) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset("assets/placeholder.jpg"),
                                CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ],
                            );
                          },
                        ),
                      );
  }

  Future<void> _launchUrl(String link) async {
    final Uri url = Uri.parse(link);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
