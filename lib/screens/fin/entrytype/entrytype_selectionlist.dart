import 'package:fin/controllers/entrytype_controller.dart';
import 'package:fin/screens/fin/entrytype/entrytype_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class EntryTypeSelectionList extends StatelessWidget {
  const EntryTypeSelectionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EntryTypeController entryTypeController = Provider.of(context, listen: false);
    var entryTypeList = entryTypeController.entryTypeList;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Column(
        children: [
          const Text('Toque no tipo de lançamento desejado'),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: entryTypeList.length,
              itemBuilder: (ctx, index) => EntryTypeCard(
                entryType: entryTypeList[index],
                screenMode: ScreenMode.list,
              ),
            ),
          )
        ],
      ),
    );
  }
}
