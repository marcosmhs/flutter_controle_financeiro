import 'package:fin/controllers/category_controller.dart';
import 'package:fin/screens/you_sell/category/category_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class CategorySelectionList extends StatelessWidget {
  const CategorySelectionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CategoryController controller = Provider.of(context, listen: false);
    controller.reloadCategoryList();
    var categoryList = controller.categoryList;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Column(
        children: [
          const Text('Toque na categoria desejada'),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: categoryList.length,
              itemBuilder: (ctx, index) => CategoryCard(
                category: categoryList[index],
                screenMode: CategoryCardScreenMode.list,
              ),
            ),
          )
        ],
      ),
    );
  }
}
