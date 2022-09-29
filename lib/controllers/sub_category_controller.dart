import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/uid_generator.dart';
import 'package:fin/controllers/category_controller.dart';
import 'package:fin/models/item_classification.dart';
import 'package:fin/models/user.dart';
import 'package:flutter/material.dart';

class SubCategoryController with ChangeNotifier {
  final User currentUser;
  final List<SubCategory> _subCategoryList;

  SubCategoryController(this.currentUser, this._subCategoryList);

  List<SubCategory> get subCategoryList => [..._subCategoryList];

  Future<CustomReturn> save({required SubCategory subCategory}) async {
    if (subCategory.id == '') {
      return _add(subCategory: subCategory);
    } else {
      return _update(subCategory: subCategory);
    }
  }

  Future<CustomReturn> _add({required SubCategory subCategory}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem cadastrar subcategorias',
      );
    }

    try {
      var subCategoryId = UidGenerator.firestoreUid;
      await FirebaseFirestore.instance.collection('subCategory').doc(subCategoryId).set({
        'id': subCategoryId,
        'name': subCategory.name,
        'categoryId': subCategory.categoryId,
        'iconCode': subCategory.iconCode,
        'active': subCategory.active,
      });
      subCategory.id = subCategoryId;
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> _update({required SubCategory subCategory}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem cadastrar categorias',
      );
    }

    int index = _subCategoryList.indexWhere((e) => e.id == subCategory.id);

    if (index == -1) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Erro interno, categoria não encontrado',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('subCategory').doc(subCategory.id).update(
            subCategory.toMap(),
          );
      _subCategoryList[index] = subCategory;
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> remove({required String subCategoryId}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem remover categorias',
      );
    }

    if (_subCategoryList.indexWhere((e) => e.id == subCategoryId) == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, categoria não encontrado');
    }

    try {
      await FirebaseFirestore.instance.collection('category').doc(subCategoryId).delete();
      _subCategoryList.removeWhere((e) => e.id == subCategoryId);
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> reloadSubCategoryList({String categoryId = ''}) async {
    try {
      final categories = await FirebaseFirestore.instance.collection('subCategory').get();
      final dataList = categories.docs.map((doc) => doc.data()).toList();

      var categoryController = CategoryController(currentUser, []);
      await categoryController.reloadCategoryList();

      _subCategoryList.clear();
      for (var subCategory in dataList) {
        _subCategoryList.add(SubCategory(
          id: subCategory['id'],
          name: subCategory['name'],
          categoryId: subCategory['categoryId'],
          active: subCategory['active'],
          iconCode: subCategory['iconCode'],
          category: categoryController.categoryList.firstWhere((c) => c.id == subCategory['categoryId']),
        ));
      }
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  List<SubCategory> subCategoryListByCategoryId({required String categoryId}) {
    return _subCategoryList.where((s) => s.categoryId == categoryId).toList();
  }
}
