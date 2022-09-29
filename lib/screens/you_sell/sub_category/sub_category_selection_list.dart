import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/screens/you_sell/sub_category/sub_category_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class SubCategorySelectionList extends StatelessWidget {
  final String categoryId;
  const SubCategorySelectionList({this.categoryId = '', Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SubCategoryController controller = Provider.of(context, listen: false);
    controller.reloadSubCategoryList(categoryId: categoryId);

    var subCategoryList = controller.subCategoryList.where((sc) => categoryId.isEmpty || sc.categoryId == categoryId).toList();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Column(
        children: [
          const Text('Toque na subcategoria desejada'),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: subCategoryList.length,
              itemBuilder: (ctx, index) => SubCategoryCard(
                subCategory: subCategoryList[index],
                screenMode: SubCategoryCardScreenMode.list,
              ),
            ),
          )
        ],
      ),
    );
  }
}
