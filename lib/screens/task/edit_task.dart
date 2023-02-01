import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/firestore_methods.dart';
import 'package:yourteam/methods/task_methods.dart';
import 'package:yourteam/models/todo_model.dart';
import 'package:yourteam/models/user_model.dart';

class EditTask extends StatefulWidget {
  final TodoModel model;
  const EditTask({required this.model, super.key});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late TodoModel model;
  String taskDeadline = "";
  int progress = 0;
  List tasksList = [];
  bool updatedStarted = false;
  List people = [];
  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskDesc = TextEditingController();
  TextEditingController taskAssignBy = TextEditingController();

  @override
  void initState() {
    super.initState();
    model = widget.model;
    taskDeadline = model.deadline;
    progress = model.progress;
    //Converting the values in map to normal format
    model.taskList.forEach((element) {
      TaskModel model = TaskModel.fromMap(element);
      tasksList.add(model);
    });
    taskTitle.text = model.todoTitle;
    taskDesc.text = model.taskDescription;
    taskAssignBy.text = model.assignedBy;
  }

  void refresh(List values) {
    setState(() {
      tasksList = values;
    });
    int completedTasks = 0;
    tasksList.forEach((element) {
      TaskModel model = element;
      if (model.isCompleted) {
        completedTasks++;
      }
    });
    progress = ((completedTasks / tasksList.length) * 100).toInt();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return !updatedStarted;
      },
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            title: const Text(
              "Edit-Task",
              style:
                  TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 70,
                            child: TextFormField(
                              controller: taskTitle,
                              onFieldSubmitted: (value) {},
                              onChanged: (val) {
                                setState(() {});
                              },
                              autofocus: false,
                              decoration: const InputDecoration(
                                filled: true,
                                labelText: "Task Title",
                                labelStyle: TextStyle(
                                    // color: Color.fromRGBO(23, 35, 49, 1),
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                hintText: 'Enter the task title',
                                // filled: true,
                                fillColor: Colors.white,
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(102, 124, 150, 1),
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DateTimePicker(
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: "Date & Time",
                              labelText: "Date & Time",
                              labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            type: DateTimePickerType.dateTime,

                            dateMask: 'd MMM, yyyy - hh:mm a',
                            // use24HourFormat: false,
                            initialValue: model.deadline,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            icon: const Icon(Icons.event),
                            dateLabelText: 'Deadline',
                            timeLabelText: "Time",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 18),
                            onChanged: (val) {
                              setState(() {
                                taskDeadline = val;
                              });
                            },
                            onSaved: (val) => log(val.toString()),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              // margin: const EdgeInsets.all(12),
                              height: 5 * 24.0,
                              child: TextField(
                                controller: taskDesc,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: "Enter Description",
                                  labelText: "Description",
                                  labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.bold,
                                      height: 1),
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, right: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 28.0,
                                    lineWidth: 5.0,
                                    animation: true,
                                    percent: progress / 100,
                                    center: Text(
                                      "$progress%",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color: Colors.black),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    reverse: true,
                                    backgroundColor: const Color.fromARGB(
                                        255, 237, 236, 236),
                                    progressColor: mainColor,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    // width: size.width / 1.1,
                                    height: 60,
                                    child: Center(
                                      child: ListTile(
                                        title: const Text(
                                          "See Tasks List",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        onTap: () {
                                          showTaskListAdd(
                                              context, tasksList, refresh);
                                        },
                                        trailing:
                                            const Icon(Icons.arrow_forward),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: taskAssignBy,
                            onFieldSubmitted: (value) {},
                            onChanged: (val) {
                              setState(() {});
                            },
                            autofocus: false,
                            // obscureText: passObscure,
                            decoration: const InputDecoration(
                              filled: true,

                              labelText: "Assigned by",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'Assigned By',
                              // filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(
                                  color: Color.fromRGBO(102, 124, 150, 1),
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Text(
                  //   model.todoTitle,
                  //   textAlign: TextAlign.start,
                  //   style: const TextStyle(
                  //       overflow: TextOverflow.visible,
                  //       fontWeight: FontWeight.w400,
                  //       fontSize: 18),
                  // ),

                  _getAddedPeople(
                    people: model.people,
                  ),

                  // const SizedBox(
                  //   height: 5,
                  // ),
                  // const Text(
                  //   "Tasks List:",
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(15.0),
                  //   child: Text(
                  //     model.assignedBy,
                  //     style: const TextStyle(
                  //         overflow: TextOverflow.visible,
                  //         fontWeight: FontWeight.w400,
                  //         fontSize: 18),
                  //   ),
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: taskTitle.text.isEmpty ||
                                    taskAssignBy.text.isEmpty ||
                                    taskDeadline.isEmpty ||
                                    updatedStarted
                                ? null
                                : () {
                                    updateTask();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              minimumSize: const Size(306, 54),
                            ),
                            child: !updatedStarted
                                ? const Text(
                                    'Update',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )
                                : const CircularProgressIndicator(
                                    color: mainColor,
                                  )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  updateTask() async {
    showToastMessage('Updating Todo, Please Wait');
    setState(() {
      updatedStarted = true;
    });
    List taskInMapForm = [];
    // int completedTasks = 0;
    //generating the progress
    tasksList.forEach((element) {
      // TaskModel model = element;
      // if (model.isCompleted) {
      //   completedTasks++;
      // }
      taskInMapForm.add(element.toMap());
    });

    String res = await TaskMethods().updateTask(
        // ((completedTasks / tasksList.length) * 100).toInt(),
        progress,
        model.assignedBy,
        model.todoTitle,
        taskDeadline,
        model.taskDescription,
        model.todoId,
        model.people,
        taskInMapForm);
    if (res == "Success") {
      Navigator.pop(context);
    } else {
      updatedStarted = false;
    }
  }
}

class _getAddedPeople extends StatefulWidget {
  const _getAddedPeople({
    Key? key,
    required this.people,
  }) : super(key: key);

  final List people;

  @override
  State<_getAddedPeople> createState() => _getAddedPeopleState();
}

class _getAddedPeopleState extends State<_getAddedPeople> {
  List tempList = [];

  @override
  void initState() {
    super.initState();
    tempList = widget.people;
    tempList.remove(firebaseAuth.currentUser!.uid);
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                'People',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(23, 35, 49, 1),
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: mainColor),
                  borderRadius: BorderRadius.circular(15)),
              child: widget.people.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showPeopleForTask(context, widget.people, refresh);
                          },
                          child: const Card(
                            child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Icon(Icons.add, size: 60),
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tempList.length + 1,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: ((context, index) {
                        if (widget.people.isEmpty) {}
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                showPeopleForTask(
                                    context, widget.people, refresh);
                              },
                              child: const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(Icons.add, size: 60),
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: FutureBuilder<UserModel>(
                                  future: FirestoreMethods()
                                      .getUserInformationOther(
                                          widget.people[index - 1]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Card(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      snapshot.data!.photoUrl),
                                            ),
                                            Text(snapshot.data!.username),
                                          ],
                                        ),
                                      ));
                                    }
                                    return const Text("Loading");
                                  })),
                        );
                      })),
            ),
          ),
        ],
      ),
    );
  }
}
