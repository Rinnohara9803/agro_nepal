import 'package:agro_nepal/providers/cart.dart';
import 'package:agro_nepal/providers/product.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cartData = Provider.of<CartProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.white,
          context: context,
          builder: (context) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(
                            4,
                          ),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: const Icon(
                            Icons.close,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        product.productImageUrl,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  'Rs. ${product.price} ${product.sellingUnit}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            product.productDescription,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        cartData.addCartItem(
                          product.productId,
                          product.productName,
                          product.price,
                          product.productImageUrl,
                          product.sellingUnit,
                        );
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: ThemeClass.primaryColor,
                            content: const Text('Item added to the Cart'),
                            duration: const Duration(
                              milliseconds: 1500,
                            ),
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: Colors.amber,
                              onPressed: () {
                                cartData
                                    .removeSingleCartItem(product.productId);
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Add To Cart',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Stack(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PhysicalModel(
                      elevation: 3,
                      color: Colors.white,
                      shadowColor: Colors.grey,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        child: SizedBox(
                          height: constraints.maxHeight * 0.78,
                          width: double.infinity,
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            placeholder: const AssetImage(
                              'images/loadingImage.gif',
                            ),
                            image: NetworkImage(
                              product.productImageUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: -10,
                      child: Container(
                        padding: const EdgeInsets.all(
                          7,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Colors.grey,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: InkWell(
                          onTap: !product.isFavourite
                              ? () async {
                                  await product.addProductToFavourites(product);
                                }
                              : () async {
                                  await product.removeFromFavourites(
                                      product, context);
                                },
                          child: Icon(
                            product.isFavourite
                                ? Icons.favorite
                                : Icons.favorite_outline_rounded,
                            size: 18,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 0,
                      child: InkWell(
                        onTap: () {
                          cartData.addCartItem(
                            product.productId,
                            product.productName,
                            product.price,
                            product.productImageUrl,
                            product.sellingUnit,
                          );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: ThemeClass.primaryColor,
                              content: const Text('Item added to the Cart'),
                              duration: const Duration(
                                milliseconds: 1500,
                              ),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: Colors.amber,
                                onPressed: () {
                                  cartData
                                      .removeSingleCartItem(product.productId);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.5,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(
                                  0xffF49763,
                                ),
                                Color(
                                  0xffD23A3A,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                15,
                              ),
                              bottomRight: Radius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  product.productName,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rs. ${product.price} ${product.sellingUnit}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
