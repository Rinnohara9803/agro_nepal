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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const SplashPage(),
        routes: {
          SignUpPage.routeName: (context) => const SignUpPage(),
          SignInPage.routeName: (context) => const SignInPage(),
          VerifyEmailPage.routeName: (context) => const VerifyEmailPage(),
          DashboardPage.routeName: (context) => const DashboardPage(),
        },
      ),
    );
  }
}
