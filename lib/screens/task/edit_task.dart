import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid.dart';
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
  bool showAddTaskField = false;

  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskDesc = TextEditingController();
  TextEditingController taskAssignBy = TextEditingController();
  ScrollController scrollController = ScrollController();
  TextEditingController taskController = TextEditingController();

  FocusNode focusNode = FocusNode();
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
    KeyboardVisibilityController().onChange.listen((isVisible) {
      if (isVisible == false && showAddTaskField) {
        setState(() {
          showAddTaskField = false;
        });
      }
    });
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
            actions: [
              IconButton(
                onPressed: () {
                  taskTitle.text.isEmpty ||
                          taskAssignBy.text.isEmpty ||
                          taskDeadline.isEmpty ||
                          updatedStarted
                      ? showToastMessage("Fields cannot be empty")
                      : updateTask();
                },
                icon: const Icon(
                  Icons.check,
                  color: Colors.black,
                ),
              ),
            ],
            centerTitle: true,
            title: const Text(
              "Edit-Task",
              style:
                  TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
            ),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
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
                            Container(
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(210, 240, 240, 240),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, right: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 25.0),
                                          child: Text(
                                            'Tasks',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    23, 35, 49, 1),
                                                fontFamily: 'Poppins',
                                                fontSize: 15,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.bold,
                                                height: 1),
                                          ),
                                        ),
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
                                          circularStrokeCap:
                                              CircularStrokeCap.round,
                                          reverse: true,
                                          backgroundColor: const Color.fromARGB(
                                              255, 237, 236, 236),
                                          progressColor: mainColor,
                                        )
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            210, 240, 240, 240),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    height: tasksList.isEmpty
                                        ? size.height / 5.5
                                        : tasksList.length >= 2
                                            ? tasksList.length >= 4
                                                ? size.height / 3
                                                : size.height / 2
                                            : size.height / 4,
                                    width: size.width,
                                    child: Scaffold(
                                        backgroundColor: Colors.transparent,
                                        body: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: ListView.builder(
                                              itemCount: tasksList.length + 1,
                                              shrinkWrap: true,
                                              controller: scrollController,
                                              itemBuilder: ((context, index) {
                                                if (index == tasksList.length) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        showAddTaskField = true;
                                                      });
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      child: Card(
                                                          child: ListTile(
                                                        title: Text(
                                                          "Add a task",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        trailing: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: CircleAvatar(
                                                            radius: 18,
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_upward_sharp,
                                                              color:
                                                                  Colors.white,
                                                              size: 35,
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                    ),
                                                  );
                                                }
                                                // TaskModel data =
                                                //     TaskModel.fromMap();
                                                return InkWell(
                                                    child: getTaskCard(
                                                        tasksList[index],
                                                        context,
                                                        () => setState(() {
                                                              tasksList
                                                                  .removeAt(
                                                                      index);
                                                            }),
                                                        refresh: refresh,
                                                        tasksList: tasksList));
                                              })),
                                        )),
                                  ),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                  // Expanded(
                                  //   child: Padding(
                                  //       padding: const EdgeInsets.all(8.0),
                                  //       child: Container(
                                  //         decoration: BoxDecoration(
                                  //             color: Colors.white,
                                  //             borderRadius:
                                  //                 BorderRadius.circular(15)),
                                  //         // width: size.width / 1.1,
                                  //         height: 60,
                                  //         child: Center(
                                  //           child: ListTile(
                                  //             title: const Text(
                                  //               "See Tasks List",
                                  //               style: TextStyle(fontSize: 18),
                                  //             ),
                                  //             onTap: () {
                                  //               showTaskListAdd(
                                  //                   context, tasksList, refresh);
                                  //             },
                                  //             trailing:
                                  //                 const Icon(Icons.arrow_forward),
                                  //           ),
                                  //         ),
                                  //       )),
                                  // ),
                                ],
                              ),
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
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
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
              if (showAddTaskField)
                Card(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskController,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: "Add a task",
                              suffixIcon: InkWell(
                                  onTap: () {
                                    if (taskController.text.isNotEmpty) {
                                      var messageId = const Uuid().v1();

                                      TaskModel taskModel = TaskModel(
                                        taskId: messageId.toString(),
                                        isCompleted: false,
                                        taskTitle: taskController.text,
                                      );
                                      tasksList.add(taskModel);
                                      taskController.text = "";
                                      setState(
                                        () {
                                          tasksList;
                                        },
                                      );
                                    }
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                      scrollController.jumpTo(scrollController
                                          .position.maxScrollExtent);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: CircleAvatar(
                                      radius: 18,
                                      child: Icon(
                                        Icons.arrow_upward_sharp,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  ))),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
