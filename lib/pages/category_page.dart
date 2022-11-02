import 'package:agro_nepal/models/category.dart';
import 'package:agro_nepal/pages/productsby_category_page.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with AutomaticKeepAliveClientMixin<CategoryPage> {
  @override
  bool get wantKeepAlive => true;

  List<Category> categories = [];
  Future fetchCategories() async {
    try {
      var categoriesRef = FirebaseFirestore.instance.collection('categories');
      await categoriesRef.get().then((snapshot) {
        for (var category in snapshot.docs) {
          categories.add(Category(category.data()['categoryName'],
              category.data()['categoryImage']));
        }
      });
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 122, 83),
        leading: Container(),
        title: const Text(
          'Categories',
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchCategories(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 2.0,
                ),
              ),
            );
          } else {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, ProductsByCategoryPage.routeName, arguments: categories[index].categoryName,);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    height: MediaQuery.of(context).size.height * 0.14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      border: Border.all(
                        color: Colors.black,
                      ),
                      color: ThemeClass.primaryColor,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Image(
                            image:
                                NetworkImage(categories[index].categoryImageUrl),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            categories[index].categoryName,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }),
      ),
    );
  }
}
