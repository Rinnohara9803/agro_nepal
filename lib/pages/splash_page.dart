import 'dart:async';
import 'dart:io';
import 'package:agro_nepal/pages/dashboard_page.dart';
import 'package:agro_nepal/pages/sign_in_page.dart';
import 'package:agro_nepal/pages/verify_email_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () {
      fetchUser();
    });
    super.initState();
  }

  Future fetchUser() async {
    // ignore: unrelated_type_equality_checks
    if (FirebaseAuth.instance.authStateChanges().isEmpty == true) {
      Navigator.pushNamed(context, SignInPage.routeName);
    } else {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      print(user);

      if (user?.emailVerified == false) {
        Navigator.pushNamed(context, VerifyEmailPage.routeName);
        return;
      } else {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get()
              .then(
            (data) {
              Navigator.pushNamed(context, DashboardPage.routeName);
            },
          );
        } on SocketException catch (_) {
          Navigator.pushNamed(context, SignInPage.routeName);
        } catch (e) {
          Navigator.pushNamed(context, SignInPage.routeName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple.withOpacity(
          0.7,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/planting.png',
                height: 150,
                width: 150,
              ),
              const AutoSizeText(
                'mhicha',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                  fontFamily: 'Lato',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
