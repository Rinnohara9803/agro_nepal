import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../services/apis/pdf_api.dart';
import '../services/apis/pdf_invoice_api.dart';
import '../services/shared_service.dart';

class PaymentDetailsPage extends StatelessWidget {
  static String routeName = '/paymentDetailsPage';
  const PaymentDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPdfDownloaded = false;

    final payment = ModalRoute.of(context)!.settings.arguments as Payment;

    TableRow buildRow(List<String> cells, bool isHeader) {
      return TableRow(
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(
            color: Colors.black,
          ),
        ),
        children: cells.map((cell) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              cell,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      );
    }

    List<TableRow> itemList = payment.products.map((product) {
      final total = product.price * product.quantity;
      return TableRow(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 236, 231, 231),
          ),
          children: [
            product.title,
            product.quantity.toString(),
            product.sellingUnit,
            product.price.toString(),
            total.toString(),
          ].map((cell) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 4,
                left: 4,
                right: 4,
                bottom: 4,
              ),
              child: Text(
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                cell,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }).toList());
    }).toList();

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.navigate_before,
                          ),
                        ),
                        const AutoSizeText(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final pdfFile = await PdfInvoiceApi.generate(
                              payment,
                            );
                            Share.shareFiles(
                              [pdfFile.path],
                            );
                          },
                          icon: const Icon(
                            Icons.share,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (isPdfDownloaded) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Are you Sure ?'),
                                      content: const Text(
                                        'Do you want to re-download the Pdf ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'No',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final pdfFile =
                                                await PdfInvoiceApi.generate(
                                              payment,
                                            );
                                            PdfApi.openFile(pdfFile);
                                            isPdfDownloaded = true;
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  });
                              return;
                            } else {
                              final pdfFile = await PdfInvoiceApi.generate(
                                payment,
                              );
                              PdfApi.openFile(pdfFile);
                              isPdfDownloaded = true;
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  payment.paidBy,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment.paidByEmail,
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invoice Number:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      payment.paymentId,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      payment.paymentToken,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invoice Date:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(DateFormat.yMd()
                        .add_jm()
                        .format(payment.paymentDateTime)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        children: [
                          buildRow(
                            [
                              'Product',
                              'Quantity',
                              'S.Unit',
                              'U.Price',
                              'Total'
                            ],
                            true,
                          ),
                        ],
                      ),
                      Table(
                        border: null,
                        children: itemList,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Spacer(
                            flex: 5,
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Net Total:',
                                    ),
                                    Text(
                                      'Rs. ${payment.amount}',
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'VAT Amount: ',
                                    ),
                                    Text(
                                      'Not included',
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      'Rs. ${payment.amount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Processed By: AgroNepal.Pvt.Ltd',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${payment.paidVia}: ${payment.paidViaContact}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
