import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/screens/drawer/drawer_files/dawer_links_screen.dart';
import 'package:yourteam/screens/drawer/drawer_files/drawer_file_screen.dart';
import 'package:yourteam/screens/drawer/drawer_files/drawer_media_screen.dart';

class DrawerMenuController extends StatefulWidget {
  const DrawerMenuController({super.key});

  @override
  State<DrawerMenuController> createState() => _DrawerMenuControllerState();
}

class _DrawerMenuControllerState extends State<DrawerMenuController> {
  int index = 0;
  List pages = [const MediaScreen(), const LinkScreen(), const FileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          index == 0
              ? "Files"
              : index == 1
                  ? "Link"
                  : "Docs",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(children: [
        _TabSwitch(
            value: index,
            callBack: (val) {
              setState(() {
                index = val;
              });
            }),
        Expanded(child: pages[index])
      ]),
    );
  }
}

class _TabSwitch extends StatefulWidget {
  int value;
  ValueSetter<int> callBack;
  _TabSwitch({Key? key, required this.value, required this.callBack})
      : super(key: key);

  @override
  State<_TabSwitch> createState() => _TabSwitchState();
}

class _TabSwitchState extends State<_TabSwitch> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    index = widget.value;
    return Center(
      child: Container(
        height: 50,
        width: size.width,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(35)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: index == 0
                  ? 8
                  : index == 1
                      ? size.width * 0.35
                      : size.width * 0.68,
              child: Container(
                height: 50,
                width: size.width / 3.4,
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(35)),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.callBack(0);
                    },
                    child: SizedBox(
                      height: 50,
                      width: size.width / 3.4,
                      child: Center(
                        child: Text(
                          "Media",
                          style: TextStyle(
                              color: index == 0 ? Colors.white : mainColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.callBack(1);
                    },
                    child: SizedBox(
                      height: 50,
                      width: size.width / 3.4,
                      child: Center(
                        child: Text(
                          "Link",
                          style: TextStyle(
                              color: index == 1 ? Colors.white : mainColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    width: size.width / 3.4,
                    child: InkWell(
                      onTap: () {
                        widget.callBack(2);
                      },
                      child: Center(
                        child: Text(
                          "Docs",
                          style: TextStyle(
                              color: index == 2 ? Colors.white : mainColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
