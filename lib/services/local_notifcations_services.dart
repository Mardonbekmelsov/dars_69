import 'dart:io';

import 'package:dars_69/services/quote_http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzl;

class LocalNotifcationsServices {
  static final localNotification = FlutterLocalNotificationsPlugin();
  final QuoteHttpService quoteHttpService = QuoteHttpService();

  static bool notificationsEnabled = false;

  static Future<void> requestPemission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      notificationsEnabled = await localNotification
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      final androidImplementation =
          localNotification.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      final bool? grantedScheduleNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      notificationsEnabled = grantedNotificationPermission ?? false;
      notificationsEnabled = grantedScheduleNotificationPermission ?? false;
    }
  }

  static Future<void> start() async {
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tzl.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const androidInit = AndroidInitializationSettings('mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
    );
    final notificationInit = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await localNotification.initialize(notificationInit);
  }

  static void showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'goodChannelId',
      'goodChannelName',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      // actions: [
      //   AndroidNotificationAction("id_1", 'Action 1'),
      //   AndroidNotificationAction("id_2", 'Action 2'),
      //   AndroidNotificationAction("id_3", 'Action 3'),
      // ],
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: "demoCategory",
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final quote = await QuoteHttpService.getQuote();

    await localNotification.show(0, 'Quote for you',
        "${quote['quote']}\nauthor: ${quote['author']}", notificationDetails);
  }

   static void scheduleNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotification.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 15)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: "Hello World",
    );
  }

  static void periodicallyShowNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      importance: Importance.max,
      priority: Priority.max
      
    );
    const iosDetails = DarwinNotificationDetails(
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotification.periodicallyShowWithDuration(
      id,
      title,
      body,
      const Duration(seconds: 60),
      notificationDetails,
      payload: "Hello World",
    );
  }

  
  static void periodicallyShowNotificationQuote({
    int id = 0,
   
  }) async {
    final quote= await QuoteHttpService.getQuote();
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      importance: Importance.max,
      priority: Priority.max
    );
    const iosDetails = DarwinNotificationDetails(
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotification.periodicallyShowWithDuration(
      id,
      quote['author'],
      quote['quote'],
      const Duration(minutes: 1),
      notificationDetails,
      payload: "Hello world",
    );
  }

  static Future<NotificationDetails> _groupedNotificationDetails() async {
    const List<String> lines = <String>[
      'Team 1 Play Badminton',
      'Team 1   Play Volleyball',
      'Team 1   Play Cricket',
      'Team 2 Play Badminton',
      'Team 2   Play Volleyball'
    ];
    const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '5 messages',
      summaryText: 'missed messages',
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'channel id',
      'channel name',
      sound: RawResourceAndroidNotificationSound("slow_spring_board"),
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      setAsGroupSummary: true,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      styleInformation: inboxStyleInformation,
      color: Color(0xff2196f3),
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(threadIdentifier: "thread2");

    final details = await localNotification
        .getNotificationAppLaunchDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  static Future<void> showGroupedNotifications({
    required String title,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final groupedPlatformChannelSpecifics = await _groupedNotificationDetails();
    await localNotification.show(
      0,
      "Team 1",
      "Play Badminton ",
      platformChannelSpecifics,
    );
    await localNotification.show(
      1,
      "Team 1",
      "Play Volleyball",
      platformChannelSpecifics,
    );
    await localNotification.show(
      3,
      "Team 1",
      "Play Cricket",
      platformChannelSpecifics,
    );
    await localNotification.show(
      4,
      "Team 2",
      "Play Badminton",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await localNotification.show(
      5,
      "Team 2",
      "Play Volleyball",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await localNotification.show(
      6,
      Platform.isIOS ? "Team 2" : "Attention",
      Platform.isIOS ? "Play Cricket" : "5 missed messages",
      groupedPlatformChannelSpecifics,
    );
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    print("on background tap");
  }
}
