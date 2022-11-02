import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'cart.dart';

class Order with ChangeNotifier {
  final String orderId;
  final String userId;
  final String orderedBy;
  final double amount;
  String paymentStatus;
  String deliveryStatus;
  String deliveryTime;
  final List<CartItem> products;
  final DateTime dateTime;

  Order({
    required this.orderId,
    required this.userId,
    required this.orderedBy,
    required this.amount,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.deliveryTime,
    required this.products,
    required this.dateTime,
  });
  Future<void> changePOStatus(String pStatus, String dStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'paymentStatus': pStatus,
        'deliveryStatus': dStatus,
        'deliveryTime': '40 minutes'
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> fetchOrderById() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get()
          .then((snapshot) {
        paymentStatus = snapshot.data()!['paymentStatus'];
        notifyListeners();
        deliveryStatus = snapshot.data()!['deliveryStatus'];
        notifyListeners();
        deliveryTime = snapshot.data()!['deliveryTime'];
        notifyListeners();
      });
    } catch (e) {
      print(e);
      return Future.error(
        e.toString(),
      );
    }
  }
}
