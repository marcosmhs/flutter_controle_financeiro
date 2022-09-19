import 'package:flutter/material.dart';

class CustomScafold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showAppDrawer;
  final bool showAppBar;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Widget? drawer;

  const CustomScafold({
    Key? key,
    this.title = '',
    this.drawer,
    this.showAppBar = true,
    required this.body,
    this.floatingActionButton,
    this.showAppDrawer = true,
    this.appBarActions,
    this.bottomNavigationBar,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: appBarActions,
            )
          : null,
      bottomNavigationBar: bottomNavigationBar,
      drawer: showAppDrawer ? drawer : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
