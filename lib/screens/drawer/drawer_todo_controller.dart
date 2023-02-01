import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/screens/bottom_pages.dart/todo_screen.dart';

class DrawerTodoController extends StatefulWidget {
  const DrawerTodoController({super.key});

  @override
  State<DrawerTodoController> createState() => _DrawerTodoControllerState();
}

class _DrawerTodoControllerState extends State<DrawerTodoController> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "To Do",
            style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(children: [
          const SizedBox(
            height: 10,
          ),
          _TabSwitch(
            value: pageIndex,
            callBack: () {
              setState(() {
                if (pageIndex == 0) {
                  pageIndex = 1;
                } else {
                  pageIndex = 0;
                }
                log(pageIndex.toString());
              });
            },
          ),

          Expanded(
              child: TodoScreen(
                  id: pageIndex == 1 ? firebaseAuth.currentUser!.uid : ""))
          // Expanded(child: TodoScreen()),
        ]));
  }
}

class _TabSwitch extends StatefulWidget {
  int value;
  VoidCallback callBack;
  _TabSwitch({Key? key, required this.value, required this.callBack})
      : super(key: key);

  @override
  State<_TabSwitch> createState() => _TabSwitchState();
}

class _TabSwitchState extends State<_TabSwitch> {
  bool isChat = true;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (widget.value == 0) {
      isChat = true;
    } else {
      isChat = false;
    }
    return GestureDetector(
      onTap: widget.callBack,
      child: Container(
        height: 50,
        width: size.width / 1.2,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(35)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isChat ? 0 : size.width / 1.2 * 0.5,
              child: Container(
                height: 50,
                width: size.width / 1.2 * 0.5,
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(35)),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "All",
                      style: TextStyle(
                          color: isChat ? Colors.white : mainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "My To Do",
                      style: TextStyle(
                          color: isChat ? mainColor : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
