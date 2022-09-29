import 'package:fin/components/util/custom_datetimeselector.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/controllers/entry_controller.dart';
import 'package:fin/models/entry.dart';
import 'package:fin/screens/fin/entry/entry_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class EntryPaymentComponent extends StatefulWidget {
  final Entry entry;
  const EntryPaymentComponent({Key? key, required this.entry}) : super(key: key);

  @override
  State<EntryPaymentComponent> createState() => _EntryPaymentComponentState();
}

class _EntryPaymentComponentState extends State<EntryPaymentComponent> {
  final TextEditingController _textValueController = TextEditingController();
  late EntryPayment entryPayment;
  String _entryDateErrorMessage = '';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    entryPayment = EntryPayment(
      entryId: widget.entry.id,
      date: DateTime.now(),
      value: widget.entry.value - widget.entry.payedValue,
    );
  }

  Future<void> _submit({required BuildContext context}) async {
    _entryDateErrorMessage = '';
    if (widget.entry.date != null && entryPayment.date.isBefore(widget.entry.date!)) {
      _entryDateErrorMessage =
          'A data de pagamento deve ser posterior a data do lançamento (${DateFormat('dd/MM/yyyy').format(widget.entry.date!)})';
    }

    if (entryPayment.date.isAfter(DateTime.now())) {
      _entryDateErrorMessage = 'A data do pagamento não pdoe ser maior que o dia de hoje.';
    }

    setState(() => _isLoading = true);
    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      try {
        if (_entryDateErrorMessage == '') {
          _formKey.currentState?.save();

          EntryController entryController = Provider.of(context, listen: false);
          CustomReturn retorno;
          retorno = await entryController.registerPayment(entryPayment: entryPayment);
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(true);
            CustomMessage(
              context: context,
              modelType: ModelType.toast,
              messageText: 'Lançamento criado com sucesso',
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

  @override
  Widget build(BuildContext context) {
    _textValueController.text = entryPayment.value.toString();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Pagamento',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            EntryCard(entry: widget.entry, useSwipe: false),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  CustomDateTimeSelector(
                    buttonText: 'Data de pagamento',
                    context: context,
                    initialDate: entryPayment.date,
                    onOpenDateSelector: () => setState(() => _entryDateErrorMessage = ''),
                    errorMessage: _entryDateErrorMessage,
                    onSelected: (value) => entryPayment.date = value!,
                  ),
                  CustomTextEdit(
                    context: context,
                    controller: _textValueController,
                    labelText: 'Valor do pagamento',
                    hintText: 'Valor do pagamento',
                    onSave: (value) => entryPayment.value = double.parse(value ?? '0'),
                    validator: (value) {
                      final finalValue = value ?? '';
                      if (finalValue.trim().isEmpty) {
                        return 'Informe o valor do pagamento';
                      } else if (double.tryParse(finalValue) == null) {
                        return 'O valor informado não é um número válido';
                      } else {
                        if (double.tryParse(finalValue)! > widget.entry.value) {
                          return 'O valor do pagamento não pode ser maior que o valor do lançamento';
                        }
                        if (double.tryParse(finalValue)! == 0) {
                          return 'O valor do pagamento não pode zero';
                        }
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Voltar'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  await _submit(context: context);
                                },
                                child: const Text('Pagar'),
                              ),
                            ],
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
