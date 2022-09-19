import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/you_store_drawer.dart';
import 'package:flutter/material.dart';

class YouStoreScreen extends StatefulWidget {
  const YouStoreScreen({Key? key}) : super(key: key);

  @override
  State<YouStoreScreen> createState() => _YouStoreScreenState();
}

class _YouStoreScreenState extends State<YouStoreScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScafold(
      title: 'You Store',
      drawer: const YouStoreDrawer(),
      body: const Text('Store'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        mini: false,
        child: const Icon(Icons.add_ic_call),
      ),
    );
  }
}
