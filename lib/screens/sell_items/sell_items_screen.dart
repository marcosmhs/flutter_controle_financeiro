import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/you_store_drawer.dart';
import 'package:flutter/material.dart';

class SellItemsScreen extends StatefulWidget {
  const SellItemsScreen({Key? key}) : super(key: key);

  @override
  State<SellItemsScreen> createState() => _SellItemsScreenState();
}

class _SellItemsScreenState extends State<SellItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScafold(
      drawer: const YouStoreDrawer(),
      body: Center(
        child: Column(
          children: [const Text('Selling')],
        ),
      ),
    );
  }
}
