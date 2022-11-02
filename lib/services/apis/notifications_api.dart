import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../models/user.dart';
import '../shared_service.dart';

class Notifications {
  static void saveToken(String token, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('userTokens').doc(userId).set(
        {
          'token': token,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteToken(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('userTokens').doc(userId).set(
        {
          'token': '',
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> sendPushMessage(
      String token, String title, String body) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAArC3QuJI:APA91bFUQmP_yzgI88dAvGHh2gDlzno-RfTyKbYnbX3olrNWXBwK_mBUdC1QMoA_-ZxsFR62_wYcLJashdQba_Kr590YZI9mHz0nBd_qOw-Vv1GeyVLG-2zi6FrghRx8WdMCVxQ-bYqU',
        },
        body: constructFCMPayload(
          token,
          title,
          body,
        ),
      );
    } catch (e) {
      print(e.toString());
      return Future.error(e.toString());
    }
  }

  static Future<void> notifyAdmin(String title, String body) async {
    String token = '';
    List<TheUser> users = [];

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((snapshot) {
        for (var theUser in snapshot.docs) {
          users.add(
            TheUser(
              isAdmin: theUser.data()['tag'],
              userId: theUser.data()['userId'],
              userName: theUser.data()['userName'],
            ),
          );
        }
      }).then((value) async {
        TheUser user =
            users.firstWhere((theUser) => theUser.isAdmin == 'admin');
        await FirebaseFirestore.instance
            .collection('userTokens')
            .doc(user.userId)
            .get()
            .then((snapshot) {
          token = snapshot.data()!['token'];
        }).then((value) async {
          await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAArC3QuJI:APA91bFUQmP_yzgI88dAvGHh2gDlzno-RfTyKbYnbX3olrNWXBwK_mBUdC1QMoA_-ZxsFR62_wYcLJashdQba_Kr590YZI9mHz0nBd_qOw-Vv1GeyVLG-2zi6FrghRx8WdMCVxQ-bYqU',
            },
            body: constructFCMPayload(
              token,
              title,
              body,
            ),
          );
        });
      });
    } catch (e) {
      print('ee');
      print(e.toString());
      return Future.error(e.toString());
    }
  }

  static Future<void> changeNotificationStatus() async {
    if (SharedService.isNotificationOn == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isNotificationOn', true);
      SharedService.isNotificationOn =
          prefs.getBool('isNotificationOn') as bool;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isNotificationOn', false);
      SharedService.isNotificationOn =
          prefs.getBool('isNotificationOn') as bool;
    }
  }

  static Future<void> getIsNotificationOnValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isNotificationOn = prefs.getBool('isNotificationOn');

    if (isNotificationOn == false) {
      SharedService.isNotificationOn = false;
    } else {
      SharedService.isNotificationOn = true;
    }
    print('here');
    print(SharedService.isNotificationOn);
  }
}
