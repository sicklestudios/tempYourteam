import 'package:flutter/material.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/methods/chat_methods.dart';
import 'package:yourteam/models/chat_model.dart';

class ChatContactsListScreen extends StatefulWidget {
  String value;
  ChatContactsListScreen({required this.value, super.key});

  @override
  State<ChatContactsListScreen> createState() => _ChatContactsListScreenState();
}

class _ChatContactsListScreenState extends State<ChatContactsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<ChatContactModel>>(
                stream: ChatMethods().getChatContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == null) {
                    return getNewChatPrompt(context);
                  }
                  List<ChatContactModel> temp = [];
                  if (widget.value != "") {
                    for (var element in snapshot.data!) {
                      if (element.name.contains(widget.value)) {
                        temp.add(element);
                      }
                    }
                  } else {
                    temp = snapshot.data!;
                  }
                  if (temp.isEmpty) {
                    // return const Center(
                    //   child: Text("Nothing to show"),
                    // );
                    return getNewChatPrompt(context);
                  }
                  return ListView.builder(
                      itemCount: temp.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: ((context, index) {
                        var data = temp[index];
                        return getMessageCard(data, context);
                      }));
                }),
          ],
        ),
      ),
    );
  }
}
