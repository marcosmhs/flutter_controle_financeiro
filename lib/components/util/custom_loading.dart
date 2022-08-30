import 'package:flutter/material.dart';

class CustomLoading {
  final BuildContext context;

  CustomLoading({required this.context});

  Widget builder({
    required bool condition,
    required String loadingMessage,
    bool? showReloadButton = false,
    String? reloadMessage = '',
    String? reloadButtonLabel = '',
    void Function()? reloadMethod,
    required Widget child,
  }) {
    showReloadButton = showReloadButton ?? false;
    return condition
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!showReloadButton)
                  Column(children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(loadingMessage)
                  ]),
                if (showReloadButton && reloadMethod != null)
                  Column(children: [
                    Text(reloadMessage ?? ''),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: () => reloadMethod, child: const Text('Tentar novamente'))
                  ]),
              ],
            ),
          )
        : child;
  }
}
