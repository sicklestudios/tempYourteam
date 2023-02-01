import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/firestore_methods.dart';
import 'package:yourteam/models/todo_model.dart';
import 'package:yourteam/service/local_push_notification.dart';

class TaskMethods {
  Future<String> setTask(
    String assignedBy,
    String taskTitle,
    String deadline,
    String taskDescription,
    List people,
    List tasksList,
  ) async {
    String res = "Some error occurred";

    try {
      people.add(userInfo.uid);
      var taskId = const Uuid().v1();

      TodoModel todoModel = TodoModel(
          todoId: taskId,
          assignedBy: assignedBy,
          todoTitle: taskTitle,
          deadline: deadline,
          taskDescription: taskDescription,
          taskList: tasksList,
          people: people);
      await firebaseFirestore
          .collection('todos')
          .doc(taskId)
          .set(todoModel.toMap());
      showToastMessage("Task Added");
      res = "Success";
      //getting the list of all the peoples added in the todo and sending them a notification as well as adding
      //that in there notifications collection
      for (var element in people) {
        if (element != firebaseAuth.currentUser!.uid) {
          await FirestoreMethods().setNotificationHistory(
              element,
              firebaseAuth.currentUser!.uid,
              "Task",
              userInfo.username + " assigned you a task");
          DocumentSnapshot documentSnapshot =
              await firebaseFirestore.collection('users').doc(element).get();
          //receivers token for sending notification to the user
          String token = documentSnapshot.get('token');
          await sendNotification(
              element, token, userInfo.username + " assigned you a task");
        }
      }
    } on FirebaseAuthException catch (err) {
      res = err.message.toString();
    }
    return res;
  }

  Future<String> updateTask(
    int progress,
    String assignedBy,
    String taskTitle,
    String deadline,
    String taskDescription,
    String taskId,
    List people,
    List taskList,
  ) async {
    String res = "Some error occurred";
    try {
      people.add(userInfo.uid);
      TodoModel todoModel = TodoModel(
          progress: progress,
          todoId: taskId,
          assignedBy: assignedBy,
          todoTitle: taskTitle,
          deadline: deadline,
          taskList: taskList,
          taskDescription: taskDescription,
          people: people);
      await firebaseFirestore
          .collection('todos')
          .doc(taskId)
          .update(todoModel.toMap());
      showToastMessage("Task Updated");
      res = "Success";
      //getting the list of all the peoples added in the todo and sending them a notification as well as adding
      //that in there notifications collection
      for (var element in people) {
        if (element != firebaseAuth.currentUser!.uid) {
          await FirestoreMethods().setNotificationHistory(
              element,
              firebaseAuth.currentUser!.uid,
              "Task",
              userInfo.username + " assigned you a task");
          DocumentSnapshot documentSnapshot =
              await firebaseFirestore.collection('users').doc(element).get();
          //receivers token for sending notification to the user
          String token = documentSnapshot.get('token');
          await sendNotification(
              element, token, userInfo.username + " assigned you a task");
        }
      }
    } on FirebaseAuthException catch (err) {
      res = err.message.toString();
    }
    return res;
  }

  Stream<List<TodoModel>> getTodos() {
    return firebaseFirestore.collection('todos').snapshots().map((event) {
      List<TodoModel> messages = [];
      for (var document in event.docs) {
        // log(document.data().toString());
        try {
          messages.add(TodoModel.fromMap(document.data()));
        } catch (e) {
          log(e.toString());
        }
      }
      return messages;
    });
  }

  // Stream getTodos() {
  //   return firebaseFirestore.collection('todos').snapshots();
  // }
}
