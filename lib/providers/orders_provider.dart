import 'package:agro_nepal/providers/order.dart';
import 'package:agro_nepal/providers/cart.dart';
import 'package:agro_nepal/services/shared_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> addOrderItem(double amount, List<CartItem> products) async {
    final timeStamp = DateTime.now().toIso8601String();
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;
    try {
      await FirebaseFirestore.instance.collection('orders').doc(timeStamp).set(
        {
          'orderId': timeStamp,
          'userId': userUid,
          'orderedBy': SharedService.userName,
          'totalAmount': amount,
          'dateTime': timeStamp,
          'paymentStatus': 'Not paid',
          'deliveryStatus': 'Booked',
          'deliveryTime': 'Not specified',
          'deliveryLocation': 'Not specified',
          'contactNumber': 'Not specified',
          'products': products.map(
            (cartItem) {
              return {
                'id': cartItem.id,
                'title': cartItem.title,
                'price': cartItem.price,
                'quantity': cartItem.quantity,
                'sellingUnit': cartItem.sellingUnit,
                'imageUrl': cartItem.imageUrl,
              };
            },
          ).toList(),
        },
      ).then((value) {});
      _orders.insert(
        0,
        Order(
          orderId: timeStamp,
          userId: userUid,
          orderedBy: SharedService.userName,
          amount: amount,
          paymentStatus: 'Not paid',
          deliveryStatus: 'Booked',
          deliveryTime: 'Not specified',
          deliveryLocation: 'Not specified',
          contactNumber: 'Not specified',
          products: products,
          dateTime: DateTime.parse(timeStamp),
        ),
      );
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;
    try {
      var collectionRef = FirebaseFirestore.instance.collection('orders');

      await collectionRef.get().then(
        (snapshot) {
          List<Order> loadedOrders = [];
          for (var order in snapshot.docs) {
            loadedOrders.add(
              Order(
                orderId: order.data()['orderId'],
                userId: order.data()['userId'],
                orderedBy: order.data()['orderedBy'],
                amount: order.data()['totalAmount'],
                paymentStatus: order.data()['paymentStatus'],
                deliveryStatus: order.data()['deliveryStatus'],
                deliveryTime: order.data()['deliveryTime'].toString(),
                deliveryLocation: order.data()['deliveryLocation'],
                contactNumber: order.data()['contactNumber'],
                products: (order.data()['products'] as List<dynamic>)
                    .map((orderData) {
                  return CartItem(
                    id: orderData['id'] as String,
                    title: orderData['title'] as String,
                    price: double.parse(
                      orderData['price'].toString(),
                    ),
                    sellingUnit: orderData['sellingUnit'],
                    quantity: int.parse(orderData['quantity'].toString()),
                    imageUrl: orderData['imageUrl'] as String,
                  );
                }).toList(),
                dateTime: DateTime.parse(order.data()['dateTime']),
              ),
            );

            loadedOrders.sort(
              (a, b) {
                return DateTime.parse(b.dateTime.toIso8601String()).compareTo(
                  DateTime.parse(
                    a.dateTime.toIso8601String(),
                  ),
                );
              },
            );
          }

          if (SharedService.isUserAdmin) {
            _orders = loadedOrders;
            notifyListeners();
          } else {
            _orders =
                loadedOrders.where((order) => order.userId == userUid).toList();
            notifyListeners();
          }
        },
      );
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('orders');

      await collectionRef.doc(id).delete().then((value) {
        Order order = _orders.firstWhere((order) => order.orderId == id);
        _orders.remove(order);
        notifyListeners();
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> fetchOrderById(Order order) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .get()
          .then((snapshot) {
        order.paymentStatus = snapshot.data()!['paymentStatus'];
        notifyListeners();
        order.deliveryStatus = snapshot.data()!['deliveryStatus'];
        notifyListeners();
        order.deliveryTime = snapshot.data()!['deliveryTime'];
        notifyListeners();
        order.deliveryLocation = snapshot.data()!['deliveryLocation'];
        notifyListeners();
        order.contactNumber = snapshot.data()!['contactNumber'];
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
