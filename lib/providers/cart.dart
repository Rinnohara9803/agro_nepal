import 'package:flutter/material.dart';

enum CartState {
  isAddedToCart,
  isRemovedFromcart,
}

class CartItem {
  final String id;
  final String title;
  final double price;
  final String sellingUnit;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.sellingUnit,
    required this.quantity,
    required this.imageUrl,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get cartItems {
    return {..._items};
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach(
      (key, value) {
        total += value.price * value.quantity;
      },
    );
    return double.parse(
      total.toStringAsFixed(2),
    );
  }

  int get itemCount {
    return _items.length;

    // int x = 0;
    // _items.forEach((key, value) {
    //   x += value.quantity;
    // });
    // return x;
  }

  void addCartItem(
      String productId, String title, double price, String imageUrl, String sellingUnit) async {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: double.parse(
            value.price.toStringAsFixed(2),
          ),
          sellingUnit: value.sellingUnit,
          quantity: value.quantity + 1,
          imageUrl: value.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          price: price,
          sellingUnit: sellingUnit,
          quantity: 1,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeCartItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  Future<void> editSingleCartItem(
    String productId,
    double price,
    int quantity,
  ) async {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items.containsKey(productId) && quantity > 0) {
      _items.update(
        productId,
        (value) => CartItem(
            id: value.id,
            title: value.title,
            price: price,
            sellingUnit: value.sellingUnit,
            quantity: quantity,
            imageUrl: value.imageUrl),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeSingleCartItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    } else if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          sellingUnit: value.sellingUnit,
          quantity: value.quantity - 1,
          imageUrl: value.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
