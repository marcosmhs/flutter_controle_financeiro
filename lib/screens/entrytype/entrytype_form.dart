import 'package:fin/components/fin_modalscafold.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/entrytype_controller.dart';
import 'package:fin/models/entry.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class EntryTypeForm extends StatefulWidget {
  final EntryType? entryType;
  const EntryTypeForm({Key? key, this.entryType}) : super(key: key);

  @override
  State<EntryTypeForm> createState() => _EntryTypeFormState();
}

class _EntryTypeFormState extends State<EntryTypeForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _primaryClassController = TextEditingController();
  final TextEditingController _secundaryClassController = TextEditingController();
  final FocusNode _primaryFocus = FocusNode();
  final FocusNode _secundaryFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<bool> _selectedType = [true, false, false];

  late EntryType localEntryType = EntryType(colorValue: Theme.of(context).primaryColor.value);

  @override
  void initState() {
    super.initState();
    if (widget.entryType != null) {
      localEntryType = widget.entryType!;
      _nameController.text = localEntryType.name;
      _primaryClassController.text = localEntryType.primaryClass;
      _secundaryClassController.text = localEntryType.secundaryClass;
      _selectedType = [
        localEntryType.type == EntryType.etBoth,
        localEntryType.type == EntryType.etIncome,
        localEntryType.type == EntryType.etExpense
      ];
    }
  }

  void _submit() async {
    setState(() => _isLoading = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      CustomReturn retorno;
      try {
        retorno = await Provider.of<EntryTypeController>(context, listen: false).save(
          entryType: localEntryType,
        );
        if (retorno.returnType == ReturnType.sucess) {
          CustomMessage(
            context: context,
            messageText: 'Dados salvos com sucesso',
            messageType: MessageType.sucess,
          );
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          CustomMessage(
            context: context,
            modelType: ModelType.toast,
            messageText: retorno.message,
            messageType: MessageType.error,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _typeSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          const Text('Tipos de lançamentos permitidos e cor de identificação'),
          const SizedBox(height: 5),
          Center(
            child: ToggleButtons(
              isSelected: _selectedType,
              fillColor:
                  localEntryType.colorValue == 0 ? Theme.of(context).primaryColor : Color(localEntryType.colorValue),
              selectedColor: Colors.black,
              onPressed: (index) {
                _showCollorPicker(context);
                setState(() {
                  if (index == 0) {
                    localEntryType.type = EntryType.etBoth;
                  } else if (index == 1) {
                    localEntryType.type = EntryType.etIncome;
                  } else {
                    localEntryType.type = EntryType.etExpense;
                  }
                  _selectedType = [index == 0, index == 1, index == 2];
                });
              },
              children: [
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(EntryType.iconBoth),
                      const SizedBox(width: 5),
                      Text(EntryType.etBoth),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(EntryType.iconIncome), const SizedBox(width: 5), Text(EntryType.etIncome)],
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(EntryType.iconExpense), const SizedBox(width: 5), Text(EntryType.etExpense)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FinModalScafold(
      title: 'Tipo lançamento',
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              CustomTextEdit(
                context: context,
                controller: _nameController,
                nextFocusNode: _primaryFocus,
                onSave: (value) => localEntryType.name = value ?? '',
                validator: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                  return null;
                },
                labelText: 'Nome',
                hintText: 'Informe o nome do tipo de lançamento',
              ),
              CustomTextEdit(
                context: context,
                controller: _primaryClassController,
                focusNode: _primaryFocus,
                nextFocusNode: _secundaryFocus,
                onSave: (value) => localEntryType.primaryClass = value ?? '',
                validator: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isEmpty) return 'A classificação primária deve ser informada';
                  return null;
                },
                labelText: 'Classificação primária',
                hintText: 'Classificação primária (ex: Casa, família)',
              ),
              CustomTextEdit(
                context: context,
                controller: _secundaryClassController,
                focusNode: _secundaryFocus,
                onSave: (value) => localEntryType.secundaryClass = value ?? '',
                validator: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isEmpty) return 'A classificação secundária deve ser informada';
                  return null;
                },
                labelText: 'Classificação Secundária',
                hintText: 'Classificação secundária (ex: copel, sanepar, etc)',
              ),
              const SizedBox(height: 10),
              _typeSelection(context),
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
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showCollorPicker(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selecione a cor tipo de lançamento'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor:
                    localEntryType.colorValue == 0 ? Theme.of(context).primaryColor : Color(localEntryType.colorValue),
                onColorChanged: (selectedColor) => setState(() {
                  localEntryType.colorValue = selectedColor.value;
                }),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(child: const Text('Selecionar'), onPressed: () => Navigator.of(context).pop()),
            ],
          );
        });
  }
}
