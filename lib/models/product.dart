class Product {
  final String productId;
  final String productName;
  final String productDescription;
  final String category;
  final String sellingUnit;
  final double price;
  bool isFavourite;

  Product({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.category,
    required this.sellingUnit,
    required this.price,
    this.isFavourite = false,
  });
}
