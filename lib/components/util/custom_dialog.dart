import 'package:flutter/material.dart';

class CustomDialog {
  final BuildContext context;

  CustomDialog({required this.context});

  Future<bool?> errorMessage({required String message}) {
    return customdialog(
      message: message,
      yesButtonText: "OK",
      yesButtonValue: false,
      noButtonText: '',
      icon: Icon(
        Icons.error_outline,
        size: 50,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<bool?> confirmationDialog({
    required String message,
    Color? yesButtonHighlightColor,
    String yesButtonText = 'Sim',
    String noButtonText = 'Não',
  }) async {
    return await customdialog(
      message: message,
      yesButtonText: yesButtonText,
      noButtonText: noButtonText,
      yesButtonColor: yesButtonHighlightColor,
      icon: const Icon(Icons.question_mark, size: 50),
    );
  }

  Future<bool?> informationDialog({required String message}) {
    // A cor do botão deve ser passada em branco para assumir a cor do tema
    // noButtonText deve ser deixado em branco para que não seja exibido
    return customdialog(
      message: message,
      yesButtonText: "OK",
      noButtonText: '',
      icon: const Icon(Icons.info_outline, size: 50),
    );
  }

  Future<bool?> customdialog({
    required String message,
    required String yesButtonText,
    required String noButtonText,
    bool? yesButtonValue = true,
    Color? yesButtonColor,
    Icon? icon,
  }) {
    Color yesBtnColor = yesButtonColor ?? Theme.of(context).colorScheme.primary;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            icon ?? Container(),
            icon != null ? const SizedBox(width: 10) : Container(),
            Flexible(child: Text(message)),
          ],
        ),
        actions: [
          if (noButtonText != '')
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(noButtonText),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(yesButtonValue),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(yesBtnColor)),
            child: Text(yesButtonText),
          )
        ],
      ),
    );
  }
}
