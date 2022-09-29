import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/models/entry.dart';
import 'package:fin/screens/fin/entry/entry_form.dart';
import 'package:fin/screens/fin/entry/entry_pay_component.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EntryCard extends StatefulWidget {
  final Entry entry;
  final double fixedHeight;
  final bool useSwipe;
  final void Function()? refreshMethod;
  const EntryCard({Key? key, required this.entry, this.refreshMethod, this.fixedHeight = 0, this.useSwipe = true})
      : super(key: key);

  @override
  State<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard> {
  Future<bool> _swipeAction({required BuildContext context, required DismissDirection direction}) async {
    if (direction == DismissDirection.startToEnd) {
      if (widget.entry.value == widget.entry.payedValue) {
        await CustomDialog(context: context).informationDialog(
          message: 'Este lançamento está pago, cuidado com alterações.',
        );
      }
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) {
          return EntryForm(entry: widget.entry);
        },
      ).then((value) {
        if (value) {
          if (widget.refreshMethod != null) {
            widget.refreshMethod;
          }
        }
      });
    } else {
      bool? openModal = true;
      if (widget.entry.value == widget.entry.payedValue) {
        openModal = await CustomDialog(context: context).confirmationDialog(
          message: 'Este lançamento está pago, deseja lançar um novo pagamento?',
        );
      }
      if (openModal!) {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          elevation: 5,
          builder: (_) {
            return EntryPaymentComponent(entry: widget.entry);
          },
        ).then((value) {
          if (value) {
            if (widget.refreshMethod != null) {
              widget.refreshMethod;
            }
          }
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: ((direction) async {
        return await _swipeAction(context: context, direction: direction);
      }),
      direction: !widget.useSwipe
          ? DismissDirection.none
          : widget.entry.entryExpenseIncome == EntryType.etExpense
              ? DismissDirection.horizontal
              : DismissDirection.startToEnd,
      background: Container(
        color: Theme.of(context).primaryColor.withAlpha(60),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
          size: 50,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.green.withAlpha(60),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: const Icon(
          Icons.payment,
          color: Colors.green,
          size: 50,
        ),
      ),
      child: SizedBox(
        height: widget.fixedHeight != 0 ? widget.fixedHeight : screenHeight * 0.13,
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // tipo e valor
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // icone
                              Container(
                                width: 40,
                                height: 40,
                                color: Color(widget.entry.entryType!.colorValue),
                                child: Icon(EntryType.icons[widget.entry.entryExpenseIncome], size: 20, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              // descrição e tipo
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.entry.entryType!.name),
                                  Text(
                                    '${widget.entry.entryType!.primaryClass} / ${widget.entry.entryType!.secundaryClass}',
                                  ),
                                  Text(
                                    widget.entry.id,
                                    style: Theme.of(context).textTheme.bodySmall!.merge(
                                          const TextStyle(color: Colors.grey, fontSize: 10),
                                        ),
                                  ),
                                ],
                              ),
                              // espaço entre descrição e valor
                              const Expanded(child: Text('')),
                              // valor
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${widget.entry.value}',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.subtitle1!.merge(
                                          const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  if (widget.entry.entryExpenseIncome == EntryType.etExpense && widget.entry.payedValue != 0)
                                    Text(
                                      'R\$ ${widget.entry.payedValue}',
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context).textTheme.subtitle2,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
                          child: Row(
                            children: [
                              Text(DateFormat('dd/MM/yyyy').format(widget.entry.date!)),
                              if (widget.entry.entryExpenseIncome == EntryType.etExpense)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        widget.entry.situationText,
                                        textAlign: TextAlign.right,
                                        style: widget.entry.expired ? const TextStyle(color: Colors.red) : null,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
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

/*
ListTile(
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        color: Colors.red,
                        child: Icon(
                          Icons.question_mark,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  title: Text('Tipo lançamento'),
                  subtitle: Text('Primário / secundário'),
                )
*/