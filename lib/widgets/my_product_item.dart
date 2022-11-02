import 'package:agro_nepal/pages/edit_product_page.dart';
import 'package:agro_nepal/providers/cart.dart';
import 'package:agro_nepal/providers/product.dart';
import 'package:agro_nepal/providers/products_provider.dart';
import 'package:agro_nepal/utilities/snackbars.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProductItem extends StatefulWidget {
  const MyProductItem({Key? key}) : super(key: key);

  @override
  State<MyProductItem> createState() => _MyProductItemState();
}

class _MyProductItemState extends State<MyProductItem> {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          product.productName,
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
                      right: 48,
                      bottom: -10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            splashColor: Colors.red, // inkwell color
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Are you Sure?'),
                                    content: const Text(
                                      'Do you want to remove the product?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();

                                          await Provider.of<ProductsProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteProduct(product.productId)
                                              .then((value) {
                                            SnackBars.showNormalSnackbar(
                                                context,
                                                'Product deleted successfully!!!');
                                          }).catchError(
                                            (e) {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'An error occurred!'),
                                                    content: const Text(
                                                      'Something went wrong.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Okay'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: -10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        child: Material(
                          color: ThemeClass.primaryColor, // button color
                          child: InkWell(
                            splashColor: Colors.red, // inkwell color
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProductPage(
                                    product: product,
                                  ),
                                ),
                              );
                            },
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
