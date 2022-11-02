import 'package:agro_nepal/providers/orders_provider.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/order.dart';
import '../pages/order_details_page.dart';
import '../services/shared_service.dart';

class OrderItemm extends StatefulWidget {
  const OrderItemm({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderItemm> createState() => _OrderItemmState();
}

class _OrderItemmState extends State<OrderItemm> {
  bool isLoading = false;
  bool isExpanded = false;

  Future<void> deleteOrder(Order order) async {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Are you Sure?'),
          content: const Text(
            'Do you want to remove the order?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                });
                await Provider.of<OrdersProvider>(context, listen: false)
                    .deleteOrder(order.orderId)
                    .then((value) {
                  setState(() {
                    isLoading = false;
                  });
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
                            'Something went wrong.',
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
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = Provider.of<Order>(context, listen: true);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, OrderDetailsPage.routeName,
              arguments: order,);
        },
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Order No.',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                order.orderId.toString(),
              ),
              trailing: order.deliveryStatus == 'Processing'
                  ? const Icon(
                      Icons.hourglass_top_outlined,
                      color: Colors.greenAccent,
                    )
                  : order.deliveryStatus == 'Delivered'
                      ? const Icon(
                          Icons.done,
                          color: Colors.green,
                        )
                      : IconButton(
                          color: Colors.red.withOpacity(0.6),
                          onPressed: SharedService.isUserAdmin ? null : () async {
                            await deleteOrder(order);
                          },
                          icon: isLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.redAccent,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.delete,
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
