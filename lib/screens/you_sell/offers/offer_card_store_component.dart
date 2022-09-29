import 'package:fin/models/offer.dart';
import 'package:flutter/material.dart';

enum OfferStoreCardStyle { small, medium, large }

class OfferStoreCardComponent extends StatefulWidget {
  final Offer offer;
  final OfferStoreCardStyle cardStyle;

  const OfferStoreCardComponent({
    Key? key,
    required this.offer,
    this.cardStyle = OfferStoreCardStyle.medium,
  }) : super(key: key);

  @override
  State<OfferStoreCardComponent> createState() => _OfferStoreCardComponentState();
}

class _OfferStoreCardComponentState extends State<OfferStoreCardComponent> {
  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 1,
      child: Text('hi!'),
    );
  }
}
