import 'package:flutter/material.dart';
import 'package:tool_store_app/view/var/var.dart';

class TextFormFields extends StatefulWidget {
  const TextFormFields({
    super.key,
    required this.labelTexts,
    required this.textColor,
    required this.controllers,
    required this.validators,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });
  final String labelTexts;
  final TextEditingController controllers;
  final Color textColor;
  final String? Function(String?)? validators;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  State<TextFormFields> createState() => _TextFormFieldsState();
}

class _TextFormFieldsState extends State<TextFormFields> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(paddingForm),
      child: TextFormField(
        controller: widget.controllers,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        decoration: InputDecoration(
          labelText: widget.labelTexts,
          labelStyle: Theme.of(context).textTheme.labelMedium,
          hintStyle: Theme.of(context).textTheme.labelMedium,
          floatingLabelStyle: Theme.of(context).textTheme.labelMedium,
          suffixIcon: widget.suffixIcon,
          border: const OutlineInputBorder(),
        ),
        validator: widget.validators,
      ),
    );
  }
}
