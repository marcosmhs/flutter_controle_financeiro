import 'package:flutter/material.dart';

class CustomDropBoxData {
  final String id;
  final String displayValue;
  final IconData? icon;

  CustomDropBoxData({required this.id, required this.displayValue, this.icon});
}

typedef OnClose<CustomDropBoxData> = void Function(CustomDropBoxData value);

enum DisplayMode { dialog, modal }

class CustomDropBox extends StatefulWidget {
  final BuildContext context;
  final OnClose<CustomDropBoxData> onClose;
  final List<CustomDropBoxData> data;
  final String title;
  final String buttonText;
  final DisplayMode displayMode;
  final Color? color;
  final IconData? buttonIcon;
  final CustomDropBoxData? inicialValue;
  const CustomDropBox({
    Key? key,
    required this.context,
    required this.onClose,
    required this.data,
    this.title = '',
    required this.buttonText,
    this.displayMode = DisplayMode.dialog,
    this.buttonIcon,
    this.color,
    this.inicialValue,
  }) : super(key: key);

  @override
  State<CustomDropBox> createState() => _CustomDropBoxState();
}

class _CustomDropBoxState extends State<CustomDropBox> {
  CustomDropBoxData? _selectedValue;

  @override
  initState() {
    super.initState();
    if (widget.inicialValue != null) {
      _selectedValue = widget.inicialValue;
    }
  }

  Future<bool?> _openDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: _dropBoxBody(),
      ),
    );
  }

_openModalSelectionList() {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      elevation: 5,
      builder: (_) {
        return _dropBoxBody();
      },
    );
  }

  Widget _dropBoxBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
          width: MediaQuery.of(context).size.width - 30,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              if (widget.title != '')
                Divider(thickness: 1, indent: 10, endIndent: 10, color: Theme.of(context).primaryColor),
              if (widget.title != '') Text(widget.title, style: Theme.of(context).textTheme.headline5),
              if (widget.title != '')
                Divider(thickness: 1, indent: 10, endIndent: 10, color: Theme.of(context).primaryColor),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.data.length,
                    itemBuilder: (ctx, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onClose(widget.data[index]);
                          setState(() => _selectedValue = widget.data[index]);
                        },
                        child: Column(
                          children: [
                            Card(
                              color: widget.inicialValue != null
                                  ? widget.data[index].id == widget.inicialValue!.id
                                      ? Theme.of(context).primaryColor.withAlpha(50)
                                      : null
                                  : null,
                              elevation: 0,
                              child: Row(
                                children: [
                                  if (widget.data[index].icon != null) Icon(widget.data[index].icon),
                                  if (widget.data[index].icon != null) const SizedBox(width: 5),
                                  Text(widget.data[index].displayValue),
                                ],
                              ),
                            ),
                            const Divider(thickness: 0.8, color: Colors.grey)
                          ],
                        ),
                      );

                      //return Text(data[index].displayValue);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      //onPressed: () => _openModalSelectionList(),
      onPressed: () {
        if (widget.displayMode == DisplayMode.dialog) {
          _openDialog();
        } else {
          _openModalSelectionList();
        }
      },
      style: ElevatedButton.styleFrom(
        primary: widget.color ?? Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.buttonIcon != null || (_selectedValue != null && _selectedValue!.icon != null))
              Icon(_selectedValue != null ? _selectedValue!.icon : widget.buttonIcon),
            if (widget.buttonIcon != null || (_selectedValue != null && _selectedValue!.icon != null))
              const SizedBox(width: 5),
            Text(_selectedValue == null ? widget.buttonText : _selectedValue!.displayValue),
          ],
        ),
      ),
    );
  }
}
