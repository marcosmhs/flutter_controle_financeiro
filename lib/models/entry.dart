import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EntryType {
  String id;
  String type;
  String name;
  String primaryClass;
  String secundaryClass;
  int colorValue;

  static Map<String, IconData> icons = {
    etBoth: Icons.money_outlined,
    etIncome: Icons.monetization_on_outlined,
    etExpense: Icons.remove
  };

  static IconData get iconBoth {
    return EntryType.icons[EntryType.etBoth]!;
  }

  static IconData get iconExpense {
    return EntryType.icons[EntryType.etExpense]!;
  }

  static IconData get iconIncome {
    return EntryType.icons[EntryType.etIncome]!;
  }

  static String etBoth = 'Ambos';
  static String etIncome = 'Receita';
  static String etExpense = 'Despesa';

  EntryType({
    this.id = '',
    this.type = 'Ambos',
    this.name = '',
    this.primaryClass = '',
    this.colorValue = 0,
    this.secundaryClass = '',
  });

  IconData? get icon {
    return icons[type];
  }
}

class Entry {
  String id;
  String description;
  String entryExpenseIncome;
  EntryType? entryType;
  double value;
  DateTime? date;
  DateTime? expiratioDate;
  List<EntryPayment>? entryPaymentList;

  Entry({
    this.id = '',
    this.description = '',
    this.entryType,
    this.entryExpenseIncome = '',
    this.value = 0,
    this.date,
    this.expiratioDate,
    this.entryPaymentList,
  });

  double get payedValue {
    if (entryPaymentList == null) {
      return 0;
    } else {
      return entryPaymentList!.fold(0, (total, entry) => total + entry.value);
    }
  }

  DateTime? get lastPaymentDate {
    if (entryPaymentList == null) {
      return null;
    }
    return entryPaymentList!.reduce((item1, item2) => item1.date.isAfter(item2.date) ? item1 : item2).date;
  }

  String get situationText {
    if (expiratioDate != null) {
      if (payedValue == value) {
        return 'Paga em ${DateFormat('dd/MM/yyyy').format(lastPaymentDate!)}';
      } else {
        if (expiratioDate! == DateTime.now()) {
          return 'Vence hoje (${DateFormat('dd/MM/yyyy').format(expiratioDate!)})!';
        }
        if (expiratioDate!.isBefore(DateTime.now())) {
          return 'Vencida desde ${DateFormat('dd/MM/yyyy').format(expiratioDate!)}';
        }
        if (expiratioDate!.isAfter(DateTime.now())) {
          return 'Vence em ${DateFormat('dd/MM/yyyy').format(expiratioDate!)}';
        }
      }
    }
    return '';
  }

  bool get expired {
    return (
        // possui uma data de vencimento
        expiratioDate != null &&
            // esta data é anterior a data atual
            expiratioDate!.isBefore(DateTime.now()) &&
            payedValue != value);
  }
}

class EntryPayment {
  String id;
  String entryId;
  double value;
  DateTime date;

  EntryPayment({
    this.id = '',
    required this.entryId,
    required this.value,
    required this.date,
  });
}
