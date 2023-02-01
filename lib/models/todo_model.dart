import 'package:firebase_storage/firebase_storage.dart';

class TodoModel {
  final String todoId;
  final String assignedBy;
  final String todoTitle;
  final String deadline;
  final String taskDescription;
  final List taskList;
  final List people;
  final int progress;

  TodoModel({
    required this.todoId,
    required this.assignedBy,
    required this.todoTitle,
    required this.deadline,
    required this.taskDescription,
    required this.taskList,
    required this.people,
    this.progress = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'todoId': todoId,
      'assignedBy': assignedBy,
      'todoTitle': todoTitle,
      'deadline': deadline,
      'taskDescription': taskDescription,
      'taskList': taskList,
      'people': people,
      'progress': progress,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      todoId: map['todoId'],
      assignedBy: map['assignedBy'],
      todoTitle: map['todoTitle'],
      deadline: map['deadline'],
      taskDescription: map['taskDescription'],
      taskList: map['taskList'],
      people: map['people'],
      progress: map['progress'],
    );
  }
}

class TaskModel {
  final String taskId;
  bool isCompleted;
  String taskTitle;
  DateTime? completedAt;

  TaskModel({
    required this.taskId,
    required this.isCompleted,
    required this.taskTitle,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'isCompleted': isCompleted,
      'taskTitle': taskTitle,
      'completedAt': completedAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      taskId: map['taskId'],
      isCompleted: map['isCompleted'],
      taskTitle: map['taskTitle'],
      completedAt:
          map['completedAt'] != null ? map['completedAt'].toDate() : null,
    );
  }
}
