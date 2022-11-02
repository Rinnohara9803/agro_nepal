import 'dart:convert';
import 'package:agro_nepal/pages/add_product_page.dart';
import 'package:agro_nepal/pages/change_email_page.dart';
import 'package:agro_nepal/pages/change_password_page.dart';
import 'package:agro_nepal/pages/edit_product_page.dart';
import 'package:agro_nepal/pages/edit_profile_page.dart';
import 'package:agro_nepal/pages/favourites_page.dart';
import 'package:agro_nepal/pages/forgot_password_page.dart';
import 'package:agro_nepal/pages/khalti_payment_page.dart';
import 'package:agro_nepal/pages/my_payments_page.dart';
import 'package:agro_nepal/pages/my_products_page.dart';
import 'package:agro_nepal/pages/order_details_page.dart';
import 'package:agro_nepal/pages/orders_page.dart';
import 'package:agro_nepal/pages/payment_details_page.dart';
import 'package:agro_nepal/pages/productsby_category_page.dart';
import 'package:agro_nepal/pages/settings_page.dart';
import 'package:agro_nepal/providers/cart.dart';
import 'package:agro_nepal/providers/orders_provider.dart';
import 'package:agro_nepal/providers/payments_provider.dart';
import 'package:agro_nepal/providers/profile_provider.dart';
import 'package:agro_nepal/services/shared_service.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'package:agro_nepal/pages/dashboard_page.dart';
import 'package:agro_nepal/pages/sign_in_page.dart';
import 'package:agro_nepal/pages/sign_up_page.dart';
import 'package:agro_nepal/pages/verify_email_page.dart';
import 'package:agro_nepal/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'high_importance_notification',
  description: 'this channel is used for important notifications',
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!SharedService.isNotificationOn) {
    return;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductsProvider>(
          create: (context) => ProductsProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (ctx) => OrdersProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (ctx) => ProfileProvider(),
        ),
        ChangeNotifierProvider<PaymentsProvider>(
          create: (ctx) => PaymentsProvider(),
        ),
      ],
      child: KhaltiScope(
        publicKey: "test_public_key_838f3eccb49044dda55c4b505a94bc51",
        builder: (context, navigatorKey) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: const [
              KhaltiLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              fontFamily: 'Lato',
              primaryColor: Colors.green,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: ThemeClass.primaryColor,
              ),
            ),
            home: const SplashPage(),
            routes: {
              SignUpPage.routeName: (context) => const SignUpPage(),
              SignInPage.routeName: (context) => const SignInPage(),
              VerifyEmailPage.routeName: (context) => const VerifyEmailPage(),
              DashboardPage.routeName: (context) => const DashboardPage(),
              AddProductPage.routeName: (context) => const AddProductPage(),
              FavouritesPage.routeName: (context) => const FavouritesPage(),
              OrdersPage.routeName: (context) => const OrdersPage(),
              MyProductsPage.routeName: (context) => const MyProductsPage(),
              ForgotPasswordPage.routeName: (context) =>
                  const ForgotPasswordPage(),
              SettingsPage.routeName: (context) => const SettingsPage(),
              ChangePasswordPage.routeName: (context) =>
                  const ChangePasswordPage(),
              ChangeEmailPage.routeName: (context) => const ChangeEmailPage(),
              EditProductPage.routeName: (context) => const EditProfilePage(),
              OrderDetailsPage.routeName: (context) => const OrderDetailsPage(),
              // SetLocationPage.routeName: (context) => const SetLocationPage(),
              KhaltiPaymentPage.routeName: (context) =>
                  const KhaltiPaymentPage(),
              MyPaymentsPage.routeName: (context) => const MyPaymentsPage(),
              PaymentDetailsPage.routeName: (context) =>
                  const PaymentDetailsPage(),
              ProductsByCategoryPage.routeName: (context) =>
                  const ProductsByCategoryPage(),
            },
          );
        },
      ),
    );
  }
}

int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token, String title, String body) {
  _messageCount++;
  return jsonEncode({
    'to': token,
    'priority': 'high',
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': title,
      'body': body,
    },
  });
}
