import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../widgets/my_product_item.dart';

class MyProductsPage extends StatefulWidget {
  static String routeName = '/myProductsPage';
  const MyProductsPage({Key? key}) : super(key: key);

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 4, 122, 83),
          title: const Text(
            'My Products',
          ),
        ),
        body: FutureBuilder(
          future: Provider.of<ProductsProvider>(context, listen: false)
              .fetchAllProducts(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    period: const Duration(
                      milliseconds: 1500,
                    ),
                    baseColor: Colors.blueGrey,
                    highlightColor: Colors.white,
                    direction: ShimmerDirection.ltr,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Column(
                        children: [
                          Flexible(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(
                                  10,
                                ),
                                topLeft: Radius.circular(
                                  10,
                                ),
                              ),
                              child: Container(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(
                                  10,
                                ),
                                bottomLeft: Radius.circular(
                                  10,
                                ),
                              ),
                              child: Container(
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      snapshot.error.toString(),
                    ),
                    const Text(
                      'and',
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Try again...'))
                  ],
                ),
              );
            } else {
              return Consumer<ProductsProvider>(
                builder: (ctx, productData, child) {
                  if (productData.products.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await productData.fetchAllProducts();
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 20,
                            crossAxisCount: 2,
                            childAspectRatio: 10 / 15,
                          ),
                          itemCount: productData.products.length,
                          itemBuilder: (context, index) {
                            return ChangeNotifierProvider<Product>.value(
                              value: productData.products[index],
                              child: const MyProductItem(),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No Items Found.',
                      ),
                    );
                  }
                },
              );
            }
          }),
        ),
      ),
    );
  }
}
