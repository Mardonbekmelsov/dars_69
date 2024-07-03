import 'package:dars_69/services/local_notifcations_services.dart';
import 'package:dars_69/views/screens/main_scree.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifcationsServices.requestPemission();
  await LocalNotifcationsServices.start();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScree(),
    );
  }
}
