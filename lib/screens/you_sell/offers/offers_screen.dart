import 'package:fin/components/util/custom_message.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/controllers/offer_controller.dart';
import 'package:fin/models/offer.dart';
import 'package:fin/routes.dart';
import 'package:fin/screens/you_sell/offers/offer_screen_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  late bool _isLoading = false;
  late List<Offer> _offerList;
  late List<bool> _selectedType = [true, false];
  late OfferType _filterOfferType = OfferType.product;

  @override
  void initState() {
    super.initState();
    _reloadOfferList();
  }

  void _reloadOfferList() async {
    setState(() => _isLoading = true);
    try {
      CustomReturn retorno = await Provider.of<OfferController>(context, listen: false).reloadCurrentUserOfferList(
        offerType: _filterOfferType,
      );
      if (retorno.returnType == ReturnType.error) {
        CustomMessage(context: context, messageText: retorno.message, messageType: MessageType.error);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _syncOfferList() {
    setState(() {
      _offerList = Provider.of<OfferController>(context, listen: true).offerList;
    });
  }

  Widget _typeSelection(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tipo de oferta'),
            ToggleButtons(
              isSelected: _selectedType,
              fillColor: Theme.of(context).primaryColor,
              selectedColor: Colors.black,
              onPressed: (index) {
                setState(() {
                  _selectedType = [index == 0, index == 1];
                  _filterOfferType = _selectedType[0] ? OfferType.product : OfferType.service;
                });
                _reloadOfferList();
              },
              children: [
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.account_box), SizedBox(width: 5), Text('Produto')],
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.account_box), SizedBox(width: 5), Text('Serviço')],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncOfferList();
    return CustomScafold(
      title: 'Seus anúncios',
      showAppDrawer: false,
      appBarActions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _reloadOfferList,
          )
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _typeSelection(context),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.70,
                    child: ListView.builder(
                      itemCount: _offerList.length,
                      itemBuilder: (ctx, index) => OfferScreenCard(
                        offer: _offerList[index],
                        screenMode: OfferScreenCardScreenMode.form,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.offersForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
