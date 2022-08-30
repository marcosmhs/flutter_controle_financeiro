import 'package:fin/components/fin_drawer.dart';
import 'package:flutter/material.dart';

class FinScafold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showAppDrawer;
  final List<Widget>? appBarActions;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;

  const FinScafold({
    Key? key,
    this.title = '',
    required this.body,
    this.floatingActionButton,
    this.showAppDrawer = true,
    this.appBarActions,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Center(
          child: Text(title),
        ),
        actions: appBarActions,
      ),
      drawer: showAppDrawer ? const FinDrawer() : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
