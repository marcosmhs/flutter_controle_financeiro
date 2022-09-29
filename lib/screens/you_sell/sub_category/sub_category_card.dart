import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/routes.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/models/item_classification.dart';
import 'package:flutter/material.dart';

enum SubCategoryCardScreenMode { form, list, showItem }

class SubCategoryCard extends StatefulWidget {
  final SubCategory subCategory;
  final SubCategoryCardScreenMode screenMode;
  final bool cropped;
  final double? fixedWidth;

  const SubCategoryCard({
    Key? key,
    required this.subCategory,
    required this.screenMode,
    this.cropped = false,
    this.fixedWidth,
  }) : super(key: key);

  Widget _structure({Widget? leading, Widget? title, Widget? subtitle, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      elevation: 1,
      child: ListTile(
        visualDensity: cropped ? const VisualDensity(horizontal: 0, vertical: -4) : null,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }

  Widget emptyCard(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 28),
      child: _structure(
          leading: Container(
            width: cropped ? 25 : 45,
            height: cropped ? 25 : 45,
            color: Colors.grey,
          ),
          title: const Text('Selecione uma subcategoria')),
    );
  }

  @override
  State<SubCategoryCard> createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<SubCategoryCard> {
  bool _isLoading = false;

  void _remove() async {
    final deletedConfirmed = await CustomDialog(context: context).confirmationDialog(
      message: 'Confirma a exclusão da subcategoria?',
    );

    if (!(deletedConfirmed ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ignore: use_build_context_synchronously
      var retorno = await Provider.of<SubCategoryController>(context, listen: false).remove(
        subCategoryId: widget.subCategory.id,
      );
      if (retorno.returnType == ReturnType.sucess) {
        CustomMessage(
          context: context,
          messageText: 'Subcategoria removida',
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

  void _returnSelectedItem() {
    Navigator.of(context).pop(widget.subCategory);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.screenMode == SubCategoryCardScreenMode.list ? _returnSelectedItem : null,
      child: widget._structure(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 45,
              height: 45,
              child: Icon(
                IconData(widget.subCategory.iconCode, fontFamily: 'MaterialIcons'),
                size: 30,
                color: widget.subCategory.active ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
        title: Text(widget.subCategory.name),
        subtitle: widget.subCategory.active ? null : const Text('(Inativo)'),
        trailing: widget.screenMode == SubCategoryCardScreenMode.list
            ? ElevatedButton(onPressed: _returnSelectedItem, child: const Text('Selecionar'))
            : widget.screenMode == SubCategoryCardScreenMode.showItem
                ? null
                : _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    Navigator.pushNamed(context, Routes.subCategoryForm, arguments: widget.subCategory)),
                            // delete buttom
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: _remove,
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
