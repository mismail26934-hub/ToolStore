import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolFormInput extends StatefulWidget {
  const ToolFormInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormInput> createState() => ToolFormInputState();
}

class ToolFormInputState extends State<ToolFormInput> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Data Tool")),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            TextFormFields(
              labelTexts: 'Form Number',
              textColor: Colors.black,
              controllers: formNumberController,
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
              controllers: categoryController,
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
              controllers: checkedBy,
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
              controllers: dateCreateForm,
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
              controllers: commentRequester,
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
              controllers: commentSuperior,
              validators: (cmtReq) {
                if (cmtReq == null || cmtReq.isEmpty) {
                  return 'Required !';
                }
                return null;
              },
            ),
            TextFormFields(
              labelTexts: 'Comment Service Admin',
              textColor: Colors.black,
              controllers: commentServiceAdmin,
              validators: (cmtSup) {
                if (cmtSup == null || cmtSup.isEmpty) {
                  return 'Required !';
                }
                return null;
              },
            ),
            TextFormFields(
              labelTexts: 'Comment Service Head',
              textColor: Colors.black,
              controllers: commentServiceHead,
              validators: (cmtSup) {
                if (cmtSup == null || cmtSup.isEmpty) {
                  return 'Required !';
                }
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.all(paddingForm),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: clrBtnPrimary,
                  foregroundColor: clrBtnPrimaryFgBlack,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Data diproses'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: btnFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
