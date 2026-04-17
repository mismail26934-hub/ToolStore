import 'package:flutter/material.dart';
import 'package:tool_store_app/view/var/var.dart';

class TextFormFields extends StatefulWidget {
  const TextFormFields({
    super.key,
    required this.labelTexts,
    required this.textColor,
    required this.controllers,
    required this.validators,
  });
  final String labelTexts;
  final TextEditingController controllers;
  final Color textColor;
  final String? Function(String?)? validators;

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
        decoration: InputDecoration(
          labelText: widget.labelTexts,
          labelStyle: Theme.of(context).textTheme.titleSmall,
          border: const OutlineInputBorder(),
        ),
        validator: widget.validators,
      ),
    );
  }
}
