import 'package:dars_69/services/local_notifcations_services.dart';
import 'package:flutter/material.dart';

class MainScree extends StatefulWidget {
  @override
  State<MainScree> createState() => _MainScreeState();
}

class _MainScreeState extends State<MainScree> {
  void showNotification() async {
    LocalNotifcationsServices.showNotification();
    await Future.delayed(Duration(seconds: 10)).then(
      (value) => showNotification(),
    );
  }

  @override
  void initState() {
    super.initState();
    showNotification();
    LocalNotifcationsServices.periodicallyShowNotificationQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Main Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!LocalNotifcationsServices.notificationsEnabled)
              const Text("ruxsat berilmagan"),
            FilledButton(
                onPressed: () {
                  LocalNotifcationsServices.periodicallyShowNotification(
                      title: "Dam Olish vaqti",
                      body: "ish vaqtida tanaffus zarur");
                },
                child: Text("pomodoro")),
          ],
        ),
      ),
    );
  }
}
