import 'dart:convert';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/data/firebase_consts.dart';
import 'package:fin/models/entry.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:flutter/material.dart';

class EntryTypeController with ChangeNotifier {
  final AuthData currentUserData;
  final List<EntryType> _entryTypeList;

  EntryTypeController(this.currentUserData, this._entryTypeList);

  List<EntryType> get entryTypeList => [..._entryTypeList];

  Future<CustomReturn> save({required EntryType entryType, bool forcedBySync = false}) async {
    if (entryType.id == '' || forcedBySync) {
      return _addEntryType(entryType: entryType, forcedBySync: forcedBySync);
    } else {
      return _updateEntryType(entryType: entryType, forcedBySync: forcedBySync);
    }
  }

  Future<CustomReturn> _updateEntryType({required EntryType entryType, bool forcedBySync = false}) async {
    int index = _entryTypeList.indexWhere((e) => e.id == entryType.id);

    if (index == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, produto não encontrado');
    }

    // http.patch
    final response = await patch(
      Uri.parse(
        '${FirebaseConsts.entryType}/${currentUserData.userId}/${entryType.id}.json?auth=${currentUserData.token}',
      ),
      body: jsonEncode({
        'type': entryType.type,
        'name': entryType.name,
        'colorValue': entryType.colorValue,
        'primaryClass': entryType.primaryClass,
        'secundaryClass': entryType.secundaryClass,
      }),
    );
    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      _entryTypeList[index] = entryType;
      return CustomReturn.sucess;
    }
  }

  Future<CustomReturn> _addEntryType({required EntryType entryType, bool forcedBySync = false}) async {
    if (_entryTypeList.where((element) => element.name == entryType.name).isNotEmpty) {
      return CustomReturn(returnType: ReturnType.error, message: 'Já existe um tipo de lançamento com este nome');
    }

    final response = await post(
      // http.post
      Uri.parse('${FirebaseConsts.entryType}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
      // Id fica em branco pois será gerado no banco
      body: jsonEncode({
        'id': entryType.id,
        'type': entryType.type,
        'name': entryType.name,
        'colorValue': entryType.colorValue,
        'primaryClass': entryType.primaryClass,
        'secundaryClass': entryType.secundaryClass,
      }),
    );
    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      String id = jsonDecode(response.body)['name'];
      if (id.isEmpty) {
        return CustomReturn(returnType: ReturnType.error, message: 'Erro interno ao tentar salvar.');
      } else {
        entryType.id = entryType.id == '' ? id : entryType.id;
        _entryTypeList.add(entryType);
        notifyListeners();
        return CustomReturn.sucess;
      }
    }
  }

  Future<CustomReturn> removeEntryType({required EntryType entryType}) async {
    return _removeEntryType(entryType: entryType, deleteAll: false);
  }

  Future<CustomReturn> clearEntryTypeBySync() async {
    return _removeEntryType(entryType: EntryType(), deleteAll: true);
  }

  Future<CustomReturn> _removeEntryType({required EntryType entryType, bool deleteAll = false}) async {
    if (!deleteAll && _entryTypeList.indexWhere((e) => e.id == entryType.id) == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, tipo de lançamento não encontrado');
    }

    String url = '${FirebaseConsts.entryType}/${currentUserData.userId}/${entryType.id}.json?auth=${currentUserData.token}';
    if (deleteAll) {
      url = '${FirebaseConsts.entryType}/${currentUserData.userId}.json?auth=${currentUserData.token}';
    }
    final response = await delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      if (deleteAll) {
        _entryTypeList.clear();
      } else {
        _entryTypeList.removeWhere((e) => e.id == entryType.id);
      }
      notifyListeners();
      return CustomReturn.sucess;
    }
  }

  Future<CustomReturn> loadEntryTypeList() async {
    // só deve fazer a requisição se estiver conectado
    final response = await get(
      Uri.parse('${FirebaseConsts.entryType}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
    );
    if (response.statusCode == 401) {
      return CustomReturn.unauthorizedError;
    } else {
      if (response.statusCode > 400) {
        return CustomReturn.httpError(errorCode: response.statusCode);
      } else {
        if (response.body == 'null') {
          return CustomReturn(returnType: ReturnType.error, message: 'Sem retorno do Firebase');
        } else {
          Map<String, dynamic> data = jsonDecode(response.body);
          _entryTypeList.clear();
          data.forEach((id, entryTypeData) {
            _entryTypeList.add(EntryType(
              id: id,
              type: entryTypeData['type'],
              name: entryTypeData['name'],
              colorValue: entryTypeData['colorValue'],
              primaryClass: entryTypeData['primaryClass'],
              secundaryClass: entryTypeData['secundaryClass'],
            ));
          });
          notifyListeners();
          return CustomReturn.sucess;
        }
      }
    }
  }

  Future<EntryType> entryTypeById({required String id}) async {
    EntryType entryType = EntryType();
    final response = await get(
      Uri.parse('${FirebaseConsts.entryType}/${currentUserData.userId}/$id.json?auth=${currentUserData.token}'),
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 401) {
      return entryType;
    } else {
      if (response.statusCode > 400) {
        return entryType;
      } else {
        entryType = EntryType(
          id: id,
          type: data['type'],
          name: data['name'],
          colorValue: data['colorValue'],
          primaryClass: data['primaryClass'],
          secundaryClass: data['secundaryClass'],
        );
      }
      return entryType;
    }
  }
}
