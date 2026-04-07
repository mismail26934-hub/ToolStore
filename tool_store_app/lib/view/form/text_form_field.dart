import 'package:flutter/material.dart';

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
    return TextFormField(
      controller: widget.controllers,
      decoration: InputDecoration(
        labelText: widget.labelTexts,
        border: const OutlineInputBorder(),
      ),
      validator: widget.validators,
    );
  }
}
