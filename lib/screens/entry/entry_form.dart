//import 'package:fin/components/fin_modalscafold.dart';
import 'package:fin/components/fin_scafold.dart';
import 'package:fin/components/util/custom_datetimeselector.dart';
import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/entry_controller.dart';
import 'package:fin/controllers/entrytype_controller.dart';
import 'package:fin/models/entry.dart';
import 'package:fin/screens/entrytype/entrytype_card.dart';
import 'package:fin/screens/entrytype/entrytype_selectionlist.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EntryForm extends StatefulWidget {
  final Entry? entry;
  final bool showInstallment;
  const EntryForm({Key? key, this.entry, this.showInstallment = false}) : super(key: key);

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> with SingleTickerProviderStateMixin {
  Entry localEntry = Entry(
    date: DateTime.now(),
    entryInstallment: EntryInstallment(
      date: DateTime.now(),
      installmentQuantity: 1,
    ),
  );
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _entryDescriptionController = TextEditingController();
  final TextEditingController _entryValueController = TextEditingController();
  final FocusNode _entryValueFocus = FocusNode();
  List<bool> _selectedIncomeExpense = [false, false];
  List<EntryPayment> _entryPaymentList = [];

  String _entryDateErrorMessage = '';
  String _entryExpirationDateErrorMessage = '';
  bool _entryTypeError = false;
  bool _incomeExpenseError = false;

  @override
  void initState() {
    super.initState();
    localEntry = widget.entry ?? localEntry;
    _entryDescriptionController.text = localEntry.description;
    _entryValueController.text = localEntry.value == 0 ? '' : localEntry.value.toString();
    _entryTypeError = false;
    _incomeExpenseError = false;
  }

  void _submit() async {
    if (localEntry.entryType == null) {
      setState(() => _entryTypeError = true);
      CustomMessage(
        modelType: ModelType.toast,
        context: context,
        messageText: 'O tipo de lançamento deve ser informado',
        messageType: MessageType.error,
      );
    }

    if (localEntry.entryExpenseIncome == '') {
      setState(() => _incomeExpenseError = true);
      CustomMessage(
        modelType: ModelType.toast,
        context: context,
        messageText: 'Informe se este lançamento é uma Receita ou Despesa',
        messageType: MessageType.error,
      );
    }

    _entryDateErrorMessage = '';
    if (localEntry.date == null) {
      _entryDateErrorMessage = 'Informe a data do lançamento';
    }

    _entryExpirationDateErrorMessage = '';
    if (localEntry.expiratioDate != null && localEntry.expiratioDate!.isBefore(localEntry.date!)) {
      _entryExpirationDateErrorMessage = 'A data de vencimento deve ser posterior a data atual';
    }

    setState(() => _isLoading = true);
    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      try {
        // salva os dados
        _formKey.currentState?.save();
        EntryController entryController = Provider.of(context, listen: false);
        CustomReturn retorno;

        retorno = await entryController.save(entry: localEntry);
        if (retorno.returnType == ReturnType.sucess) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(true);
          CustomMessage(
            context: context,
            messageText: 'Lançamento criado com sucesso',
            messageType: MessageType.sucess,
          );
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          CustomMessage(
            context: context,
            messageText: retorno.message,
            messageType: MessageType.error,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeEntry() async {
    bool? deletedConfirmed = false;
    deletedConfirmed = await CustomDialog(context: context).confirmationDialog(
      message: 'Confirma a exclusão do lançamento. Esta ação não pode ser desfeita?',
    );
    if (deletedConfirmed!) {
      setState(() => _isLoading = true);
      try {
        if (localEntry.payedValue != 0) {
          CustomMessage(
            modelType: ModelType.toast,
            context: context,
            messageText: 'Este lançamento possui pagamentos.',
            messageType: MessageType.error,
          );
        } else {
          // ignore: use_build_context_synchronously
          EntryController entryController = Provider.of(context, listen: false);
          CustomReturn retorno;

          retorno = await entryController.removeEntry(entry: localEntry);

          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(true);
            CustomMessage(
              context: context,
              modelType: ModelType.toast,
              messageText: 'Lançamento excluído',
              messageType: MessageType.sucess,
            );
          }

          if (retorno.returnType == ReturnType.error) {
            CustomMessage(
              context: context,
              modelType: ModelType.toast,
              messageText: retorno.message,
              messageType: MessageType.error,
            );
          }
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _entryTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
              decoration: _entryTypeError ? BoxDecoration(border: Border.all(color: Theme.of(context).errorColor)) : null,
              alignment: Alignment.center,
              child: localEntry.entryType == null
                  ? EntryTypeCard(entryType: EntryType(), screenMode: ScreenMode.showItem).emptyCard(context)
                  : EntryTypeCard(
                      entryType: localEntry.entryType!,
                      screenMode: ScreenMode.showItem,
                      cropped: true,
                    ),
            ),
            onTap: () async {
              _selectedIncomeExpense = [false, false];
              var entryType = await showModalBottomSheet<EntryType>(
                context: context,
                isDismissible: true,
                builder: (context) => const EntryTypeSelectionList(),
              );
              if (entryType != null) {
                setState(() {
                  _entryTypeError = false;
                  localEntry.entryType = entryType;
                  localEntry.entryExpenseIncome = entryType.type == EntryType.etBoth ? '' : entryType.type;
                });
              }
            },
          ),
          if (localEntry.entryType != null && localEntry.entryType!.type == EntryType.etBoth)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                decoration: _incomeExpenseError ? BoxDecoration(border: Border.all(color: Theme.of(context).errorColor)) : null,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'O tipo de lançamento indica que podem ser lançados receitas e despesas. Qual você quer utilizar agora?',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: Center(
                          child: ToggleButtons(
                            isSelected: _selectedIncomeExpense,
                            fillColor: localEntry.entryType?.colorValue == null
                                ? Theme.of(context).primaryColor
                                : Color(localEntry.entryType?.colorValue ?? 0),
                            selectedColor: Colors.black,
                            onPressed: (index) {
                              setState(() {
                                _incomeExpenseError = false;
                                if (index == 0) {
                                  localEntry.entryExpenseIncome = EntryType.etIncome;
                                } else {
                                  localEntry.entryExpenseIncome = EntryType.etExpense;
                                }
                                _selectedIncomeExpense = [index == 0, index == 1];
                              });
                            },
                            children: [
                              SizedBox(
                                width: 115,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(EntryType.iconIncome),
                                    const SizedBox(width: 5),
                                    Text(EntryType.etIncome),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 115,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(EntryType.iconExpense),
                                    const SizedBox(width: 5),
                                    Text(EntryType.etExpense),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _loadEntryPaymentList({required String entryId}) async {
    _entryPaymentList = await Provider.of<EntryController>(context, listen: false).entryPaymentList(entryId: entryId);
  }

  Widget _paymentCard(EntryPayment entryPayment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Card(
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          title: Text(DateFormat('dd/MM/yyyy').format(entryPayment.date)),
          subtitle: Text('R\$ ${entryPayment.value.toStringAsFixed(2)}'),
          trailing: IconButton(
            onPressed: () async {
              bool? deletedConfirmed = false;
              deletedConfirmed = await CustomDialog(context: context).confirmationDialog(
                message: 'Confirma a exclusão do pagamento?. Esta ação não pode ser desfeita!',
              );
              if (deletedConfirmed!) {
                // ignore: use_build_context_synchronously
                EntryController entryController = Provider.of(context, listen: false);
                CustomReturn retorno;

                retorno = await entryController.removeEntryPayment(entryPayment: entryPayment);

                if (retorno.returnType == ReturnType.sucess) {
                  // ignore: use_build_context_synchronously
                  _loadEntryPaymentList(entryId: widget.entry!.id);
                  CustomMessage(
                    context: context,
                    modelType: ModelType.toast,
                    messageText: 'Pagamento excluído',
                    messageType: MessageType.sucess,
                  );
                }

                if (retorno.returnType == ReturnType.error) {
                  CustomMessage(
                    modelType: ModelType.toast,
                    context: context,
                    messageText: retorno.message,
                    messageType: MessageType.error,
                  );
                }
              }
            },
            icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
          ),
        ),
      ),
    );
  }

  Widget _installmentCard(int installment) {
    double value = localEntry.value != 0 ? localEntry.value : double.tryParse(_entryValueController.text) ?? 0;
    if (localEntry.entryInstallment != null) {
      if (localEntry.entryInstallment!.installmentQuantity != 0) {
        value = (value / localEntry.entryInstallment!.installmentQuantity);
      }
    }

    DateTime? expiratioDate = localEntry.expiratioDate;

    if (expiratioDate != null) {
      expiratioDate = expiratioDate.add(Duration(days: 30 * (installment - 1)));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Parcela $installment - ${expiratioDate == null ? "" : DateFormat('dd/MM/yyyy').format(expiratioDate)}'),
              Text('R\$ ${value.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<EntryTypeController>(context).loadEntryTypeList();
    if (widget.entry != null && widget.entry!.payedValue != 0) {
      _loadEntryPaymentList(entryId: widget.entry!.id);
    }
    return FinScafold(
      title: widget.entry != null && widget.entry!.id != '' ? 'Alterar' : 'Novo lançamento',
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _entryTypeSelection(),
                // descrição
                CustomTextEdit(
                  labelText: 'Descrição',
                  hintText: 'Descrição',
                  controller: _entryDescriptionController,
                  onSave: (value) => localEntry.description = value ?? '',
                  validator: ((value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) {
                      return 'Informe a descrição';
                    }
                    return null;
                  }),
                ),
                // valor
                CustomTextEdit(
                  labelText: 'Valor',
                  hintText: 'Valor',
                  controller: _entryValueController,
                  keyboardType: TextInputType.number,
                  focusNode: _entryValueFocus,
                  onSave: (value) => localEntry.value = double.parse(value ?? '0'),
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) {
                      return 'Informe o valor do lançamento';
                    } else if (double.tryParse(finalValue) == null) {
                      return 'O valor informado não é um número válido';
                    }
                    return null;
                  },
                ),
                // data
                CustomDateTimeSelector(
                  context: context,
                  displayName: 'Data',
                  buttonText: 'Selecionar Data',
                  initialDate: localEntry.date,
                  onOpenDateSelector: () => setState(() => _entryDateErrorMessage = ''),
                  errorMessage: _entryDateErrorMessage,
                  onSelected: (value) => localEntry.date = value,
                ),
                // data de vencimento
                CustomDateTimeSelector(
                  context: context,
                  displayName: 'Data de vencimento',
                  buttonText: 'Selecionar',
                  onOpenDateSelector: () => setState(() => _entryExpirationDateErrorMessage = ''),
                  errorMessage: _entryExpirationDateErrorMessage,
                  initialDate: localEntry.expiratioDate,
                  onSelected: (value) => localEntry.expiratioDate = value,
                ),
                // opções de parcelamento
                if (widget.showInstallment)
                  Column(
                    children: [
                      CustomTextEdit(
                        context: context,
                        labelText: 'Parcelas',
                        hintText: 'Número de parcelas',
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            setState(() => localEntry.entryInstallment!.installmentQuantity = int.tryParse(value ?? '') ?? 0),
                        onSave: (value) => localEntry.entryInstallment!.installmentQuantity = int.tryParse(value ?? '') ?? 0,
                        validator: (value) {
                          if (widget.showInstallment) {
                            final finalValue = value ?? '';
                            if (finalValue == '') {
                              return 'Informe a quantidade de parcelas';
                            }
                            if (int.tryParse(finalValue) != null && int.tryParse(finalValue)! <= 0) {
                              return 'Número de parcelas inválidas';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (localEntry.entryInstallment!.installmentQuantity != 0)
                        SizedBox(
                          height: MediaQuery.of(context).size.height *
                              (localEntry.entryType == null || localEntry.entryType!.type != EntryType.etBoth ? 0.33 : 0.21),
                          child: SingleChildScrollView(
                            physics: const ScrollPhysics(),
                            child: ListView.builder(
                              itemCount: localEntry.entryInstallment!.installmentQuantity,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (ctx, index) {
                                return _installmentCard(index + 1);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                // botões cancelar e salvar -------------------------------------------------------------------------
                _isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (localEntry.id.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(primary: Theme.of(context).errorColor.withAlpha(180)),
                                onPressed: _removeEntry,
                                child: const SizedBox(width: 80, child: Text("Excluir", textAlign: TextAlign.center)),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: Theme.of(context).disabledColor),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const SizedBox(width: 80, child: Text("Cancelar", textAlign: TextAlign.center)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: const SizedBox(width: 80, child: Text("Salvar", textAlign: TextAlign.center)),
                            ),
                          ),
                        ],
                      ),
                // alerta sobre lançamento pago --------------------------------------------------------------------
                if (widget.entry != null && widget.entry!.entryPaymentList!.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Lista de pagamentos',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5!,
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        itemCount: _entryPaymentList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (ctx, index) {
                          return _paymentCard(_entryPaymentList[index]);
                        },
                      )
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
