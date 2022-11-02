import 'package:agro_nepal/providers/orders_provider.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/order.dart';
import '../widgets/order_item.dart';

class OrdersPage extends StatefulWidget {
  static String routeName = '/ordersPage';
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    var timeFrame = '';
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
           backgroundColor: const Color.fromARGB(255, 4, 122, 83),
          title: const Text('My Orders'),
        ),
        body: FutureBuilder(
          future:
              Provider.of<OrdersProvider>(context, listen: false).fetchOrders(),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return Center(
            child: Column(
              children: [
                Text(
                  snapshot.error.toString(),
                ),
                const Text(
                  'and',
                ),
                TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Try again...'))
              ],
            ),
          );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    color: ThemeClass.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Consumer<OrdersProvider>(
                builder: (ctx, orderData, child) {
                  if (orderData.orders.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await orderData.fetchOrders().then((value) {
                          timeFrame = '';
                        });
                      },
                      child: ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) {
                          var orderTimeStamp = DateFormat.yMEd()
                              .format(orderData.orders[i].dateTime);
                          if (timeFrame != orderTimeStamp) {
                            timeFrame = orderTimeStamp;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 10,
                                    bottom: 0,
                                  ),
                                  child: AutoSizeText(
                                    orderTimeStamp,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: ThemeClass.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ChangeNotifierProvider<Order>.value(
                                  value: orderData.orders[i],
                                  child: const OrderItemm(),
                                ),
                              ],
                            );
                          }
                          return ChangeNotifierProvider<Order>.value(
                            value: orderData.orders[i],
                            child: const OrderItemm(),
                          );
                        },
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text('No orders placed.')
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Something went wrong.'),
              );
            }
          },
        ),
      ),
    );
  }
}
