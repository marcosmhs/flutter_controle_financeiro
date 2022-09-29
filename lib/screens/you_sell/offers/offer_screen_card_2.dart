import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/offer_controller.dart';
import 'package:fin/models/offer.dart';
import 'package:fin/routes.dart';
import 'package:fin/screens/you_sell/offers/offers_form.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

enum OfferScreenCardScreenMode { form, list, showItem, evaluation }

class OfferScreenCard extends StatefulWidget {
  final OfferScreenCardScreenMode screenMode;
  final Offer offer;
  final bool cropped;
  final double? fixedWidth;

  const OfferScreenCard({
    Key? key,
    required this.offer,
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
          title: const Text('Selecione uma categoria')),
    );
  }

  @override
  State<OfferScreenCard> createState() => _OfferScreenCardState();
}

class _OfferScreenCardState extends State<OfferScreenCard> {
  bool _isLoading = false;

  void _remove() async {
    final deletedConfirmed = await CustomDialog(context: context).confirmationDialog(
      message: 'Confirma a exclusão da oferta?',
    );

    if (!(deletedConfirmed ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ignore: use_build_context_synchronously
      var retorno = await Provider.of<OfferController>(context, listen: false).remove(
        offerId: widget.offer.id,
      );
      if (retorno.returnType == ReturnType.sucess) {
        CustomMessage(
          context: context,
          messageText: 'Oferta removida',
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
    Navigator.of(context).pop(widget.offer);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.screenMode == OfferScreenCardScreenMode.list ? _returnSelectedItem : null,
      child: widget._structure(
        leading: Container(
          alignment: Alignment.centerLeft,
          width: 65,
          height: 65,
          child: Image.network(widget.offer.thumbnailUrl, fit: BoxFit.cover),
        ),
        title: Text(widget.offer.title),
        //subtitle: widget.category.active ? null : const Text('(Inativo)'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // category
            Row(
              children: [
                Icon(
                  IconData(widget.offer.category.iconCode, fontFamily: 'MaterialIcons'),
                  size: 20,
                  color: widget.offer.category.active ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                ),
                const SizedBox(width: 3),
                Text(widget.offer.category.name)
              ],
            ),
            // subcategory
            Row(
              children: [
                Icon(
                  IconData(widget.offer.subCategory.iconCode, fontFamily: 'MaterialIcons'),
                  size: 20,
                  color: widget.offer.subCategory.active ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                ),
                const SizedBox(width: 3),
                Text(widget.offer.subCategory.name)
              ],
            ),
            // status
            Row(
              children: [
                Icon(
                  widget.offer.expirationDate != null && widget.offer.expirationDate!.isAfter(DateTime.now())
                      ? Icons.check_box
                      : Icons.warning_amber,
                  size: 20,
                  color: widget.offer.subCategory.active ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    !widget.offer.evaluated
                        ? 'Aguardando liberação'
                        : widget.offer.expirationDate != null && widget.offer.expirationDate!.isBefore(DateTime.now())
                            ? 'Anúncio expirado'
                            : 'Liberado até ${DateFormat('dd/MM/yyyy').format(widget.offer.expirationDate!)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
              ],
            ),
          ],
        ),

        // { form, list, showItem, evaluation }
        trailing: widget.screenMode == OfferScreenCardScreenMode.list
            ? ElevatedButton(onPressed: _returnSelectedItem, child: const Text('Selecionar'))
            : widget.screenMode == OfferScreenCardScreenMode.showItem
                ? null
                : _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : widget.screenMode == OfferScreenCardScreenMode.evaluation
                        ? IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.offersForm,
                              arguments: [
                                widget.offer,
                                OfferFormScreenMode.evaluation,
                              ],
                            ),
                          )
                        : SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.pushNamed(context, Routes.offersForm, arguments: [widget.offer]),
                                ),
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
