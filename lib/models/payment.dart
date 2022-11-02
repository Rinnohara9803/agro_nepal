import '../providers/cart.dart';

class Payment {
  final String paymentId;
  final String userId;
  final String paidBy;
  final String paidByEmail;
  final String paymentToken;
  final DateTime paymentDateTime;
  final double amount;
  final String paidVia;
  final String paidViaContact;
  final List<CartItem> products;
  Payment({
    required this.paymentId,
    required this.userId,
    required this.paidBy,
    required this.paidByEmail,
     
    required this.paymentToken,
    required this.paymentDateTime,
    required this.amount,
    required this.paidVia,
    required this.paidViaContact,
    required this.products,
  });
}
