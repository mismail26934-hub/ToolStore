import 'package:flutter/material.dart';
import 'package:tool_store_app/view/form/text_form_field.dart';

class FmInputDataTool extends StatefulWidget {
  const FmInputDataTool({super.key});

  @override
  State<FmInputDataTool> createState() => FmInputDataToolState();
}

class FmInputDataToolState extends State<FmInputDataTool> {
  final _formKey = GlobalKey<FormState>();
  final _formNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 8.0,
        children: [
          TextFormFields(
            labelTexts: 'Form Number',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (formNumber) {
              if (formNumber == null || formNumber.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          TextFormFields(
            labelTexts: 'Category',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (category) {
              if (category == null || category.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          TextFormFields(
            labelTexts: 'Checked By',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (cek) {
              if (cek == null || cek.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          TextFormFields(
            labelTexts: 'Date Create Form',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (dtCreateFm) {
              if (dtCreateFm == null || dtCreateFm.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          TextFormFields(
            labelTexts: 'Comment Requester',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (cmtReq) {
              if (cmtReq == null || cmtReq.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          TextFormFields(
            labelTexts: 'Comment Requester',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (cmtReq) {
              if (cmtReq == null || cmtReq.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          TextFormFields(
            labelTexts: 'Comment Superior',
            textColor: Colors.black,
            controllers: _formNumberController,
            validators: (cmtSup) {
              if (cmtSup == null || cmtSup.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // 4. Cara memicu validasi
              if (_formKey.currentState!.validate()) {
                // Jika valid, lakukan aksi selanjutnya (misal: simpan data)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Data diproses'),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
