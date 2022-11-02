import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Product with ChangeNotifier {
  final String productId;
  final String productImageUrl;
  final String productName;
  final String productDescription;
  final String category;
  final String sellingUnit;
  final double price;
  bool isFavourite;

  Product({
    required this.productId,
    required this.productImageUrl,
    required this.productName,
    required this.productDescription,
    required this.category,
    required this.sellingUnit,
    required this.price,
    this.isFavourite = false,
  });

  Future<void> addProductToFavourites(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .set({'userProducts': 'userProducts'}).then((value) async {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(userUid)
            .collection('favourites')
            .doc(productId)
            .set({
          'productId': productId,
          'productName': productName,
          'productDescription': productDescription,
          'category': category,
          'sellingUnit': sellingUnit,
          'productImageUrl': productImageUrl,
          'price': price,
        });
      });
      isFavourite = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> removeFromFavourites(
      Product product, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .set({'userProducts': 'userProducts'}).then((value) {
        FirebaseFirestore.instance
            .collection('products')
            .doc('MQpzkaEzsZc7aUZ0lbds5v8suQB3')
            .collection('favourites')
            .doc(productId)
            .delete();
      });
      isFavourite = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
