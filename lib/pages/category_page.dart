import 'package:agro_nepal/models/category.dart';
import 'package:agro_nepal/widgets/circular_progress_indicator.dart';
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
      print(
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: fetchCategories(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ProgressIndicator1();
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: categories
                  .map((category) => Column(
                        children: [
                          Text(category.categoryImageUrl),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          );
        }
      }),
    );
  }
}
