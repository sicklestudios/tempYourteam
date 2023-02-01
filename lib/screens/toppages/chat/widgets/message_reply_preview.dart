import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/message_enum.dart';
import 'package:yourteam/constants/message_reply.dart';
import 'package:yourteam/screens/toppages/chat/widgets/display_text_image_file.dart';

class MessageReplyPreview extends StatefulWidget {
  final MessageReply? messageReply;
  final String photoUrl;
  const MessageReplyPreview(
      {required this.messageReply, required this.photoUrl, super.key});

  @override
  State<MessageReplyPreview> createState() => _MessageReplyPreviewState();
}

class _MessageReplyPreviewState extends State<MessageReplyPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: mainColorFaded,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.messageReply!.isMe ? 'Me' : 'Opposite',
                  // 'Me',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    messageReply = null;
                  });
                },
                icon: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DisplayTextImageGIF(
            photoUrl: widget.photoUrl,
            message: widget.messageReply!.message,
            type: widget.messageReply!.messageEnum,
            isSender: widget.messageReply!.isMe,
          ),
          // DisplayTextImageGIF(
          //   message: "This is message",
          //   type: MessageEnum.text,
          //   isSender: false,
          // ),
        ],
      ),
    );
  }
}
