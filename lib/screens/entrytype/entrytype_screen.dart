import 'package:fin/components/fin_scafold.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/entrytype_controller.dart';
import 'package:fin/screens/entrytype/entrytype_form.dart';
import 'package:fin/screens/entrytype/entrytype_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class EntryTypeScreen extends StatefulWidget {
  const EntryTypeScreen({Key? key}) : super(key: key);

  @override
  State<EntryTypeScreen> createState() => _EntryTypeScreenState();
}

class _EntryTypeScreenState extends State<EntryTypeScreen> {
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    _reloadEntryType();
  }

  _reloadEntryType() async {
    setState(() => _isLoading = true);
    try {
      CustomReturn retorno = await Provider.of<EntryTypeController>(context, listen: false).loadEntryTypeList();
      if (retorno.returnType == ReturnType.error) {
        CustomMessage(context: context, messageText: retorno.message, messageType: MessageType.error);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  _openModalForm(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return const EntryTypeForm();
      },
    ).then((value) => _reloadEntryType());
  }

  @override
  Widget build(BuildContext context) {
    var entryTypeList = Provider.of<EntryTypeController>(context, listen: true).entryTypeList;
    return FinScafold(
      title: 'Tipos de lançamento',
      showAppDrawer: false,
      appBarActions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              _reloadEntryType();
            },
          )
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: entryTypeList.length,
                itemBuilder: (ctx, index) => EntryTypeCard(
                  entryType: entryTypeList[index],
                  screenMode: ScreenMode.form,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openModalForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
