import 'dart:io';
import 'package:agro_nepal/services/apis/pdf_api.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../models/payment.dart';
import '../shared_service.dart';

class PdfInvoiceApi {
  static Future<File> generate(Payment payment) async {
    final pdf = Document();

    final agroNepalImage =
        (await rootBundle.load('images/planting.png')).buffer.asUint8List();

    pdf.addPage(
      MultiPage(
        build: (context) => [
          buildTitle(
            payment,
            agroNepalImage,
          ),
          buildInvoice(payment),
          Divider(),
          buildTotal(payment),
          buildBottom(payment),
        ],
      ),
    );

    return PdfApi.saveDocument(name: '${payment.paymentId}.pdf', pdf: pdf);
  }

  static Widget buildTitle(Payment payment, dynamic agroNepalImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Invoice',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            Image(
              MemoryImage(
                agroNepalImage,
              ),
              width: 100,
              height: 100,
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          SharedService.userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          SharedService.email,
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
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
        SizedBox(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
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
        SizedBox(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Invoice Date:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat.yMEd().format(
                payment.paymentDateTime,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  static Widget buildInvoice(Payment payment) {
    final headers = [
      'Product',
      'Quantity',
      'Selling Unit',
      'Unit Price',
      'Total'
    ];

    final data = payment.products.map((product) {
      final total = product.price * product.quantity;
      return [
        product.title,
        product.quantity.toString(),
        product.sellingUnit,
        'Rs. ${product.price}',
        total,
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headerDecoration: const BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Payment payment) {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(children: [
        Spacer(
          flex: 6,
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Total:',
                  ),
                  Text(
                    'Rs. ${payment.amount}',
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VAT Amount: ',
                  ),
                  Text(
                    'Not included',
                  ),
                ],
              ),
              Divider(
                color: PdfColors.black,
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                  Text(
                    'Rs. ${payment.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  static Widget buildBottom(Payment payment) {
    return Column(children: [
      SizedBox(
        height: 10,
      ),
      Divider(
        color: PdfColors.black,
        thickness: 1,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Processed By: AgroNepal.Pvt.Ltd',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 2,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${payment.paidVia}: ${payment.paidViaContact}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    ]);
  }
}
