import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/methods/firestore_methods.dart';
import 'package:yourteam/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
            "Notifications",
            style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: FutureBuilder<List<NotificationModel>>(
              future: FirestoreMethods().getNotificationsList(),
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
                      return _notificationCard(data);
                    }));
              }),
        ));
  }

  _notificationCard(NotificationModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
                color: mainColorFaded.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15)),
            width: 55,
            height: 55,
            child: const Center(
                child: Icon(
              Icons.notifications,
              size: 35,
              color: mainColor,
            )),
          ),
          title: Text(
            model.notificationTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(model.notificationSubtitle),
          trailing: Text(
            timeago.format(model.datePublished, locale: "en_short"),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
