// ignore_for_file: file_names
import 'package:flutter/material.dart';

class CustomTextEdit extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final bool isPassword;
  final BuildContext? context;
  final String? inicialValue;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final FocusNode? nextFocusNode;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSave;
  final InputBorder? border;
  final void Function()? onTap;

  const CustomTextEdit({
    Key? key,
    this.context,
    this.controller,
    required this.labelText,
    required this.hintText,
    this.enabled = true,
    this.isPassword = false,
    this.inicialValue,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
    this.nextFocusNode,
    this.focusNode,
    this.prefixIcon,
    this.validator,
    this.onSave,
    this.border,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomTextEdit> createState() => _CustomTextEditState();
}

class _CustomTextEditState extends State<CustomTextEdit> {
  late bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          const SizedBox(height: 10),
          TextFormField(
            enabled: widget.enabled,
            obscureText: !widget.isPassword ? false : _hidePassword,
            // use text editor only if keyboardType wasn´t set.
            keyboardType: widget.isPassword && widget.keyboardType == null
                ? TextInputType.text
                : widget.keyboardType ?? TextInputType.text,
            onSaved: widget.onSave,
            initialValue: widget.inicialValue,
            textInputAction: widget.textInputAction,
            onFieldSubmitted:
                widget.nextFocusNode == null ? null : (_) => FocusScope.of(context).requestFocus(widget.nextFocusNode),
            focusNode: widget.focusNode,
            validator: widget.validator,
            controller: widget.controller,
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
              // set if password should be visible
              suffixIcon: !widget.isPassword
                  ? null
                  : GestureDetector(
                      onTap: () {
                        _hidePassword = !_hidePassword;
                        setState(() {});
                      },
                      child: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                    ),
              hintText: widget.hintText,
              labelText: widget.labelText,
              border: widget.border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
            ),
          ),
        ],
      ),
    );
  }
}
