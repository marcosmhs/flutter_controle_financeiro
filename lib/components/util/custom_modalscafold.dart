import 'package:flutter/material.dart';

class CustomModalScafold extends StatelessWidget {
  final Widget body;
  final String title;

  const CustomModalScafold({
    Key? key,
    this.title = '',
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          width: MediaQuery.of(context).size.width - 10,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              if (title != '')
                Divider(
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).primaryColor,
                ),
              if (title != '')
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              if (title != '')
                Divider(
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).primaryColor,
                ),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
