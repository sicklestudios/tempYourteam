import 'package:flutter/material.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/methods/chat_methods.dart';
import 'package:yourteam/models/user_model.dart';

class ContactsScreen extends StatefulWidget {
  final bool isChat;
  String? value;
  ContactsScreen({required this.isChat, this.value, super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FutureBuilder<List<UserModel>>(
          future: ChatMethods().getContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null) {
              // return const Center(
              //   child: Text("Nothing to show you"),
              // );
              return getNewContactPrompt(context);
            }
            if (snapshot.data!.isEmpty) {
              // return const Center(
              //   child: Text("Nothing to show you"),
              // );
              return getNewContactPrompt(context);
            }
            List<UserModel> temp = [];
            if (widget.value != null) {
              for (var element in snapshot.data!) {
                if (element.username.contains(widget.value!)) {
                  temp.add(element);
                }
              }
            } else {
              temp = snapshot.data!;
            }
            if (temp.isEmpty) {
              return const Center(
                child: Text("Nothing to show"),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  var data = snapshot.data![index];
                  return getContactCard(data, context, widget.isChat);
                }));
          }),
    );
  }
}
