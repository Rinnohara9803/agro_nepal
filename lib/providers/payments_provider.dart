import 'package:agro_nepal/models/payment.dart';
import 'package:agro_nepal/providers/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../services/shared_service.dart';

class PaymentsProvider with ChangeNotifier {
  List<Payment> _payments = [];

  List<Payment> get payments {
    return [..._payments];
  }

  Future<void> addPayment(Payment payment) async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(payment.paymentId)
          .set({
        'paymentId': payment.paymentId,
        'userId': userUid,
        'paidBy': payment.paidBy,
        'paidByEmail': payment.paidByEmail,
        'paymentToken': payment.paymentToken,
        'paymentDateTime': payment.paymentDateTime.toIso8601String(),
        'amount': payment.amount,
        'paidVia': payment.paidVia,
        'paidViaContact': payment.paidViaContact,
        'products': payment.products.map(
          (cartItem) {
            return {
              'id': cartItem.id,
              'title': cartItem.title,
              'price': cartItem.price,
              'sellingUnit': cartItem.sellingUnit,
              'quantity': cartItem.quantity,
              'imageUrl': cartItem.imageUrl,
            };
          },
        ).toList(),
      }).then((value) {
        _payments.add(
          Payment(
            paymentId: payment.paymentId,
            userId: userUid,
            paidBy: payment.paidBy,
            paidByEmail: payment.paidByEmail,
            paymentToken: payment.paymentToken,
            paymentDateTime: payment.paymentDateTime,
            amount: payment.amount,
            paidVia: payment.paidVia,
            paidViaContact: payment.paidViaContact,
            products: payment.products,
          ),
        );
        notifyListeners();
      });
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchPayments() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userUid = user!.uid;
      await FirebaseFirestore.instance
          .collection('payments')
          .get()
          .then((snapshot) {
        List<Payment> loadedPayments = [];
        for (var payment in snapshot.docs) {
          loadedPayments.add(
            Payment(
              paymentId: payment.data()['paymentId'],
              paymentToken: payment.data()['paymentToken'],
              paidBy: payment.data()['paidBy'],
              paidByEmail: payment.data()['paidByEmail'],
              userId: payment.data()['userId'],
              amount: payment.data()['amount'],
              paidVia: payment.data()['paidVia'],
              paidViaContact: payment.data()['paidViaContact'],
              paymentDateTime:
                  DateTime.parse(payment.data()['paymentDateTime']),
              products: (payment.data()['products'] as List<dynamic>)
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
            ),
          );
          loadedPayments.sort(
            (a, b) {
              return DateTime.parse(b.paymentDateTime.toIso8601String())
                  .compareTo(
                DateTime.parse(
                  a.paymentDateTime.toIso8601String(),
                ),
              );
            },
          );
        }
        if (SharedService.isUserAdmin) {
          _payments = loadedPayments;
          notifyListeners();
        } else {
          _payments = loadedPayments
            .where((payment) => payment.userId == userUid)
            .toList();
        notifyListeners();
        }

        
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }
}
