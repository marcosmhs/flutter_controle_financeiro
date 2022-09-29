import 'package:fin/components/util/custom_message.dart';
import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/controllers/offer_controller.dart';
import 'package:fin/models/offer.dart';
import 'package:fin/routes.dart';
import 'package:fin/screens/you_sell/offers/offer_screen_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class OffersEvaluationScreen extends StatefulWidget {
  const OffersEvaluationScreen({Key? key}) : super(key: key);

  @override
  State<OffersEvaluationScreen> createState() => _OffersEvaluationScreenState();
}

class _OffersEvaluationScreenState extends State<OffersEvaluationScreen> {
  late bool _isLoading = false;
  late List<Offer> _offerList;
  late bool _offerWatingEvaluation = true;
  late List<bool> _selectedType = [true, false];
  late OfferType _filterOfferType = OfferType.product;

  @override
  void initState() {
    super.initState();
    _syncOfferList();
  }

  void _syncOfferList() async {
    setState(() => _isLoading = true);
    try {
      _offerList = await Provider.of<OfferController>(context, listen: false).getOffersEvaluationList(
        evaluated: !_offerWatingEvaluation,
        offerType: _filterOfferType,
      );
      if (_offerList.isEmpty) {
        CustomMessage(context: context, messageText: 'Nenhuma oferta aguardando avaliação', messageType: MessageType.info);
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
                _syncOfferList();
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
    return CustomScafold(
      title: 'LIberação de anúncios',
      showAppDrawer: false,
      appBarActions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _syncOfferList,
          )
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch.adaptive(
                        value: _offerWatingEvaluation,
                        onChanged: (value) {
                          setState(() => _offerWatingEvaluation = value);
                          _syncOfferList();
                        },
                      ),
                      Text(_offerWatingEvaluation ? "Apenas ofertas aguardando liberação" : 'Apenas ofertas liberadas'),
                    ],
                  ),
                  _typeSelection(context),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.73,
                    child: ListView.builder(
                      itemCount: _offerList.length,
                      itemBuilder: (ctx, index) => OfferScreenCard(
                        offer: _offerList[index],
                        screenMode: OfferScreenCardScreenMode.evaluation,
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
