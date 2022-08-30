import 'package:fin/components/fin_modalscafold.dart';
import 'package:fin/components/util/custom_datetimeselector.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/entry_controller.dart';
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
  const EntryForm({Key? key, this.entry}) : super(key: key);

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  Entry localEntry = Entry(date: DateTime.now());
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _entryDescriptionController = TextEditingController();
  final TextEditingController _entryValueController = TextEditingController();
  final FocusNode _entryValueFocus = FocusNode();
  List<bool> _selectedIncomeExpense = [false, false];

  String _entryDateErrorMessage = '';
  String _entryExpirationDateErrorMessage = '';
  bool _entryTypeError = false;
  bool _incomeExpenseError = false;

  @override
  void initState() {
    super.initState();
    localEntry = widget.entry ?? localEntry;
    _entryDescriptionController.text = localEntry.description;
    _entryValueController.text = localEntry.value.toString();
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
          Navigator.of(context).pop();
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

  Widget _entryTypeSelection() {
    return Column(
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
    );
  }

  Widget _paymentCard(EntryPayment entryPayment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(entryPayment.date)),
              Text('R\$ ${entryPayment.value.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FinModalScafold(
      title: widget.entry != null && widget.entry!.id != '' ? 'Alterar' : 'Novo lançamento',
      body: Form(
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

            // botões cancelar e salvar ---------------------------------------------------------------------
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Theme.of(context).disabledColor),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const SizedBox(width: 80, child: Text("Cancelar", textAlign: TextAlign.center)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.primary),
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
                    itemCount: widget.entry!.entryPaymentList!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      return _paymentCard(widget.entry!.entryPaymentList![index]);
                    },
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
