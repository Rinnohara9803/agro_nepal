import 'package:agro_nepal/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  List<Product> _favourites = [];

  List<Product> get favourites {
    return [..._favourites];
  }

  List<Product> _productByCategory = [];

  List<Product> get productByCategory {
    return [..._productByCategory];
  }

  Future<void> addProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .set({'userProducts': 'userProducts'}).then((value) {
        FirebaseFirestore.instance
            .collection('products')
            .doc(userUid)
            .collection('userProducts')
            .doc('product6')
            .set({
          'productId': 'Test test',
          'productName': 'Test six',
          'productDescription': 'Description',
          'category': 'Test1',
          'sellingUnit': 'Test1',
          'price': 200.0,
          'isFavourite': false,
        }).then((value) {
          print('Okay');
        }).catchError((e) {
          print(e);
        });
      });
    } on FirebaseException catch (e) {
      print(e);
      return Future.error(e.toString());
    } catch (e) {
      print(e);

      return Future.error(e.toString());
    }
  }

  Future<void> addProductToFavourites() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .set({'userProducts': 'userProducts'}).then((value) {
        FirebaseFirestore.instance
            .collection('products')
            .doc(userUid)
            .collection('favourites')
            .doc('product5')
            .set({
          'productId': 'Test test',
          'productName': 'Test nest',
          'productDescription': 'Description',
          'category': 'Test1',
          'sellingUnit': 'Test1',
          'price': 200.0,
        }).then((value) {
          print('Okay');
        }).catchError((e) {
          print(e);
        });
      });
    } on FirebaseException catch (e) {
      print(e);
      return Future.error(e.toString());
    } catch (e) {
      print(e);

      return Future.error(e.toString());
    }
  }

  Future<void> fetchUserProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      var collectionRef = FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('userProducts');

      await collectionRef.get().then((snapshot) {
        List<Product> _loadedProducts = [];
        for (var product in snapshot.docs) {
          print('here');
          print(product.data()['productName']);
        }
      });
    } on FirebaseException catch (e) {
      print(e);
      return Future.error(e.toString());
    } catch (e) {
      print(e);

      return Future.error(e.toString());
    }
  }

  Future<void> fetchUserFavourites() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      var collectionRef = FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('favourites');

      await collectionRef.get().then((snapshot) {
        List<Product> _loadedProducts = [];
        for (var product in snapshot.docs) {
          print('here');
          print(product.data()['productName']);
        }
      });
    } on FirebaseException catch (e) {
      print(e);
      return Future.error(e.toString());
    } catch (e) {
      print(e);

      return Future.error(e.toString());
    }
  }

  Future<void> fetchAllProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      var collectionRef = FirebaseFirestore.instance.collection('products');
      List<Product> _loadedProducts = [];
      List<Product> _userFavourites = [];
      List<Product> _loadedProductsByCategory = [];

      var favCollectionRef = FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('favourites');

      await favCollectionRef.get().then((snapshot) {
        for (var product in snapshot.docs) {
          _userFavourites.add(
            Product(
              productId: product.id,
              productName: product.data()['productName'],
              productDescription: product.data()['productDescription'],
              category: product.data()['category'],
              sellingUnit: product.data()['sellingUnit'],
              price: product.data()['price'],
              isFavourite: true,
            ),
          );
        }
      }).then((value) async {
        print(_userFavourites.length);

        await collectionRef.get().then((snapshot) async {
          for (var document in snapshot.docs) {
            var collectionRef = FirebaseFirestore.instance
                .collection('products')
                .doc(document.id)
                .collection('userProducts');

            await collectionRef
                .where('category', isEqualTo: 'Test2')
                .get()
                .then((snapshot) {
              for (var product in snapshot.docs) {
                print(product.id);
                final userFavourite = _userFavourites.firstWhere(
                  (favProduct) => favProduct.productId == product.id,
                  orElse: () => Product(
                    productId: 'productId',
                    productName: 'productName',
                    productDescription: 'productDescription',
                    category: 'category',
                    sellingUnit: 'sellingUnit',
                    price: 0,
                    isFavourite: false,
                  ),
                );

                _loadedProducts.add(
                  Product(
                    productId: product.id,
                    productName: product.data()['productName'],
                    productDescription: product.data()['productDescription'],
                    category: product.data()['category'],
                    sellingUnit: product.data()['sellingUnit'],
                    price: product.data()['price'],
                    isFavourite: userFavourite.isFavourite,
                  ),
                );
              }
            });
          }
        });
      });

      _products = _loadedProducts;
      notifyListeners();
      _favourites = _userFavourites;
      notifyListeners();
      print(_products.length);
      print(_favourites.length);
      _products.forEach((product) {
        print(product.isFavourite);
      });
    } on FirebaseException catch (e) {
      print(e);
      return Future.error(e.toString());
    } catch (e) {
      print(e);

      return Future.error(e.toString());
    }
  }
}
