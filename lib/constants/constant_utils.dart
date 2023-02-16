import 'dart:developer';
import 'dart:math' as math;

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/constants/message_reply.dart';
import 'package:yourteam/methods/chat_methods.dart';
import 'package:yourteam/methods/contact_methods.dart';
import 'package:yourteam/models/call_model.dart';
import 'package:yourteam/models/chat_model.dart';
import 'package:yourteam/models/todo_model.dart';
import 'package:yourteam/models/user_model.dart';
import 'package:yourteam/screens/bottom_pages.dart/contacts_screen.dart';
import 'package:yourteam/screens/call/calls_ui/screens/dialScreen/dial_screen.dart';
import 'package:yourteam/screens/search_screen.dart';
import 'package:yourteam/screens/toppages/chat/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

//value to store if its replying or not
MessageReply? messageReply;
//getting a random number
math.Random random = math.Random();

Widget getCallNotifierWidget(context) {
  return Container(
    height: 35,
    width: MediaQuery.of(context).size.width,
    decoration: const BoxDecoration(color: mainColor),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        onTap: () {
          log("Hi Call pressed");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DialScreen()));
        },
        child: SizedBox(
          height: 35,
          width: MediaQuery.of(context).size.width,
          child: const Center(
              child: Text(
            "Ongoing Call",
            style: TextStyle(color: Colors.white, fontSize: 18),
          )),
        ),
      ),
    ),
  );
}

void showFloatingFlushBar(
    BuildContext context, String upMessage, String downMessage) {
  Flushbar(
    borderRadius: BorderRadius.circular(8),
    duration: const Duration(seconds: 1),
    backgroundGradient: const LinearGradient(
      colors: [mainColor, mainColorFaded],
      stops: [0.6, 1],
    ),
    boxShadows: const [
      BoxShadow(
        color: Colors.white,
        offset: Offset(3, 3),
        blurRadius: 3,
      ),
    ],
    titleColor: Colors.white,
    messageColor: Colors.white,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    title: upMessage,
    message: downMessage,
  ).show(context);
}

showToastMessage(String toastText) {
  Fluttertoast.showToast(
      msg: toastText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: mainColor,
      textColor: Colors.white,
      fontSize: 16.0);
}

getRandom() {
  return random.nextInt(3) + 0;
}

getMessageCard(ChatContactModel model, context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      height: 80,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                    contactModel: ChatContactModel(
                        contactId: model.contactId,
                        name: model.name,
                        photoUrl: model.photoUrl,
                        timeSent: DateTime.now(),
                        lastMessageBy: "",
                        lastMessageId: '',
                        isSeen: false,
                        lastMessage: ""),
                  )));
        },
        leading: Stack(
          children: [
            model.photoUrl != ""
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: CachedNetworkImageProvider(
                      model.photoUrl,
                      // maxWidth: 50,
                      // maxHeight: 50,
                    ))
                : const CircleAvatar(
                    radius: 25, backgroundImage: AssetImage('assets/user.png')),
            StreamBuilder<bool>(
                stream: ChatMethods().getOnlineStream(model.contactId),
                builder: (context, snapshot) {
                  return Positioned(
                      bottom: 1,
                      right: 1,
                      child: Icon(
                        Icons.circle_rounded,
                        size: 14,
                        color: snapshot.data != null
                            ? snapshot.data!
                                ? Colors.green
                                : Colors.grey
                            : Colors.grey,
                      ));
                }),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              model.name,
              // "model."
              // "name",
              style: TextStyle(
                  fontSize: 18,
                  //  bodyTextOverflow: TextOverflow.ellipsis,
                  fontWeight:
                      model.lastMessageBy != firebaseAuth.currentUser!.uid
                          ? !model.isSeen
                              ? FontWeight.bold
                              : FontWeight.normal
                          : FontWeight.normal),
            ),
            Text(
              DateFormat.jm().format(model.timeSent),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      model.lastMessageBy != firebaseAuth.currentUser!.uid
                          ? !model.isSeen
                              ? FontWeight.bold
                              : FontWeight.normal
                          : FontWeight.normal),
            ),
          ],
        ),
        subtitle: SizedBox(
          height: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    model.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            model.lastMessageBy != firebaseAuth.currentUser!.uid
                                ? !model.isSeen
                                    ? FontWeight.bold
                                    : FontWeight.normal
                                : FontWeight.normal),
                  ),
                ),
              ),
              Icon(
                Icons.circle,
                color: model.lastMessageBy != firebaseAuth.currentUser!.uid
                    ? !model.isSeen
                        ? mainColor
                        : Colors.transparent
                    : Colors.transparent,
                size: 14,
              )
            ],
          ),
        ),
      ),
    ),
  );
}

getIcon(icon) {
  return Icon(
    icon,
    color: Colors.black,
  );
}

showSimpleDialog(BuildContext context) async {
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) => SimpleDialog(
              title: const Center(child: Text("All Apps")),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.all(8),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50)),
                          width: 55,
                          height: 55,
                          child: const Center(
                              child: Icon(
                            Icons.folder,
                            size: 35,
                            color: Color.fromARGB(255, 85, 164, 88),
                          )),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Files",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50)),
                          width: 55,
                          height: 55,
                          child: const Center(
                              child: Icon(
                            Icons.notes_outlined,
                            size: 35,
                            color: Colors.blue,
                          )),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Notes",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 45,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50)),
                          width: 55,
                          height: 55,
                          child: const Center(
                              child: Icon(
                            Icons.note_alt,
                            size: 35,
                            color: Color.fromARGB(255, 171, 70, 70),
                          )),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "To Do",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 249, 236, 122)
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50)),
                          width: 55,
                          height: 55,
                          child: Center(
                              child: Icon(
                            Icons.lock_clock,
                            size: 35,
                            color: Colors.yellow.shade900,
                          )),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Reminder",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ])));
}

showNewMessage(BuildContext context) async {
  var size = MediaQuery.of(context).size;
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) => SimpleDialog(
              title: Row(
                children: [
                  const Expanded(
                      child: Center(child: Text("Create New Message"))),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.all(8),
              children: [
                SizedBox(
                  height: size.height / 2,
                  width: size.width,
                  child: Scaffold(
                    body: ContactsScreen(
                      isChat: true,
                    ),
                  ),
                ),
              ])));
}

showNewCall(BuildContext context) async {
  var size = MediaQuery.of(context).size;
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) => SimpleDialog(
              title: Row(
                children: [
                  const Expanded(child: Center(child: Text("New Call"))),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.all(8),
              children: [
                SizedBox(
                  height: size.height / 2,
                  width: size.width,
                  child: Scaffold(
                    body: ContactsScreen(
                      isChat: false,
                    ),
                  ),
                ),
              ])));
}

showAddToContact(BuildContext context, UserModel model) async {
  var size = MediaQuery.of(context).size;
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) => SimpleDialog(
              title: Row(
                children: [
                  const Expanded(child: Center(child: Text("Add to Contact"))),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.all(8),
              children: [
                SizedBox(
                  height: size.height / 2,
                  width: size.width,
                  child: Scaffold(
                      body: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                CachedNetworkImageProvider(model.photoUrl)),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          model.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            model.bio != "" ? model.bio : "Nothing to Show",
                            overflow: TextOverflow.visible,
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: mainColor,
                              ),
                              Text(
                                model.location != ""
                                    ? model.location
                                    : "Nothing to Show",
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.phone,
                                color: mainColor,
                              ),
                              Text(
                                model.contact != ""
                                    ? model.contact
                                    : "Nothing to Show",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.email,
                                color: mainColor,
                              ),
                              Text(
                                model.email,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              String res =
                                  await ContactMethods().addContact(model.uid);
                              if (res == "success") {
                                Navigator.pop(context);
                                //getting the userInfo
                                fetchUserInfo();
                              } else {
                                showFloatingFlushBar(context, "Error", res);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              minimumSize: const Size(306, 54),
                            ),
                            child: Text(
                              userInfo.contacts.contains(model.uid)
                                  ? "Remove"
                                  : 'Add',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            )),
                      ],
                    ),
                  )),
                ),
              ])));
}

fetchUserInfo() async {
  {
    await firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser?.uid)
        .get()
        .then((value) {
      userInfo = UserModel.getValuesFromSnap(value);
    });
  }
}

showPeopleForTask(
    BuildContext context, List usersList, VoidCallback refresh) async {
  var size = MediaQuery.of(context).size;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) => SimpleDialog(
              title: Row(
                children: [
                  const Expanded(child: Center(child: Text("Add People"))),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        refresh();
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.all(8),
              children: [
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: size.height / 2,
                    width: size.width,
                    child: Scaffold(
                        body: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: FutureBuilder<List<UserModel>>(
                          future: ChatMethods().getContacts(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data == null) {
                              return const Center(
                                child: Text("Nothing to show you"),
                              );
                            }
                            return Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      shrinkWrap: true,
                                      itemBuilder: ((context, index) {
                                        var data = snapshot.data![index];
                                        return InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (usersList
                                                    .contains(data.uid)) {
                                                  // usersModelList.remove(data);
                                                  usersList.remove(data.uid);
                                                } else {
                                                  // usersModelList.add(data);
                                                  usersList.add(data.uid);
                                                }
                                              });
                                            },
                                            child: getPeopleCard(data, context,
                                                usersList.contains(data.uid)));
                                      })),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: ElevatedButton(
                                //       onPressed: () {
                                //         // showPeopleForTask(context, people);
                                //       },
                                //       style: ElevatedButton.styleFrom(
                                //         backgroundColor: mainColor,
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(8),
                                //         ),
                                //         padding: const EdgeInsetsDirectional
                                //             .fromSTEB(0, 0, 0, 0),
                                //         minimumSize: Size(size.width / 2, 54),
                                //       ),
                                //       child: const Text(
                                //         'Add People',
                                //         textAlign: TextAlign.left,
                                //         style: TextStyle(
                                //             color: Color.fromRGBO(
                                //                 255, 255, 255, 1),
                                //             fontFamily: 'Poppins',
                                //             fontSize: 15,
                                //             letterSpacing:
                                //                 0 /*percentages not used in flutter. defaulting to zero*/,
                                //             fontWeight: FontWeight.normal,
                                //             height: 1),
                                //       )),
                                // ),
                              ],
                            );
                          }),
                    )),
                  );
                }),
              ])));
}

showTaskListAdd(
    BuildContext context, List taskList, ValueSetter<List> refresh) async {
  ScrollController scrollController = ScrollController();
  TextEditingController taskController = TextEditingController();

  var size = MediaQuery.of(context).size;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) => SimpleDialog(
              title: Row(
                children: [
                  const Expanded(
                      child: Center(child: Text("Add or Edit Tasks"))),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        refresh(taskList);
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.all(8),
              children: [
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: size.height / 2,
                    width: size.width,
                    child: Scaffold(
                        body: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          taskList.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No task added",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                      itemCount: taskList.length,
                                      shrinkWrap: true,
                                      controller: scrollController,
                                      itemBuilder: ((context, index) {
                                        // if (index == taskList.length) {
                                        //   return Padding(
                                        //     padding: const EdgeInsets.symmetric(
                                        //         vertical: 8, horizontal: 15),
                                        //     child: Container(
                                        //       decoration: BoxDecoration(
                                        //           color: Colors.white,
                                        //           borderRadius: BorderRadius.circular(15)),
                                        //       child: const ListTile(
                                        //         title: Text(
                                        //           "Add a task",
                                        //           style: TextStyle(
                                        //               fontSize: 18,
                                        //               fontWeight: FontWeight.bold),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   );
                                        // }
                                        // TaskModel data =
                                        //     TaskModel.fromMap();
                                        return InkWell(
                                            // onTap: () {
                                            //   setState(() {
                                            //     //if the task is set as completed
                                            //     if (data.isCompleted) {
                                            //       setState(() {
                                            //         data.isCompleted = false;
                                            //         data.completedAt = null;
                                            //       });
                                            //     } else {
                                            //       setState(() {
                                            //         data.isCompleted = true;
                                            //         data.completedAt =
                                            //             DateTime.now();
                                            //       });
                                            //     }
                                            //   });
                                            // },
                                            child: getTaskCard(
                                                taskList[index],
                                                context,
                                                () => setState(() {
                                                      taskList.removeAt(index);
                                                    })));
                                      })),
                                ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: taskController,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: "Add a task",
                                      suffixIcon: InkWell(
                                          onTap: () {
                                            if (taskController
                                                .text.isNotEmpty) {
                                              var messageId = const Uuid().v1();

                                              TaskModel taskModel = TaskModel(
                                                taskId: messageId.toString(),
                                                isCompleted: false,
                                                taskTitle: taskController.text,
                                              );
                                              taskList.add(taskModel);
                                              taskController.text = "";
                                              setState(
                                                () {
                                                  taskList;
                                                },
                                              );
                                            }
                                            SchedulerBinding.instance
                                                .addPostFrameCallback((_) {
                                              scrollController.jumpTo(
                                                  scrollController.position
                                                      .maxScrollExtent);
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
                        ],
                      ),
                    )),
                  );
                }),
              ])));
}

// showNewContact(BuildContext context) async {
//   var size = MediaQuery.of(context).size;
//   TextEditingController email = TextEditingController();
//   // TextEditingController contact = TextEditingController();
//   return await showDialog(
//       barrierDismissible: true,
//       context: context,
//       builder: ((context) => SimpleDialog(
//               title: Row(
//                 children: [
//                   const Expanded(child: Center(child: Text("Add New Contact"))),
//                   IconButton(
//                       onPressed: () {
//                         Navigator.of(context, rootNavigator: true).pop();
//                       },
//                       icon: const Icon(Icons.close))
//                 ],
//               ),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25)),
//               contentPadding: const EdgeInsets.all(8),
//               children: [
//                 SizedBox(
//                     height: size.height / 3.5,
//                     width: size.width,
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             children: const [
//                               Text(
//                                 'Email or Username',
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                     color: Color.fromRGBO(23, 35, 49, 1),
//                                     fontFamily: 'Poppins',
//                                     fontSize: 15,
//                                     letterSpacing: 0,
//                                     fontWeight: FontWeight.bold,
//                                     height: 1),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Expanded(
//                         //   child: Padding(
//                         //     padding: const EdgeInsets.symmetric(horizontal: 20),
//                         //     child:
//                         //   ),
//                         // ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ElevatedButton(
//                               onPressed: () {
//                                 // login();
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 padding: const EdgeInsetsDirectional.fromSTEB(
//                                     0, 0, 0, 0),
//                                 minimumSize: const Size(306, 54),
//                               ),
//                               child: const Text(
//                                 'Search',
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                     color: Color.fromRGBO(255, 255, 255, 1),
//                                     fontFamily: 'Poppins',
//                                     fontSize: 15,
//                                     letterSpacing:
//                                         0 /*percentages not used in flutter. defaulting to zero*/,
//                                     fontWeight: FontWeight.normal,
//                                     height: 1),
//                               )),
//                         ),
//                       ],
//                     )),
//               ])));
// }

getCallCard(CallModel model) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: model.receiverPic == ""
                  ? Image.asset(
                      'assets/user.png',
                      width: 50,
                      height: 50,
                    )
                  : CachedNetworkImage(
                      imageUrl: model.receiverPic,
                      width: 50,
                      height: 50,
                      fit: BoxFit.fitHeight,
                    ),
            ),
            Positioned(
                bottom: 1,
                right: 1,
                child: Icon(
                  Icons.circle_rounded,
                  size: 14,
                  color: model.isIncoming ? Colors.lightGreen : Colors.grey,
                ))
          ],
        ),
        title: Text(
          model.receiverName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(
              model.isIncoming
                  ? Icons.call_received_rounded
                  : Icons.call_made_rounded,
              color: model.isIncoming ? Colors.orange : mainColor,
              size: 18,
            ),
            Text(
              DateFormat.jm().format(model.timeSent),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
            onPressed: () {},
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50)),
                  width: 45,
                  height: 45,
                ),
                Icon(
                  model.isAudioCall
                      ? Icons.call_rounded
                      : Icons.video_call_rounded,
                  color: mainColor,
                ),
              ],
            )),
      ),
    ),
  );
}

getContactCard(UserModel model, context, bool isChat) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatScreen(
                  contactModel: ChatContactModel(
                      contactId: model.uid,
                      name: model.username,
                      photoUrl: model.photoUrl,
                      timeSent: DateTime.now(),
                      lastMessageBy: "",
                      lastMessageId: "",
                      isSeen: false,
                      lastMessage: ""),
                )));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: model.photoUrl == ""
                    ? Image.asset(
                        'assets/user.png',
                        width: 50,
                        height: 50,
                      )
                    : CachedNetworkImage(
                        imageUrl: model.photoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.fitHeight,
                      ),
              ),
              StreamBuilder<bool>(
                  stream: ChatMethods().getOnlineStream(model.uid),
                  builder: (context, snapshot) {
                    return Positioned(
                        bottom: 1,
                        right: 1,
                        child: Icon(
                          Icons.circle_rounded,
                          size: 14,
                          color: snapshot.data != null
                              ? snapshot.data!
                                  ? Colors.green
                                  : Colors.grey
                              : Colors.grey,
                        ));
                  }),
            ],
          ),
          title: Text(
            model.username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              //   Icon(
              //     Icons.message_rounded,
              //     color: model.isIncoming ? Colors.orange : mainColor,
              //     size: 18,
              //   ),
              Text(
                model.location,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50)),
            width: 45,
            height: 45,
            child: Icon(
              isChat ? Icons.message_rounded : Icons.call,
              color: mainColor,
            ),
          ),
        ),
      ),
    ),
  );
}

getForwardCard(UserModel model, context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: model.photoUrl == ""
                    ? Image.asset(
                        'assets/user.png',
                        width: 50,
                        height: 50,
                      )
                    : CachedNetworkImage(
                        imageUrl: model.photoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.fitHeight,
                      ),
              ),
              StreamBuilder<bool>(
                  stream: ChatMethods().getOnlineStream(model.uid),
                  builder: (context, snapshot) {
                    return Positioned(
                        bottom: 1,
                        right: 1,
                        child: Icon(
                          Icons.circle_rounded,
                          size: 14,
                          color: snapshot.data != null
                              ? snapshot.data!
                                  ? Colors.green
                                  : Colors.grey
                              : Colors.grey,
                        ));
                  }),
            ],
          ),
          title: Text(
            model.username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Text(
                model.location,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50)),
            width: 45,
            height: 45,
            child: const Icon(
              Icons.arrow_forward_ios,
              color: mainColor,
            ),
          )),
    ),
  );
}

getTodoCardOnGoing(TodoModel model, context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      height: 170,
      width: MediaQuery.of(context).size.width / 1.2,
      decoration: BoxDecoration(
          color: cardColors[0], borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircularPercentIndicator(
                    radius: 28.0,
                    lineWidth: 5.0,
                    animation: true,
                    percent: model.progress / 100,
                    center: Text(
                      "${model.progress}%",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          color: Colors.white),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.white,
                  )
                ],
              ),
            ),
            ListTile(
              isThreeLine: true,
              title: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  model.todoTitle,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8, left: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.white),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          model.deadline,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Assigned by: ",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          model.assignedBy,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

getTodoCardUpcoming(TodoModel model, context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
            isThreeLine: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 8, left: 5),
              child: Text(
                model.todoTitle,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8, left: 5),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        model.deadline,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Assigned by: ",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        model.assignedBy,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ),
                    ],
                  )
                ],
              ),
            ),
            trailing: CircularPercentIndicator(
              radius: 28.0,
              lineWidth: 5.0,
              animation: true,
              percent: model.progress / 100,
              center: Text(
                "${model.progress}%",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.purple,
            )),
      ),
    ),
  );
}

getPeopleCard(UserModel model, context, bool isSelected) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: model.photoUrl == ""
                    ? Image.asset(
                        'assets/user.png',
                        width: 50,
                        height: 50,
                      )
                    : CachedNetworkImage(
                        imageUrl: model.photoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.fitHeight,
                      ),
              ),
            ],
          ),
          title: Text(
            model.username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Text(
                model.location,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50)),
            width: 45,
            height: 45,
            child: Icon(
              isSelected ? Icons.circle : Icons.circle,
              color: isSelected ? mainColor : Colors.grey,
            ),
          )),
    ),
  );
}

getTaskCard(TaskModel model, context, VoidCallback callback,
    {ValueSetter<List>? refresh, List? tasksList}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: InkWell(
            onTap: () {
              setState(() {
                //if the task is set as completed
                if (model.isCompleted) {
                  setState(() {
                    model.isCompleted = false;
                    model.completedAt = null;
                  });
                } else {
                  setState(() {
                    model.isCompleted = true;
                    model.completedAt = DateTime.now();
                  });
                }
              });
              refresh!(tasksList!);
            },
            child: Container(
                decoration: BoxDecoration(
                    // color: mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                width: 45,
                height: 45,
                child: Icon(
                  Icons.check_box,
                  color: model.isCompleted ? mainColor : Colors.grey,
                )),
            // child: Container(
            //     decoration: BoxDecoration(
            //         color: mainColor.withOpacity(0.1),
            //         borderRadius: BorderRadius.circular(50)),
            //     width: 45,
            //     height: 45,
            //     child: Icon(
            //       Icons.circle,
            //       color: model.isCompleted ? mainColor : Colors.grey,
            //     )),
          ),
          title: Text(
            model.taskTitle,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: !model.isCompleted ? Colors.black : Colors.grey,
                decoration: model.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none),
          ),
          subtitle: model.completedAt != null
              ? Row(
                  children: [
                    Text(
                      timeago.format(model.completedAt!, locale: "en_short"),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : null,
          trailing: InkWell(
            onTap: () {
              _showDeleteDialog(context, callback);
              setState(() {});
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50)),
                width: 45,
                height: 45,
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                )),
          ),
        ),
      );
    }),
  );
}

_showDeleteDialog(context, VoidCallback callback) {
  showDialog(
      context: context,
      builder: (ctxt) => AlertDialog(
            title: const Text("Alert"),
            content: const Text("Are you sure you want to delete this chat?"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    callback();

                    Navigator.pop(context);
                  },
                  child: const Text("Continue")),
            ],
          ));
}

//returs a widget that acts as a prompt
getNewChatPrompt(context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 150,
        child: Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "You dont have any chats\nstart a chat",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    showNewMessage(context);
                  },
                  child: const Text('Start a chat')),
            ],
          ),
        ),
      ),
    ),
  );
}

//returs a widget that acts as a prompt
getNewContactPrompt(context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 150,
        child: Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "You dont have any contacts\nAdd a contact",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SearchScreen()));
                  },
                  child: const Text('Add a contact')),
            ],
          ),
        ),
      ),
    ),
  );
}
