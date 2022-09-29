import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/you_sell_drawer.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';

class YouSellScreen extends StatefulWidget {
  const YouSellScreen({Key? key}) : super(key: key);

  @override
  State<YouSellScreen> createState() => _YouSellScreenState();
}

class _YouSellScreenState extends State<YouSellScreen> {
  final List<String> imgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  ];

  Widget carrousel({required List<String> list, required BuildContext context, Widget? title}) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) title,
            if (title != null) const SizedBox(height: 5),
            CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: false,
                //viewportFraction: 1,
              ),
              itemCount: (list.length / 2).round(),
              itemBuilder: (context, index, _) {
                final int first = index * 2;
                final int second = first + 1;
                return Row(
                  children: [first, second].map((idx) {
                    return Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(list[idx], fit: BoxFit.cover),
                            const Text('Este é um teste com descrição longa para ver como fica'),
                            const SizedBox(height: 5),
                            const Text('R\$ 123,45', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScafold(
      title: 'You Store',
      drawer: const YouSellDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomTextEdit(
              labelText: 'Pesquisar',
              hintText: 'Pesquisar',
            ),
            carrousel(
              list: imgList,
              context: context,
              title: Text('Novos', style: Theme.of(context).textTheme.headline5),
            ),
            carrousel(
              list: imgList,
              context: context,
              title: Text('Mais Procurados', style: Theme.of(context).textTheme.headline5),
            ),
            carrousel(
              list: imgList,
              context: context,
              title: Text('Outros', style: Theme.of(context).textTheme.headline5),
            ),
          ],
        ),
      ),
    );
  }
}
