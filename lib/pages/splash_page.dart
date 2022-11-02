import 'dart:async';
import 'dart:io';
import 'package:agro_nepal/pages/dashboard_page.dart';
import 'package:agro_nepal/pages/sign_in_page.dart';
import 'package:agro_nepal/pages/verify_email_page.dart';
import 'package:agro_nepal/providers/profile_provider.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/apis/notifications_api.dart';
import '../services/shared_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? _token;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> getNotificationStatus() async {
    await Notifications.getIsNotificationOnValue();
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () {
      fetchUser();
    });
    getNotificationStatus();
    super.initState();
    requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!SharedService.isNotificationOn) {
        return;
      }
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.white,
              playSound: true,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!SharedService.isNotificationOn) {
        return;
      }
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              priority: Priority.high,
              channelDescription: channel.description,
              color: Colors.white,
              playSound: true,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission.');
    } else {
      print('User declined the permission.');
    }
  }

  void getToken(String userId) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(_token);
      Notifications.saveToken(token!, userId);
    });
  }

  Future fetchUser() async {
    // ignore: unrelated_type_equality_checks
    if (FirebaseAuth.instance.authStateChanges().isEmpty == true) {
      Navigator.pushNamed(context, SignInPage.routeName);
    } else {
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified == false) {
        Navigator.pushNamed(context, VerifyEmailPage.routeName);
        return;
      } else {
        try {
          await Provider.of<ProfileProvider>(context, listen: false)
              .fetchProfile()
              .then((value) {
            getToken(user!.uid);
            Navigator.pushReplacementNamed(context, DashboardPage.routeName);
          });
        } on SocketException catch (_) {
          Navigator.pushReplacementNamed(context, SignInPage.routeName);
        } catch (e) {
          Navigator.pushReplacementNamed(context, SignInPage.routeName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeClass.primaryColor.withOpacity(
          0.7,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/planting.png',
                height: 150,
                width: 150,
              ),
              const AutoSizeText(
                'agro_nepal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                  fontFamily: 'Lato',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
