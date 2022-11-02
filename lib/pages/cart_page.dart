import 'package:agro_nepal/providers/orders_provider.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import 'package:agro_nepal/widgets/cart_item.dart' as ci;
import '../services/apis/notifications_api.dart';
import '../services/shared_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  static const routeName = '/cart_page';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context, listen: true);
    final orderData = Provider.of<OrdersProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(
                15,
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    const Spacer(),
                    Consumer<CartProvider>(
                      builder: (BuildContext context, value, Widget? child) {
                        return Chip(
                          label: Text(
                            'Rs. ${cartData.totalPrice}',
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    CheckOutButton(
                      cartData: cartData,
                      orderData: orderData,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: cartData.cartItems.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Image(
                          image: AssetImage(
                            'images/scarecrow.png',
                          ),
                          height: 80,
                          width: 80,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('You have no items in your Cart.')
                      ],
                    )
                  : ListView.builder(
                      itemCount: cartData.cartItems.length,
                      itemBuilder: (ctx, i) {
                        return ci.CartItem(
                          cartData.cartItems.values.toList()[i].id,
                          cartData.cartItems.keys.toList()[i],
                          cartData.cartItems.values.toList()[i].title,
                          cartData.cartItems.values.toList()[i].imageUrl,
                          cartData.cartItems.values.toList()[i].quantity,
                          cartData.cartItems.values.toList()[i].price,
                        );
                      },
                    ),
            ),
            if (cartData.cartItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cartData.clearCart();
                  },
                  child: const Text('Clear your Cart'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CheckOutButton extends StatefulWidget {
  const CheckOutButton({
    Key? key,
    required this.cartData,
    required this.orderData,
  }) : super(key: key);

  final CartProvider cartData;
  final OrdersProvider orderData;

  @override
  State<CheckOutButton> createState() => _CheckOutButtonState();
}

class _CheckOutButtonState extends State<CheckOutButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: SharedService.isUserAdmin
          ? null
          : widget.cartData.itemCount <= 0
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });
                  await widget.orderData
                      .addOrderItem(
                    widget.cartData.totalPrice,
                    widget.cartData.cartItems.values.toList(),
                  )
                      .then((value) async {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return Dialog(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 80,
                                  color: ThemeClass.primaryColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Your Order has been placed.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  'Check your orders for more details.',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).catchError(
                    (e) {
                      setState(() {
                        isLoading = false;
                      });
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('An error occurred!'),
                            content: const Text(
                              'Please check your Internet Connection.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Okay'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  setState(() {
                    isLoading = false;
                  });

                  widget.cartData.clearCart();
                  await Notifications.notifyAdmin(
                    'Order placed',
                    'Order placed by ${SharedService.userName}',
                  );
                },
      child: isLoading
          ? SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                color: ThemeClass.primaryColor,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Order Now',
            ),
    );
  }
}
