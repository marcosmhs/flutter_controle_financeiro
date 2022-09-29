import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/category_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:fin/models/item_classification.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class CategoryForm extends StatefulWidget {
  const CategoryForm({Key? key}) : super(key: key);

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Category category = Category();

  void _submit({required Category category}) async {
    setState(() => _isLoading = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      CustomReturn retorno;
      try {
        retorno = await Provider.of<CategoryController>(context, listen: false).save(
          category: category,
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

  void _showIconPicker(BuildContext context) async {
    var icon = await FlutterIconPicker.showIconPicker(
      context,
      title: const Text('Selecione um ícone'),
      searchHintText: 'Procurar',
      closeChild: const Text('Fechar', textScaleFactor: 1.5),
    );

    if (icon != null) {
      category.iconCode = icon.codePoint;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (category.id.isEmpty) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        category = ModalRoute.of(context)!.settings.arguments as Category;
        _nameController.text = category.name;
      }
    }

    return CustomScafold(
      title: category.name == '' ? 'Categorias' : category.name,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // active check
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch.adaptive(
                      value: category.active,
                      onChanged: (value) => setState(() => category.active = value),
                    ),
                    const Text("Ativo"),
                  ],
                ),
                // name
                CustomTextEdit(
                  context: context,
                  controller: _nameController,
                  onSave: (value) => category.name = value ?? '',
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                    return null;
                  },
                  labelText: 'Nome',
                  hintText: 'Informe o nome da categoria',
                ),
                const SizedBox(height: 10),
                // icon
                Row(
                  children: [
                    ElevatedButton(
                      child: const Text('Selecionar icone'),
                      onPressed: () => _showIconPicker(context),
                    ),
                    const SizedBox(width: 50),
                    if (category.iconCode != 0)
                      Icon(
                        IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                        size: 45,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // buttons
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
                              onPressed: () => _submit(category: category),
                              child: const SizedBox(width: 80, child: Text("Salvar", textAlign: TextAlign.center)),
                            ),
                          ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
