import 'dart:async';

import 'package:agro_nepal/providers/payments_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esewa_pnp/esewa.dart';
import 'package:esewa_pnp/esewa_pnp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment.dart';
import '../models/user.dart';
import '../providers/order.dart';
import '../services/apis/notifications_api.dart';
import '../services/shared_service.dart';
import '../utilities/snackbars.dart';
import '../utilities/themes.dart';

class OrderDetailsPage extends StatefulWidget {
  static String routeName = '/orderDetailsPage';
  const OrderDetailsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 4, 122, 83),
          title: const Text(
            'Order Details',
          ),
        ),
        body: ChangeNotifierProvider<Order>.value(
          value: order,
          child: OrderDetailWidget(theOrder: order),
        ),
      ),
    );
  }
}

class OrderDetailWidget extends StatefulWidget {
  const OrderDetailWidget({Key? key, required this.theOrder}) : super(key: key);
  final Order theOrder;

  @override
  State<OrderDetailWidget> createState() => _OrderDetailWidgetState();
}

class _OrderDetailWidgetState extends State<OrderDetailWidget> {
  List<Map<String, Object>> paymentMethods = [
    {
      'gateway': 'Khalti',
      'color': Colors.purple,
    },
    {
      'gateway': 'E-sewa',
      'color': Colors.green,
    },
  ];

  _initEsewaPayment(Order order) async {
    ESewaConfiguration configuration = ESewaConfiguration(
      clientID: 'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R',
      secretKey: 'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==',
      environment: ESewaConfiguration.ENVIRONMENT_TEST,
    );

    ESewaPnp esewaPnp = ESewaPnp(configuration: configuration);

    ESewaPayment payment = ESewaPayment(
      amount: 400,
      productName: order.orderId,
      productID: order.orderId,
      callBackURL: 'http://exmaple.com/',
    );
    try {
      await esewaPnp.initPayment(payment: payment).then((value) async {
        await order
            .changePOStatus(
          'Paid',
          'Processing',
        )
            .then((value) {
          SnackBars.showNormalSnackbar(context, 'Payment successful!!!');
        });
      });
    } on ESewaPaymentException catch (e) {
      SnackBars.showErrorSnackBar(
        context,
        e.toString(),
      );
    }
  }

  _initKhaltiPayment(Order order) async {
    await KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: order.amount.toInt() * 100,
        productIdentity: order.orderId,
        productName: order.userId,

        // for static purpose
        // mobile: '9841937556',
        // mobileReadOnly: true,
      ),
      preferences: [
        PaymentPreference.khalti,
        PaymentPreference.connectIPS,
      ],
      onSuccess: (su) async {
        print(su);
        var timeStamp = DateTime.now().toIso8601String();
        // Navigator.of(context).pop();
        order
            .changePOStatus(
          'Paid',
          'Processing',
        )
            .then((value) {
          Provider.of<PaymentsProvider>(context, listen: false)
              .addPayment(
            Payment(
              paymentId: timeStamp,
              userId: FirebaseAuth.instance.currentUser!.uid,
              paidBy: SharedService.userName,
              paidByEmail: SharedService.email,
              paymentToken: su.token,
              paymentDateTime: DateTime.parse(timeStamp),
              amount: order.amount,
              paidVia: 'Khalti',
              paidViaContact: su.mobile,
              products: order.products,
            ),
          )
              .then((value) {
            SnackBars.showNormalSnackbar(context, 'Payment successful!!!');
          });
        });
        await Notifications.notifyAdmin('Payment completed',
            'Payment completed for Order No. ${order.orderId} by ${SharedService.userName}');
      },
      onFailure: (fa) {
        SnackBars.showErrorSnackBar(context, 'Payment failed!!!');
      },
      onCancel: () {
        SnackBars.showErrorSnackBar(context, 'Payment cancelled!!!');
      },
    );
  }

  _launchPhoneURL(String phoneNumber) async {
    String url = 'tel: $phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      await Provider.of<Order>(context, listen: false).fetchOrderById();
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = Provider.of<Order>(context);

    

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.bottom -
          MediaQuery.of(context).padding.top,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order No:  ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                order.orderId,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DateTime: ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: ThemeClass.primaryColor,
                ),
              ),
              Text(
                DateFormat.yMd().add_jm().format(order.dateTime),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          if (SharedService.isUserAdmin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ordered By: ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: ThemeClass.primaryColor,
                ),
              ),
              Text(
                order.orderedBy,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Status: ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                order.paymentStatus,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Status:   ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                order.deliveryStatus,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Time:    ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                order.deliveryTime,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount: ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                'Rs. ${order.amount.toString()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: order.products.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(
                      8,
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        height: 60,
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          child: Image(
                            image: NetworkImage(
                              order.products[index].imageUrl,
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              order.products[index].title,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '( Rs. ${order.products[index].price} )',
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Total: Rs. ${(order.products[index].price * order.products[index].quantity).toStringAsFixed(1)}',
                      ),
                      trailing: Text('${order.products[index].quantity} X'),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          if (SharedService.isUserAdmin &&
              order.paymentStatus == 'Paid' &&
              order.deliveryStatus == 'Delivered')
            const SizedBox(
              height: 5,
              width: double.infinity,
            ),
          if (SharedService.isUserAdmin && order.deliveryStatus != 'Delivered')
            Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(
                10,
              ),
              child: InkWell(
                onTap: order.paymentStatus != 'Paid'
                    ? null
                    : () async {
                        await order
                            .changePOStatus(
                          'Paid',
                          'Delivered',
                        )
                            .then((value) async {
                          List<TheUser> users = [];
                          String userName = '';
                          String token = '';
                          await FirebaseFirestore.instance
                              .collection('users')
                              .get()
                              .then((snapshot) {
                            for (var user in snapshot.docs) {
                              users.add(
                                TheUser(
                                  userId: user.data()['userId'],
                                  isAdmin: user.data()['tag'],
                                  userName: user.data()['userName'],
                                ),
                              );
                            }
                          }).then((value) async {
                            TheUser user = users.firstWhere(
                                (user) => user.userId == order.userId);
                            await FirebaseFirestore.instance
                                .collection('userTokens')
                                .doc(user.userId)
                                .get()
                                .then((snapshot) {
                              token = snapshot.data()!['token'];
                              userName = user.userName;
                            });
                          }).then((value) async {
                            await Notifications.sendPushMessage(
                              token,
                              'Order Delivered',
                              'Order No. ${order.orderId} delivered successfully to $userName',
                            );
                          });

                          // ignore: use_build_context_synchronously
                          SnackBars.showNormalSnackbar(
                              context, 'Order Delivered successfully!!!');
                        }).catchError((e) {
                          SnackBars.showErrorSnackBar(
                            context,
                            e.toString(),
                          );
                        });
                      },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: order.paymentStatus != 'Paid'
                        ? Colors.grey
                        : ThemeClass.primaryColor,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Center(
                    child: AutoSizeText(
                      'Change Delivery Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!SharedService.isUserAdmin &&
              order.paymentStatus == 'Paid' &&
              order.deliveryStatus != 'Booked')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deliveryStatus == 'Delivered'
                          ? 'Order delivered.'
                          : 'Your orders will arrive shortly.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'For more details, Call customer support.',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                FloatingActionButton.small(
                  heroTag: 'Call',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _launchPhoneURL('9808880359');
                  },
                  child: const Icon(
                    Icons.phone,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            )
          else if (!SharedService.isUserAdmin && order.paymentStatus != 'Paid')
            Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(
                10,
              ),
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isDismissible: true,
                    enableDrag: true,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(
                          12,
                        ),
                        height: 170,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.payment,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                AutoSizeText(
                                  'Choose Payment Method ',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                children: paymentMethods.map(
                                  (paymentMethod) {
                                    final payment =
                                        paymentMethod['gateway'] as String;
                                    return Expanded(
                                      child: Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary:
                                                paymentMethod['color'] as Color,
                                          ),
                                          child: Text('$payment Payment'),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            if (payment == 'Khalti') {
                                              await _initKhaltiPayment(order);
                                            } else {
                                              await _initEsewaPayment(order);
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeClass.primaryColor,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Center(
                    child: AutoSizeText(
                      'Check Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
