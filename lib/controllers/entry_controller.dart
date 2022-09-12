import 'dart:convert';
import 'dart:core';

import 'package:fin/components/util/custom_dropbox.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/controllers/entrytype_controller.dart';
import 'package:fin/data/firebase_consts.dart';
import 'package:fin/models/entry.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EntryController with ChangeNotifier {
  final AuthData currentUserData;
  final List<Entry> _entryList;
  final List<EntryPayment> _entryPaymentList = [];

  EntryController(this.currentUserData, this._entryList);

  List<Entry> get entryList => [..._entryList];
  //List<EntryPayment> get entryPaymentList => [..._entryPaymentList];

  // Entry Geters

  double totalEntryValue({String monthYear = ''}) {
    if (monthYear == '') {
      return _entryList.fold(0, (total, entry) => total + entry.value);
    } else {
      return _entryList
          .where((e) =>
              (e.expiratioDate == null && DateFormat('MM/yyyy').format(e.date!) == monthYear) ||
              (e.expiratioDate != null && DateFormat('MM/yyyy').format(e.expiratioDate!) == monthYear))
          .fold(0, (total, e) => total + (e.entryExpenseIncome == EntryType.etExpense ? (e.value) * -1 : e.value));
    }
  }

  double totalIncomeValue({String monthYear = ''}) {
    if (monthYear == '') {
      return _entryList
          .where((entry) => entry.entryExpenseIncome == EntryType.etIncome)
          .fold(0, (total, entry) => total + entry.value);
    } else {
      return _entryList
          .where((e) =>
              e.entryExpenseIncome == EntryType.etIncome &&
              ((e.expiratioDate == null && DateFormat('MM/yyyy').format(e.date!) == monthYear) ||
                  (e.expiratioDate != null && DateFormat('MM/yyyy').format(e.expiratioDate!) == monthYear)))
          .fold(0, (total, entry) => total + entry.value);
    }
  }

  double totalExpenseValue({String monthYear = ''}) {
    if (monthYear == '') {
      return _entryList
          .where((entry) => entry.entryExpenseIncome == EntryType.etExpense)
          .fold(0, (total, entry) => total + entry.value);
    } else {
      return _entryList
          .where((e) =>
              e.entryExpenseIncome == EntryType.etExpense &&
              ((e.expiratioDate == null && DateFormat('MM/yyyy').format(e.date!) == monthYear) ||
                  (e.expiratioDate != null && DateFormat('MM/yyyy').format(e.expiratioDate!) == monthYear)))
          .fold(0, (total, entry) => total + entry.value);
    }
  }

  List<Entry> entryListByDate({String monthYear = ''}) {
    if (monthYear == '') {
      return [..._entryList];
    } else {
      return [
        ..._entryList.where((entry) =>
            (entry.expiratioDate == null && DateFormat('MM/yyyy').format(entry.date!) == monthYear) ||
            (entry.expiratioDate != null && DateFormat('MM/yyyy').format(entry.expiratioDate!) == monthYear))
      ];
    }
  }

  List<CustomDropBoxData> get periodListData {
    List<CustomDropBoxData> data = [];
    Intl.defaultLocale = 'pt_BR';

    // organiza a lista para as datas sejam exibidas do maior para o menor
    _entryList.sort((a, b) => b.date!.compareTo(a.date!));

    data.add(
      CustomDropBoxData(
        id: DateFormat('MM/yyyy').format(DateTime.now()),
        displayValue: DateFormat('MMMM/yyyy').format(DateTime.now()),
        icon: Icons.calendar_month,
      ),
    );

    DateTime date;
    for (var entry in _entryList) {
      date = entry.expiratioDate == null ? entry.date! : entry.expiratioDate!;

      if (DateFormat('MMMM/yyyy').format(date) != DateFormat('MMMM/yyyy').format(DateTime.now())) {
        if (data.where((d) => d.displayValue == DateFormat('MMMM/yyyy').format(date)).isEmpty) {
          data.add(
            CustomDropBoxData(
              id: DateFormat('MM/yyyy').format(date),
              displayValue: DateFormat('MMMM/yyyy').format(date),
              icon: Icons.calendar_month,
            ),
          );
        }
      }
    }

    return data;
  }

  // Entry CRUD

  Future<CustomReturn> save({required Entry entry}) async {
    if (entry.entryType == null) {
      return CustomReturn(returnType: ReturnType.error, message: 'Tipo de lançamento não informado');
    }
    if (entry.id == '') {
      return _addEntry(entry: entry);
    } else {
      return _updateEntry(entry: entry);
    }
  }

  Future<CustomReturn> _updateEntry({required Entry entry}) async {
    int index = _entryList.indexWhere((e) => e.id == entry.id);

    if (index == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, lançamento não encontrado');
    }

    // http.patch
    final response = await patch(
      Uri.parse(
        '${FirebaseConsts.entry}/${currentUserData.userId}/${entry.id}.json?auth=${currentUserData.token}',
      ),
      body: jsonEncode({
        'description': entry.description,
        'entryExpenseIncome': entry.entryExpenseIncome,
        'value': entry.value,
        'date': entry.date?.toIso8601String(),
        'expiratioDate': entry.expiratioDate?.toIso8601String(),
        'entryTypeID': entry.entryType!.id,
      }),
    );
    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      _entryList[index] = entry;
      // retorna à todos os que estão ouvindo esta classe sejam notificados
      notifyListeners();
    }
    return CustomReturn.sucess;
  }

  Future<CustomReturn> _addEntry({required Entry entry}) async {
    int installmentQuantity = 1;
    String entryInstallmentId = '';
    double value = entry.value;
    DateTime? expiratioDate = entry.expiratioDate;
    // toda adição de pagamentos depende de um parcelamento.
    // se o usuário criou um lançamento simples será gerada apenas uma parcela
    // se ele informou parcelas será criada a tabela de controle de parcelas e ela será vinculada ao lançamento.
    if (entry.entryInstallment != null && entry.entryInstallment!.installmentQuantity >= 2) {
      var result = await _addEntryInstallment(entryInstallment: entry.entryInstallment!);
      CustomReturn customReturn = result.first as CustomReturn;
      if (customReturn.returnType == ReturnType.sucess) {
        EntryInstallment entryInstallment = result.last as EntryInstallment;
        installmentQuantity = entryInstallment.installmentQuantity;
        entryInstallmentId = entryInstallment.id;
        value = value / installmentQuantity;
      }
    }

    for (var x = 1; x <= installmentQuantity; x++) {
      expiratioDate = expiratioDate?.add(Duration(days: 30 * x - 1));
      final response = await post(
        // http.post
        Uri.parse('${FirebaseConsts.entry}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
        // Id fica em branco pois será gerado no banco
        body: jsonEncode({
          'description': '${entry.description} ${installmentQuantity == 1 ? '' : "$x / $installmentQuantity"}',
          'entryExpenseIncome': entry.entryExpenseIncome,
          'value': value,
          'date': entry.date?.toIso8601String(),
          'expiratioDate': expiratioDate?.toIso8601String(),
          'entryTypeId': entry.entryType!.id,
          'entryInstallmentId': entryInstallmentId,
        }),
      );

      if (response.statusCode >= 400) {
        return CustomReturn.httpError(errorCode: response.statusCode);
      } else {
        String id = jsonDecode(response.body)['name'];
        if (id.isEmpty) {
          return CustomReturn(returnType: ReturnType.error, message: 'Erro interno ao tentar salvar.');
        } else {
          entry.id = id;
          _entryList.add(entry);
          notifyListeners();
        }
      }
    }

    return CustomReturn.sucess;
  }

  Future<CustomReturn> removeEntry({required Entry entry}) async {
    if (_entryList.indexWhere((e) => e.id == entry.id) == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, lançamento não encontrado');
    }

    if ((await entryPaymentList(entryId: entry.id)).isNotEmpty) {
      return CustomReturn(returnType: ReturnType.error, message: 'Este lançamento possui pagamentos e não pode ser excluído');
    }

    final response = await delete(
      // http.delete
      Uri.parse('${FirebaseConsts.entry}/${currentUserData.userId}/${entry.id}.json?auth=${currentUserData.token}'),
    );

    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      _entryList.removeWhere((e) => e.id == entry.id);
      loadEntryList();
      // retorna à todos os que estão ouvindo esta classe sejam notificados
      notifyListeners();
    }
    return CustomReturn.sucess;
  }

  Future<CustomReturn> loadEntryList() async {
    final response = await get(
      Uri.parse('${FirebaseConsts.entry}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
    );

    if (response.body == 'null') {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro ao obter lançamentos');
    } else {
      if (response.statusCode == 401) {
        return CustomReturn.unauthorizedError;
      } else {
        if (response.statusCode > 400) {
          return CustomReturn.httpError(errorCode: response.statusCode);
        } else {
          Map<String, dynamic> data = jsonDecode(response.body);
          _entryList.clear();
          EntryTypeController entryTypeController = EntryTypeController(currentUserData, []);
          await entryTypeController.loadEntryTypeList();
          await loadEntryListPayment();

          for (var entryData in data.entries) {
            var entry = Entry(
              id: entryData.key,
              description: entryData.value['description'],
              entryExpenseIncome: entryData.value['entryExpenseIncome'],
              value: double.tryParse(entryData.value['value'].toString()) ?? 0,
              date: DateTime.parse(entryData.value['date']),
              expiratioDate:
                  entryData.value['expiratioDate'] == null ? null : DateTime.tryParse(entryData.value['expiratioDate']),
              entryType: entryTypeController.entryTypeList.singleWhere((e) => e.id == entryData.value['entryTypeId']),
              entryPaymentList: _entryPaymentList.where((e) => e.entryId == entryData.key).toList(),
            );

            _entryList.add(entry);
          }

          notifyListeners();
          return CustomReturn.sucess;
        }
      }
    }
  }

  Future<Set<dynamic>> _addEntryInstallment({required EntryInstallment entryInstallment}) async {
    CustomReturn customReturn = CustomReturn.sucess;
    final response = await post(
      // http.post
      Uri.parse('${FirebaseConsts.entryInstallment}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
      // Id fica em branco pois será gerado no banco
      body: jsonEncode({
        'installmentQuantity': entryInstallment.installmentQuantity,
        'date': entryInstallment.date?.toIso8601String(),
      }),
    );

    if (response.statusCode >= 400) {
      customReturn = CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      String id = jsonDecode(response.body)['name'];
      if (id.isEmpty) {
        customReturn = CustomReturn(returnType: ReturnType.error, message: 'Erro interno ao tentar salvar.');
      } else {
        entryInstallment.id = id;
      }
    }

    return {customReturn, entryInstallment};
  }

  // Entry Payment

  Future<CustomReturn> registerPayment({required EntryPayment entryPayment}) async {
    final response = await post(
      // http.post
      Uri.parse('${FirebaseConsts.entryPayment}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
      // Id fica em branco pois será gerado no banco
      body: jsonEncode({
        'date': entryPayment.date.toIso8601String(),
        'entryId': entryPayment.entryId,
        'value': entryPayment.value.toString(),
      }),
    );

    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    }

    String id = jsonDecode(response.body)['name'];
    if (id.isEmpty) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno ao tentar salvar.');
    }

    notifyListeners();
    return CustomReturn.sucess;
  }

  Future<CustomReturn> removeEntryPayment({required EntryPayment entryPayment}) async {
    if (_entryPaymentList.indexWhere((e) => e.id == entryPayment.id) == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, pagamento não encontrado');
    }

    final response = await delete(
      // http.delete
      Uri.parse('${FirebaseConsts.entryPayment}/${currentUserData.userId}/${entryPayment.id}.json?auth=${currentUserData.token}'),
    );

    if (response.statusCode >= 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    } else {
      _entryPaymentList.removeWhere((e) => e.id == entryPayment.id);
      // retorna à todos os que estão ouvindo esta classe sejam notificados
      notifyListeners();
    }
    return CustomReturn.sucess;
  }

  Future<CustomReturn> loadEntryListPayment() async {
    final response = await get(
      Uri.parse('${FirebaseConsts.entryPayment}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
    );
    if (response.body == 'null') {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro ao obter pagamentos');
    }
    if (response.statusCode == 401) {
      return CustomReturn.unauthorizedError;
    }
    if (response.statusCode > 400) {
      return CustomReturn.httpError(errorCode: response.statusCode);
    }

    Map<String, dynamic> data = jsonDecode(response.body);
    _entryPaymentList.clear();
    for (var entryPaymentData in data.entries) {
      var entryPayment = EntryPayment(
        id: entryPaymentData.key,
        entryId: entryPaymentData.value['entryId'],
        value: double.tryParse(entryPaymentData.value['value'].toString()) ?? 0,
        date: DateTime.parse(entryPaymentData.value['date']),
      );
      _entryPaymentList.add(entryPayment);
    }
    return CustomReturn.sucess;
  }

  Future<List<EntryPayment>> entryPaymentList({required String entryId}) async {
    await loadEntryListPayment();
    return _entryPaymentList.where((e) => e.entryId == entryId).toList();
  }
}
