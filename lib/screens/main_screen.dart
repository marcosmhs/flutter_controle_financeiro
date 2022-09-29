import 'package:fin/screens/fin/fin_screen.dart';
import 'package:fin/screens/you_sell/you_sell_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import '../components/util/custom_scafold.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScafold(
      showAppBar: false,
      body: Center(
        child: _selectedIndex == 0 ? const FinScreen() : const YouSellScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Fin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'You Sell',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
