import 'package:agro_nepal/providers/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  List<Product> _searchProducts = [];

  List<Product> get searchProducts {
    return [..._searchProducts];
  }

  List<Product> _favourites = [];

  List<Product> get favourites {
    return [..._favourites];
  }

  List<Product> _productsByCategory = [];

  List<Product> get productsByCategory {
    return [..._productsByCategory];
  }

  Future<void> addProduct(Product product) async {
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
            .doc(product.productId)
            .set({
          'productId': product.productId,
          'productImageUrl': product.productImageUrl,
          'productName': product.productName,
          'productDescription': product.productDescription,
          'category': product.category,
          'sellingUnit': product.sellingUnit,
          'price': product.price,
        });
      });
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('userProducts')
          .doc(id)
          .delete()
          .then((value) {
        _products.removeWhere((product) => product.productId == id);
        notifyListeners();
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> editProduct(Product product) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userUid = user!.uid;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('userProducts')
          .doc(product.productId)
          .update({
        'productId': product.productId,
        'productImageUrl': product.productImageUrl,
        'productName': product.productName,
        'productDescription': product.productDescription,
        'category': product.category,
        'sellingUnit': product.sellingUnit,
        'price': product.price,
      }).then((value) {
        int index = _products.indexWhere(
            (givenProduct) => givenProduct.productId == product.productId);
        _products[index] = product;
        notifyListeners();
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  // userProducts fetched via -fetchAllProducts...

  // Future<void> fetchUserProducts() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final userUid = user!.uid;

  //   try {
  //     var collectionRef = FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(userUid)
  //         .collection('userProducts');

  //     await collectionRef.get().then((snapshot) {
  //       List<Product> _loadedProducts = [];
  //       for (var product in snapshot.docs) {
  //         print('here');
  //         print(product.data()['productName']);
  //       }
  //     });
  //   } on FirebaseException catch (e) {
  //     return Future.error(e.toString());
  //   } catch (e) {

  //     return Future.error(e.toString());
  //   }
  // }

  // userFavourites fetched via -fetchAllProducts...

  // Future<void> fetchUserFavourites() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final userUid = user!.uid;

  //   try {
  //     var collectionRef = FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(userUid)
  //         .collection('favourites');

  //     await collectionRef.get().then((snapshot) {
  //       List<Product> _loadedProducts = [];
  //       for (var product in snapshot.docs) {
  //         _loadedProducts.add(
  //           Product(
  //             productId: product.data()['productId'],
  //             productImageUrl: product.data()['productImageUrl'],
  //             productName: product.data()['productName'],
  //             productDescription: product.data()['productDescription'],
  //             category: product.data()['category'],
  //             sellingUnit: product.data()['sellingUnit'],
  //             price: product.data()['price'],
  //             isFavourite: true,
  //           ),
  //         );
  //       }
  //       _favourites = _loadedProducts;
  //       notifyListeners();
  //     });
  //   } on FirebaseException catch (e) {
  //     print(e);
  //     return Future.error(e.toString());
  //   } catch (e) {
  //     print(e);

  //     return Future.error(e.toString());
  //   }
  // }

  Future<void> fetchAllProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    try {
      var collectionRef = FirebaseFirestore.instance.collection('products');
      List<Product> loadedProducts = [];
      List<Product> userFavourites = [];

      var favCollectionRef = FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('favourites');

      await favCollectionRef.get().then((snapshot) {
        for (var product in snapshot.docs) {
          userFavourites.add(
            Product(
              productId: product.id,
              productImageUrl: product.data()['productImageUrl'],
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
        await collectionRef.get().then((snapshot) async {
          for (var document in snapshot.docs) {
            var collectionRef = FirebaseFirestore.instance
                .collection('products')
                .doc(document.id)
                .collection('userProducts');

            await collectionRef
                // .where('category', isEqualTo: 'Test2')
                .get()
                .then((snapshot) {
              for (var product in snapshot.docs) {
                final userFavourite = userFavourites.firstWhere(
                  (favProduct) => favProduct.productId == product.id,
                  orElse: () => Product(
                    productId: 'productId',
                    productImageUrl: 'productImageUrl',
                    productName: 'productName',
                    productDescription: 'productDescription',
                    category: 'category',
                    sellingUnit: 'sellingUnit',
                    price: 0,
                    isFavourite: false,
                  ),
                );

                loadedProducts.add(
                  Product(
                    productId: product.id,
                    productImageUrl: product.data()['productImageUrl'],
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

      loadedProducts.sort(
        (a, b) {
          return DateTime.parse(b.productId).compareTo(
            DateTime.parse(
              a.productId,
            ),
          );
        },
      );

      _products = loadedProducts;
      notifyListeners();
      _favourites = userFavourites;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchSearchProducts(String productName) async {
    try {
      _searchProducts = products.where((product) {
        final productTitle = product.productName.toLowerCase();
        final searchInput = productName.toLowerCase();
        return productTitle.contains(searchInput);
      }).toList();
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user!.uid;

    var collectionRef = FirebaseFirestore.instance.collection('products');
    List<Product> loadedProducts = [];
    List<Product> userFavourites = [];

    try {
      var favCollectionRef = FirebaseFirestore.instance
          .collection('products')
          .doc(userUid)
          .collection('favourites');

      await favCollectionRef.get().then((snapshot) {
        for (var product in snapshot.docs) {
          userFavourites.add(
            Product(
              productId: product.id,
              productImageUrl: product.data()['productImageUrl'],
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
        await collectionRef.get().then((snapshot) async {
          for (var document in snapshot.docs) {
            var collectionRef = FirebaseFirestore.instance
                .collection('products')
                .doc(document.id)
                .collection('userProducts');

            await collectionRef
                .where('category', isEqualTo: category)
                .get()
                .then((snapshot) {
              for (var product in snapshot.docs) {
                final userFavourite = userFavourites.firstWhere(
                  (favProduct) => favProduct.productId == product.id,
                  orElse: () => Product(
                    productId: 'productId',
                    productImageUrl: 'productImageUrl',
                    productName: 'productName',
                    productDescription: 'productDescription',
                    category: 'category',
                    sellingUnit: 'sellingUnit',
                    price: 0,
                    isFavourite: false,
                  ),
                );

                loadedProducts.add(
                  Product(
                    productId: product.id,
                    productImageUrl: product.data()['productImageUrl'],
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

      _productsByCategory = loadedProducts;
      notifyListeners();
      _favourites = userFavourites;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
