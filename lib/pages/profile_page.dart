import 'package:agro_nepal/pages/sign_in_page.dart';
import 'package:agro_nepal/providers/products_provider.dart';
import 'package:agro_nepal/utilities/snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static String routeName = '/profilePage';
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    Provider.of<ProductsProvider>(context, listen: false).fetchAllProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              await Provider.of<ProductsProvider>(context, listen: false)
                  .addProductToFavourites()
                  .then((value) {
                SnackBars.showNormalSnackbar(context, 'added');
              }).catchError((e) {
                SnackBars.showErrorSnackBar(context, e.toString());
              });
            },
            child: const Text(
              'Add to favourites',
            ),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<ProductsProvider>(context, listen: false)
                  .addProduct()
                  .then((value) {
                SnackBars.showNormalSnackbar(context, 'Okay');
              }).catchError((e) {
                SnackBars.showErrorSnackBar(context, e.toString());
              });
            },
            child: const Text(
              'Add product',
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(
                    context, SignInPage.routeName, (route) => false);
              });
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
