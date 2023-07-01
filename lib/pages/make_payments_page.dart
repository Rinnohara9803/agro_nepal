import 'package:agro_nepal/utilities/themes.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../services/shared_service.dart';
import '../widgets/general_textformfield.dart';

class MakePaymentsPage extends StatefulWidget {
  static String routeName = '/makePaymentsPage';
  const MakePaymentsPage({Key? key}) : super(key: key);

  @override
  State<MakePaymentsPage> createState() => _MakePaymentsPageState();
}

class _MakePaymentsPageState extends State<MakePaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {   
      return;
    }
    _formKey.currentState!.save();
    SharedService.contactNumber = _contactController.text;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    String country = routeArgs['country'] as String;
    String administrativeArea = routeArgs['administrativeArea'] as String;
    String locality = routeArgs['locality'] as String;
    String subLocality = routeArgs['subLocality'] as String;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Continue Payment'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.bottom -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.primaryColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Country : ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      country,
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
                    const Text(
                      'Administrative-Area : ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      administrativeArea,
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
                    const Text(
                      'Locality : ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      locality,
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
                    const Text(
                      'Sub-Locality : ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subLocality,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GeneralTextFormField(
                        hasPrefixIcon: true,
                        hasSuffixIcon: false,
                        controller: _contactController,
                        label: 'Contact Number',
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please enter your contact number.';
                          } else if (value.trim().length != 10) {
                            return 'Enter valid phone number.';
                          }
                          return null;
                        },
                        textInputType: TextInputType.number,
                        iconData: Icons.call,
                        autoFocus: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.13,
                ),
                Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  child: InkWell(
                    onTap: () {
                      _saveForm();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: ThemeClass.primaryColor,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Center(
                        child: AutoSizeText(
                          'Continue to Payments',
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
          ),
        ),
      ),
    );
  }
}
