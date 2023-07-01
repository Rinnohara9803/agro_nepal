import 'package:google_maps_flutter/google_maps_flutter.dart';

class SharedService {
  static bool isUserAdmin = false;
  static String userName = '';
  static String email = '';
  static String userImageUrl = '';
  static LatLng currentPosition = const LatLng(0, 0);
  static LatLng deliveryPosition = const LatLng(0, 0);
  static bool isNotificationOn = false;
  static String contactNumber = '';
  static String deliveryLocation = '';
}
