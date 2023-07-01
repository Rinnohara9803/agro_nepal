import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../utilities/themes.dart';
import '../widgets/product_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  static String routeName = '/searchPage';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _productName = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                onChanged: (value) {},
                onFieldSubmitted: (value) {
                  setState(() {
                    _productName = value;
                  });
                },
              ),
              Expanded(
                child: _productName.isEmpty
                    ? const Center(
                        child: Text('Search for your products'),
                      )
                    : FutureBuilder(
                        future: Provider.of<ProductsProvider>(context,
                                listen: false)
                            .fetchSearchProducts(_productName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: ThemeClass.primaryColor,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Check your Internet Connection'),
                                  const Text('And'),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Consumer<ProductsProvider>(
                              builder: (ctx, productData, child) {
                                if (productData.searchProducts.isNotEmpty) {
                                  return SizedBox(
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
                                      itemCount:
                                          productData.searchProducts.length,
                                      itemBuilder: (context, index) {
                                        return ChangeNotifierProvider<
                                            Product>.value(
                                          value:
                                              productData.searchProducts[index],
                                          child: const ProductItem(),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Image(
                                        image: AssetImage(
                                          'images/scarecrow.png',
                                        ),
                                        height: 80,
                                        width: 80,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('No products found.')
                                    ],
                                  ));
                                }
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
