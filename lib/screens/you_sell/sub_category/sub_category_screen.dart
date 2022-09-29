import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/controllers/category_controller.dart';
//import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/models/item_classification.dart';
import 'package:fin/routes.dart';
import 'package:fin/screens/you_sell/category/category_card.dart';
import 'package:fin/screens/you_sell/category/category_selection_list.dart';
import 'package:fin/screens/you_sell/sub_category/sub_category_card.dart';
//import 'package:fin/screens/you_sell/sub_category/sub_category_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({Key? key}) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  bool _isLoading = false;
  String _searchValue = '';
  List<SubCategory> _subCategoryList = [];
  Category _category = Category();

  @override
  void initState() {
    super.initState();
    _reloadSubCategoryList();
    if (Provider.of<CategoryController>(context, listen: false).categoryList.isEmpty) {
      Provider.of<CategoryController>(context, listen: false).reloadCategoryList();
    }
  }

  void _reloadSubCategoryList() async {
    setState(() => _isLoading = true);
    try {
      CustomReturn retorno = await Provider.of<SubCategoryController>(context, listen: false).reloadSubCategoryList();
      if (retorno.returnType == ReturnType.error) {
        CustomMessage(context: context, messageText: retorno.message, messageType: MessageType.error);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onChangeFilter(String? value) {
    if (value != null && value.isNotEmpty) {
      _searchValue = value;
      setState(() {});
    }
  }

  Widget _categorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
              alignment: Alignment.center,
              child: _category.id.isEmpty
                  ? CategoryCard(
                      category: _category,
                      screenMode: CategoryCardScreenMode.showItem,
                      cropped: true,
                    ).emptyCard(context)
                  : CategoryCard(
                      category: _category,
                      screenMode: CategoryCardScreenMode.showItem,
                      cropped: true,
                    ),
            ),
            onTap: () async {
              showModalBottomSheet<Category>(
                context: context,
                isDismissible: true,
                builder: (context) => const CategorySelectionList(),
              ).then((category) {
                if (category != null) {
                  setState(() => _category = category);
                  _syncSubCategoryList();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void _syncSubCategoryList() {
    setState(() {
      if (_category.id.isNotEmpty) {
        _subCategoryList = Provider.of<SubCategoryController>(context, listen: true).subCategoryList;
        _subCategoryList = _subCategoryList.where((sc) => sc.categoryId == _category.id).toList();
        _subCategoryList = _subCategoryList.where((sc) => sc.name.toLowerCase().contains(_searchValue.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _syncSubCategoryList();
    return CustomScafold(
      title: 'SubCategorias',
      showAppDrawer: false,
      appBarActions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _reloadSubCategoryList,
          )
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _categorySelection(),
                  CustomTextEdit(
                    labelText: 'Pesquisar',
                    hintText: 'Pesquisar',
                    onChanged: _onChangeFilter,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.73,
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _subCategoryList.length,
                      itemBuilder: (ctx, idx) => SubCategoryCard(
                        subCategory: _subCategoryList[idx],
                        screenMode: SubCategoryCardScreenMode.form,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.subCategoryForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
