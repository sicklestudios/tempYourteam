import 'package:flutter/material.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/models/call_model.dart';
import 'package:yourteam/screens/call/call_methods.dart';

class CallScreenList extends StatefulWidget {
  const CallScreenList({super.key});

  @override
  State<CallScreenList> createState() => _CallScreenListState();
}

class _CallScreenListState extends State<CallScreenList> {
  @override
  Widget build(BuildContext context) {
    // return Text("data");
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FutureBuilder<List<CallModel>>(
          future: CallMethods().getCallsList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null) {
              return const Center(
                child: Text("Nothing to show"),
              );
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Nothing to show"),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  var data = snapshot.data![index];
                  return getCallCard(data);
                }));
          }),
    );
  }
}
