import 'package:agro_nepal/pages/payment_details_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/payments_provider.dart';
import '../utilities/themes.dart';

class MyPaymentsPage extends StatefulWidget {
  static String routeName = '/myPaymentsPage';
  const MyPaymentsPage({Key? key}) : super(key: key);

  @override
  State<MyPaymentsPage> createState() => _MyPaymentsPageState();
}

class _MyPaymentsPageState extends State<MyPaymentsPage> {
  @override
  Widget build(BuildContext context) {
    var timeFrame = '';
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 4, 122, 83),
          title: const Text('My Payments'),
        ),
        body: FutureBuilder(
          future: Provider.of<PaymentsProvider>(context, listen: false)
              .fetchPayments(),
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
              return Consumer<PaymentsProvider>(
                builder: (ctx, paymentData, child) {
                  if (paymentData.payments.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await paymentData.fetchPayments().then((value) {
                          timeFrame = '';
                        });
                      },
                      child: ListView.builder(
                        itemCount: paymentData.payments.length,
                        itemBuilder: (ctx, i) {
                          var orderTimeStamp = DateFormat.yMEd()
                              .format(paymentData.payments[i].paymentDateTime);
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 8,
                                    bottom: 0,
                                  ),
                                  child: Card(
                                    child: ListTile(
                                      title: const Text(
                                        'Payment Token',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      subtitle: Text(
                                        paymentData.payments[i].paymentToken,
                                      ),
                                      trailing: TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            PaymentDetailsPage.routeName,
                                            arguments: paymentData.payments[i],
                                          );
                                        },
                                        child: const Text(
                                          'View Details',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 8,
                              bottom: 0,
                            ),
                            child: Card(
                              child: ListTile(
                                title: const Text(
                                  'Payment Token',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  paymentData.payments[i].paymentToken,
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      PaymentDetailsPage.routeName,
                                      arguments: paymentData.payments[i],
                                    );
                                  },
                                  child: const Text(
                                    'View Details',
                                  ),
                                ),
                              ),
                            ),
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
                        Text('No payments till Date.')
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
