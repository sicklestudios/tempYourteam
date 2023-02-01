import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/task_methods.dart';
import 'package:yourteam/models/todo_model.dart';
import 'package:yourteam/screens/task/edit_task.dart';

class TodoScreen extends StatefulWidget {
  final String? id;
  const TodoScreen({this.id, super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoModel> onGoingTask = [];
  List<TodoModel> upComingTask = [];
  String uid = "";
  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.id != null) {
  //     uid = widget.id!;
  //   }
  //   log("uid = $uid");
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.id != null) {
      uid = widget.id!;
    } else {
      uid = firebaseAuth.currentUser!.uid;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<TodoModel>>(
                stream: TaskMethods().getTodos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == null) {
                    return const Center(
                      child: Text("Nothing to show you"),
                    );
                  }
                  upComingTask = [];
                  onGoingTask = [];
                  for (var values in snapshot.data!) {
                    if (values.progress == 0) {
                      if (uid != "") {
                        if (values.people.contains(uid)) {
                          upComingTask.add(values);
                        }
                      } else {
                        upComingTask.add(values);
                      }
                    } else {
                      if (uid != "") {
                        if (values.people.contains(uid)) {
                          onGoingTask.add(values);
                        }
                      } else {
                        onGoingTask.add(values);
                      }
                    }
                  }

                  return Column(
                    children: [
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "Ongoing Task",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      onGoingTask.isEmpty
                          ? const Center(
                              child: Text(
                                "Nothing to show",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 190,
                              child: ListView.builder(
                                  itemCount: onGoingTask.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: ((context, index) {
                                    var data = onGoingTask[index];
                                    log(data.todoTitle);
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditTask(model: data)));
                                      },
                                      child: getTodoCardOnGoing(data, context),
                                    );
                                  })),
                            ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "Upcoming Task",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      upComingTask.isEmpty
                          ? const Center(
                              child: Text(
                                "Nothing to show",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : SizedBox(
                              width: MediaQuery.of(context).size.width,
                              // height: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  itemCount: upComingTask.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  // scrollDirection: Axis.vertical,
                                  itemBuilder: ((context, index) {
                                    var data = upComingTask[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditTask(model: data)));
                                      },
                                      child: getTodoCardUpcoming(data, context),
                                    );
                                  })),
                            ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
 //if the snapshot contains data
              // return ExpansionPanelList(
              //   expansionCallback: (int index, bool isExpanded) {
              //     setState(() {
              //       if (index == 0) {
              //         showOngoing = !showOngoing;
              //       } else if (index == 1) {
              //         // showOngoing = !showOngoing;
              //         showUpComing = !showUpComing;
              //       }
              //     });
              //   },
              //   children: [
              //     ExpansionPanel(
              //       backgroundColor: mainColorFaded,
              //       headerBuilder: (BuildContext context, bool isExpanded) {
              //         return const ListTile(
              //           title: Text("Ongoing Task"),
              //         );
              //       },
              //       canTapOnHeader: true,
              //       isExpanded: showOngoing,
              //       body: const ListTile(
              //         title: Text("Hey buddy"),
              //       ),
              //     ),
              //     ExpansionPanel(
              //       backgroundColor: mainColorFaded,
              //       headerBuilder: (BuildContext context, bool isExpanded) {
              //         return const ListTile(
              //           title: Text("Upcoming Task"),
              //         );
              //       },
              //       canTapOnHeader: true,
              //       isExpanded: showUpComing,
              //       body: const ListTile(
              //         title: Text("Hey buddy"),
              //       ),
              //     ),
              //   ],
              // );