import 'package:agro_nepal/pages/search_page.dart';
import 'package:agro_nepal/providers/product.dart';
import 'package:agro_nepal/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../repositories/google_maps_repository.dart';
import '../widgets/product_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  void initState() {
    GoogleMapsRepository.determinePosition();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, SearchPage.routeName);
          },
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            margin: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              color: Colors.blueGrey.withOpacity(
                0.4,
              ),
            ),
            height: 40,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Search for products....'),
                Icon(
                  Icons.search,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Expanded(
          child: FutureBuilder(
            future: Provider.of<ProductsProvider>(context, listen: false)
                .fetchAllProducts(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
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
                                child: const ProductItem(),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            Text('No items found.')
                          ],
                        ),
                      );
                    }
                  },
                );
              }
            }),
          ),
        ),
      ],
    );
  }
}
