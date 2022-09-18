import 'package:flutter/material.dart';
import 'package:fin/components/util/custom_dropbox.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/entry_controller.dart';
import 'package:fin/models/entry.dart';
import 'package:fin/screens/entry/entry_card.dart';
import 'package:fin/screens/entry/entry_form.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import '../components/fin_scafold.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  late final EntryController entryController;
  late List<Entry> entryList = [];
  late List<CustomDropBoxData> _dropBoxData = [];
  bool _isLoading = true;
  CustomDropBoxData _monthYearFilter = CustomDropBoxData(
    id: DateFormat('MM/yyyy').format(DateTime.now()),
    displayValue: DateFormat('MMMM/yyyy').format(DateTime.now()),
    icon: Icons.calendar_month,
  );

  @override
  initState() {
    super.initState();
    entryController = Provider.of<EntryController>(context, listen: false);
    _refreshEntryList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _openModalForm(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      elevation: 5,
      builder: (_) {
        return const EntryForm();
      },
    );
  }

  Future<void> _refreshEntryList() async {
    setState(() => _isLoading = true);
    try {
      CustomReturn r = await entryController.loadEntryList();
      if (r.returnType == ReturnType.error) {
        CustomMessage(
          context: context,
          messageText: r.message,
          messageType: MessageType.error,
        );
      }

      _dropBoxData = entryController.periodListData;
      entryList = entryController.entryListByDate(monthYear: _monthYearFilter.id);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Row _subTotalRow(double screenWidth, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: screenWidth * 0.40,
          child: Column(
            children: [
              const Text('Despesas', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
              const SizedBox(height: 5),
              Text(
                'R\$ ${entryController.totalExpenseValue(monthYear: "")}',
                style: Theme.of(context).textTheme.headline5!.merge(
                      const TextStyle(color: Colors.red),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        Container(
          alignment: Alignment.center,
          width: screenWidth * 0.40,
          child: Column(
            children: [
              const Text('Receitas', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
              const SizedBox(height: 5),
              Text(
                'R\$ ${entryController.totalIncomeValue(monthYear: "")}',
                style: Theme.of(context).textTheme.headline5!.merge(
                      const TextStyle(color: Colors.green),
                    ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeigth = MediaQuery.of(context).size.height;

    return FinScafold(
      appBarActions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              _refreshEntryList();
            },
          ),
      ],
      body: Column(
        children: [
          RefreshIndicator(
            onRefresh: _refreshEntryList,
            child: Card(
              margin: const EdgeInsets.all(6),
              elevation: 2,
              child: SizedBox(
                height: screenHeigth * 0.22,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomDropBox(
                      context: context,
                      onClose: (value) {
                        setState(() => _monthYearFilter = value);
                        entryList = entryController.entryListByDate(monthYear: _monthYearFilter.id);
                      },
                      data: _dropBoxData,
                      inicialValue: _dropBoxData.isEmpty ? null : _dropBoxData[0],
                      buttonText: _monthYearFilter.displayValue != '' ? _monthYearFilter.displayValue : 'Selecione um período',
                      title: 'Selecione um período',
                      buttonIcon: Icons.calendar_view_day_rounded,
                    ),
                    const Text('Saldo Geral em todas as contas'),
                    Text('R\$ ${entryController.totalEntryValue(monthYear: "")}', style: Theme.of(context).textTheme.headline3),
                    const SizedBox(height: 10),
                    // Receitas e despesas ---------------------------------------------
                    _subTotalRow(screenWidth, context)
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeigth * 0.65,
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : entryList.isEmpty
                      ? Center(
                          child: Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
                              child: Text(
                                'Não foram encontrados lançamentos em ${_monthYearFilter.displayValue}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: entryList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (ctx, index) {
                            return EntryCard(entry: entryList[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openModalForm(context),
        mini: false,
        child: const Icon(Icons.add_box),
      ),
    );
  }
}
