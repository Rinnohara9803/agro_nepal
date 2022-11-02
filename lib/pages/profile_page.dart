import 'package:agro_nepal/pages/add_product_page.dart';
import 'package:agro_nepal/pages/edit_product_page.dart';
import 'package:agro_nepal/pages/favourites_page.dart';
import 'package:agro_nepal/pages/my_products_page.dart';
import 'package:agro_nepal/pages/orders_page.dart';
import 'package:agro_nepal/pages/settings_page.dart';
import 'package:agro_nepal/pages/sign_in_page.dart';
import 'package:agro_nepal/providers/cart.dart';
import 'package:agro_nepal/services/shared_service.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/apis/notifications_api.dart';
import '../widgets/profile_widget.dart';
import '../widgets/top_profile_screen_widget.dart';
import 'my_payments_page.dart';

class ProfilePage extends StatefulWidget {
  static String routeName = '/profilePage';
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final sizeQuery = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(
            top: sizeQuery.height * 0.22,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (SharedService.isUserAdmin == true)
                  ProfileWidgets(
                    text: 'Add Product',
                    iconData: Icons.add_card,
                    onTap: () async {
                      Navigator.pushNamed(context, AddProductPage.routeName);
                    },
                  ),
                if (SharedService.isUserAdmin == true)
                  ProfileWidgets(
                    text: 'My Products',
                    iconData: Icons.agriculture_outlined,
                    onTap: () async {
                      Navigator.pushNamed(context, MyProductsPage.routeName);
                    },
                  ),
                ProfileWidgets(
                  text: 'My Orders',
                  iconData: Icons.book,
                  onTap: () {
                    Navigator.pushNamed(context, OrdersPage.routeName);
                  },
                ),
                ProfileWidgets(
                  text: 'My Payments',
                  iconData: Icons.payment,
                  onTap: () {
                    Navigator.pushNamed(context, MyPaymentsPage.routeName);
                  },
                ),
                ProfileWidgets(
                  text: 'Favourites',
                  iconData: Icons.favorite_outline,
                  onTap: () {
                    Navigator.pushNamed(context, FavouritesPage.routeName);
                  },
                ),
                ProfileWidgets(
                  text: 'Settings',
                  iconData: Icons.settings,
                  onTap: () {
                    Navigator.pushNamed(context, SettingsPage.routeName);
                  },
                ),
                ProfileWidgets(
                  text: 'Log Out',
                  iconData: Icons.logout,
                  onTap: () async {
                    final userId = FirebaseAuth.instance.currentUser!.uid;

                    await Notifications.deleteToken(userId).then((value) {
                      FirebaseAuth.instance.signOut().then((value) {
                        Provider.of<CartProvider>(context, listen: false)
                            .clearCart();
                        SharedService.isUserAdmin = false;
                        Navigator.pushNamedAndRemoveUntil(
                            context, SignInPage.routeName, (route) => false);
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        TopProfileScreenWidget(sizeQuery: sizeQuery),
        Positioned(
          top: sizeQuery.height * 0.111,
          right: sizeQuery.width * 0.07,
          child: FloatingActionButton(
            backgroundColor: ThemeClass.primaryColor,
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditProductPage.routeName,
              );
            },
            child: const Icon(
              Icons.edit,
            ),
          ),
        ),
      ],
    );
  }
}
