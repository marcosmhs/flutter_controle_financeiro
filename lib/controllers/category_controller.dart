import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/uid_generator.dart';
import 'package:fin/models/item_classification.dart';
import 'package:fin/models/user.dart';
import 'package:flutter/material.dart';

class CategoryController with ChangeNotifier {
  final User currentUser;
  final List<Category> _categoryList;

  CategoryController(this.currentUser, this._categoryList);

  List<Category> get categoryList => [..._categoryList];

  Future<CustomReturn> save({required Category category}) async {
    if (category.id == '') {
      return _add(category: category);
    } else {
      return _update(category: category);
    }
  }

  Future<CustomReturn> _add({required Category category}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem cadastrar categorias',
      );
    }

    try {
      var categoryId = UidGenerator.firestoreUid;
      await FirebaseFirestore.instance.collection('category').doc(categoryId).set({
        'id': categoryId,
        'name': category.name,
        'iconCode': category.iconCode,
        'active': category.active,
      });
      category.id = categoryId;
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> _update({required Category category}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem cadastrar categorias',
      );
    }

    int index = _categoryList.indexWhere((e) => e.id == category.id);

    if (index == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, categoria não encontrado');
    }

    try {
      await FirebaseFirestore.instance.collection('category').doc(category.id).update({
        'id': category.id,
        'name': category.name,
        'iconCode': category.iconCode,
        'active': category.active,
      });
      _categoryList[index] = category;
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> remove({required String categoryId}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem remover categorias',
      );
    }

    if (_categoryList.indexWhere((e) => e.id == categoryId) == -1) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Erro interno, categoria não encontrado',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('category').doc(categoryId).delete();
      _categoryList.removeWhere((e) => e.id == categoryId);
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> reloadCategoryList() async {
    try {
      final categories = await FirebaseFirestore.instance.collection('category').get();
      final dataList = categories.docs.map((doc) => doc.data()).toList();

      _categoryList.clear();
      for (var category in dataList) {
        _categoryList.add(Category(
          id: category['id'],
          name: category['name'],
          active: category['active'],
          iconCode: category['iconCode'],
        ));
      }
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }
}
