import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';

class AddTaskTodo extends StatefulWidget {
  const AddTaskTodo({super.key});

  @override
  State<AddTaskTodo> createState() => _AddTaskTodoState();
}

class _AddTaskTodoState extends State<AddTaskTodo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Add-Todo",
          style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
