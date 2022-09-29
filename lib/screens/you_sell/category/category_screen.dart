import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/controllers/category_controller.dart';
import 'package:fin/models/item_classification.dart';
import 'package:fin/routes.dart';
import 'package:fin/screens/you_sell/category/category_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = false;
  String _searchValue = '';
  List<Category> _categoryList = [];

  @override
  void initState() {
    super.initState();
    _reloadCategoryList();
  }

  void _reloadCategoryList() async {
    setState(() => _isLoading = true);
    try {
      CustomReturn retorno = await Provider.of<CategoryController>(context, listen: false).reloadCategoryList();
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

  @override
  Widget build(BuildContext context) {
    _categoryList = Provider.of<CategoryController>(context, listen: true).categoryList;
    if (_searchValue.isNotEmpty) {
      _categoryList = _categoryList.where((c) => c.name.toLowerCase().contains(_searchValue.toLowerCase())).toList();
    }
    return CustomScafold(
      title: 'Categorias',
      showAppDrawer: false,
      appBarActions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _reloadCategoryList,
          )
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  CustomTextEdit(
                    labelText: 'Pesquisar',
                    hintText: 'Pesquisar',
                    onChanged: _onChangeFilter,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: ListView.builder(
                      itemCount: _categoryList.length,
                      itemBuilder: (ctx, index) => Column(
                        children: [
                          CategoryCard(
                            category: _categoryList[index],
                            screenMode: CategoryCardScreenMode.form,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.categoryForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
