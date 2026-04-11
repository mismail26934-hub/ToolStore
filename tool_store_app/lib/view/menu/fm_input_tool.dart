import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/functions.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/var/var.dart';

class FmInputDataTool extends StatefulWidget {
  const FmInputDataTool({super.key});

  @override
  State<FmInputDataTool> createState() => FmInputDataToolState();
}

class FmInputDataToolState extends State<FmInputDataTool> {
  @override
  void initState() {
    // TODO: implement initState
    // _getDataUser(params);
    super.initState();
  }

  List<PostList?> _listUser = [];
  bool _loading = false;
  String params = paramViewDataUser;

  _getDataUser(params) async {
    setState(() {
      _loading = true;
    });
    PostData.getDataUser(params, "", "", "", "", "", "", "", "", "", "").then((
      value,
    ) async {
      setState(() {
        _listUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
                backgroundColor: clrBtnPrimary,
                foregroundColor: clrBtnPrimaryFgBlack,
              ),
              onPressed: () {
                // 4. Cara memicu validasi
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _getDataUser(params);
                  });
                  // Jika valid, lakukan aksi selanjutnya (misal: simpan data)
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
    );
  }
}
