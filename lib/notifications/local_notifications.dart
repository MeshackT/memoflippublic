import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../reuse/reuse.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> getPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotificationOnForeground(message);
      final routeFromMessage = message.data["/"];
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final routeFromMessage = message.data["/"];
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        );
    _notificationsPlugin.initialize(initializationSettings);
  }

  static void showNotificationOnForeground(RemoteMessage message) {
    var notificationDetail = NotificationDetails(
      android: AndroidNotificationDetails(
        "high_importance_channel", // must match the manifest
        "High Importance Notifications", // user-visible name

        importance: Importance.max,
        priority: Priority.high,

        styleInformation: BigTextStyleInformation(
          "${message.notification!.body}",
          // 'Grey Background Notification',
          htmlFormatContent: true,
          htmlFormatTitle: true,
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
          // Set the background color to grey
          htmlFormatBigText: true, // Enable HTML formatting for big text
        ),
      ),
    );

    _notificationsPlugin.show(
      DateTime.now().microsecond,
      message.notification!.title,
      message.notification!.body,
      notificationDetail,
      payload: message.data["/"],
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
  }

  /*
    Check in and out
  */

  /*
  * Subscribe to topic
  * */
  final topic = "memoflip";
  static Future<void> subscribeToTopicDevice() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic("memoflip");
      logger.i("subscribed to memoflip");
    } catch (e) {
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  /*
  * Unsubscribe to topic
  */
  static Future<void> unSubscribeToTopicDevice(
    String? subscribeToTopicAll,
  ) async {
    try {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(subscribeToTopicAll!)
          .whenComplete(
            () => Fluttertoast.showToast(
              backgroundColor: Colors.green,
              msg:
                  "you will no longer receive messages from updates and things to teach",
              textColor: Colors.white,
            ),
          );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
