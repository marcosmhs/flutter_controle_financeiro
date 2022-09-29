import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/screens/you_sell/category/category_card.dart';
import 'package:fin/screens/you_sell/category/category_selection_list.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:fin/models/item_classification.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class SubCategoryForm extends StatefulWidget {
  const SubCategoryForm({Key? key}) : super(key: key);

  @override
  State<SubCategoryForm> createState() => _SubCategoryFormState();
}

class _SubCategoryFormState extends State<SubCategoryForm> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late SubCategory subCategory = SubCategory();
  late bool _categoryError = false;

  void _submit() async {
    setState(() => _isLoading = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      CustomReturn retorno;
      try {
        retorno = await Provider.of<SubCategoryController>(context, listen: false).save(
          subCategory: subCategory,
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
      subCategory.iconCode = icon.codePoint;
      setState(() {});
    }
  }

  Widget _categorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
              decoration: _categoryError ? BoxDecoration(border: Border.all(color: Theme.of(context).errorColor)) : null,
              alignment: Alignment.center,
              child: subCategory.category == null
                  ? CategoryCard(category: Category(), screenMode: CategoryCardScreenMode.showItem).emptyCard(context)
                  : CategoryCard(
                      category: subCategory.category!,
                      screenMode: CategoryCardScreenMode.showItem,
                      cropped: true,
                    ),
            ),
            onTap: () async {
              var category = await showModalBottomSheet<Category>(
                context: context,
                isDismissible: true,
                builder: (context) => const CategorySelectionList(),
              );
              if (category != null) {
                setState(() {
                  _categoryError = false;
                  subCategory.categoryId = category.id;
                  subCategory.category = category;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (subCategory.id.isEmpty) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        if (subCategory.id.isEmpty) {
          subCategory = ModalRoute.of(context)!.settings.arguments as SubCategory;
          _nameController.text = subCategory.name;
        }
      }
    }

    return CustomScafold(
      title: subCategory.name == '' ? 'SubCategoria' : subCategory.name,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _categorySelection(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch.adaptive(
                      value: subCategory.active,
                      onChanged: (value) => setState(() => subCategory.active = value),
                    ),
                    const Text("Ativo"),
                  ],
                ),
                CustomTextEdit(
                  context: context,
                  controller: _nameController,
                  onSave: (value) => subCategory.name = value ?? '',
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                    return null;
                  },
                  labelText: 'Nome',
                  hintText: 'Informe o nome da categoria',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      child: const Text('Selecionar icone'),
                      onPressed: () => _showIconPicker(context),
                    ),
                    const SizedBox(width: 50),
                    if (subCategory.iconCode != 0)
                      Icon(
                        IconData(subCategory.iconCode, fontFamily: 'MaterialIcons'),
                        size: 45,
                      ),
                  ],
                ),
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
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
