import 'package:flutter/material.dart';

class BuildDetail extends StatefulWidget {
  const BuildDetail({super.key, required this.label, required this.value});
  final String label, value;

  @override
  State<BuildDetail> createState() => _BuildDetailState();
}

class _BuildDetailState extends State<BuildDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "${widget.label}: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(widget.value.isEmpty ? "-" : widget.value)),
        ],
      ),
    );
  }
}
