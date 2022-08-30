import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/entrytype_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/models/entry.dart';
import 'package:fin/screens/entrytype/entrytype_form.dart';
import 'package:flutter/material.dart';

enum ScreenMode { form, list, showItem }

class EntryTypeCard extends StatefulWidget {
  final EntryType entryType;
  final ScreenMode screenMode;
  final bool cropped;
  final double? fixedWidth;
  const EntryTypeCard({
    Key? key,
    required this.entryType,
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
            width: 45,
            height: 45,
            color: Colors.grey,
          ),
          title: const Text('Selecione um tipo')),
    );
  }

  @override
  State<EntryTypeCard> createState() => _EntryTypeCardState();
}

class _EntryTypeCardState extends State<EntryTypeCard> {
  bool _isLoading = false;

  void _removeEntryType() async {
    setState(() => _isLoading = true);
    try {
      var retorno = await Provider.of<EntryTypeController>(context, listen: false).removeEntryType(
        entryType: widget.entryType,
      );
      if (retorno.returnType == ReturnType.sucess) {
        CustomMessage(
          context: context,
          messageText: 'Dados salvos com sucesso',
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

  _returnSelectedItem() {
    Navigator.of(context).pop(widget.entryType);
  }

  @override
  Widget build(BuildContext context) {
    IconData itemIcon;

    if (widget.entryType.type == EntryType.etBoth) {
      itemIcon = Icons.money_outlined;
    } else if (widget.entryType.type == EntryType.etIncome) {
      itemIcon = Icons.monetization_on_outlined;
    } else {
      itemIcon = Icons.remove;
    }
    return GestureDetector(
      onTap: widget.screenMode == ScreenMode.list ? _returnSelectedItem : null,
      child: widget._structure(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              color: Color(widget.entryType.colorValue),
              child: Icon(
                itemIcon,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
        title: Text(widget.entryType.name),
        subtitle: Text('${widget.entryType.primaryClass} / ${widget.entryType.secundaryClass}'),
        trailing: widget.screenMode == ScreenMode.list
            ? ElevatedButton(onPressed: _returnSelectedItem, child: const Text('Selecionar'))
            : widget.screenMode == ScreenMode.showItem
                ? null
                : _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Color(widget.entryType.colorValue),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  elevation: 5,
                                  builder: (_) => EntryTypeForm(entryType: widget.entryType),
                                );
                              },
                            ),
                            // delete buttom
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Color(widget.entryType.colorValue),
                              onPressed: () async {
                                final deletedConfirmed = await CustomDialog(context: context).confirmationDialog(
                                  message: 'Confirma a exclusão do tipo de lançamento?',
                                );

                                if (deletedConfirmed ?? false) {
                                  _removeEntryType();
                                } else {
                                  CustomMessage(
                                    context: context,
                                    messageType: MessageType.info,
                                    messageText: 'Exclusão cancelada',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
