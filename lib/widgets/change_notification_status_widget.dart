import 'package:agro_nepal/utilities/themes.dart';
import 'package:flutter/material.dart';
import '../services/apis/notifications_api.dart';
import '../services/shared_service.dart';

class ChangeNotificationStatusWidget extends StatefulWidget {
  const ChangeNotificationStatusWidget({Key? key}) : super(key: key);

  @override
  State<ChangeNotificationStatusWidget> createState() =>
      _ChangeNotificationStatusWidgetState();
}

class _ChangeNotificationStatusWidgetState
    extends State<ChangeNotificationStatusWidget> {
  bool isNotificationOn = !SharedService.isNotificationOn;

  void toggleSwitch(bool value) {
    if (isNotificationOn == false) {
      setState(() {
        isNotificationOn = true;
      });
    } else {
      setState(() {
        isNotificationOn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RawMaterialButton(
              onPressed: () {},
              elevation: 2.0,
              fillColor: ThemeClass.primaryColor,
              padding: const EdgeInsets.all(
                15,
              ),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.notifications,
                size: 22.0,
                color: Colors.white,
              ),
            ),
            const Text(
              'Mute Notifications',
            ),
          ],
        ),
        Row(
          children: [
            Switch(
              onChanged: (isDarkMode) {
                Notifications.changeNotificationStatus().then((value) {
                  toggleSwitch(isDarkMode);
                });
              },
              value: isNotificationOn,
              activeColor: ThemeClass.primaryColor,
              splashRadius: 4,
            ),
          ],
        ),
      ],
    );
  }
}
