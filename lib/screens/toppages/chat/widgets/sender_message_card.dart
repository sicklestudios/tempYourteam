import 'package:flutter/material.dart';
import 'package:yourteam/constants/message_enum.dart';
import 'package:yourteam/screens/toppages/chat/widgets/display_text_image_file.dart';

class SenderMessageCard extends StatelessWidget {
  final String photoUrl;
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback longPress;
  final bool? isSelected;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  const SenderMessageCard(
      {required this.photoUrl,
      required this.message,
      required this.date,
      required this.type,
      required this.longPress,
      required this.repliedText,
      required this.username,
      this.isSelected,
      required this.repliedMessageType,
      super.key});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: 5,
              maxWidth: type != MessageEnum.audio
                  ? MediaQuery.of(context).size.width / 1.6
                  : MediaQuery.of(context).size.width / 1.25),
          child: Column(
            children: [
              Row(
                children: [
                  if (isSelected != null)
                    if (isSelected!) const Icon(Icons.check_box),
                  Flexible(
                    child: Card(
                      elevation: 1,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        // bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      )),
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Padding(
                          // padding: const EdgeInsets.only(
                          //     left: 10, right: 30, top: 5, bottom: 5),
                          padding: const EdgeInsets.all(15),
                          child: DisplayTextImageGIF(
                              photoUrl: photoUrl,
                              date: date,
                              message: message,
                              type: type,
                              isSender: false)),
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 8),
                  child: Text(
                    date == "null" ? "" : date,
                    style: const TextStyle(
                        fontSize: 13, color: Color.fromARGB(124, 0, 0, 0)),
                  ),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
