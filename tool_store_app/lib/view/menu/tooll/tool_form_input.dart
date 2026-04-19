import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/function/funct.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormFields(
                  labelTexts: 'Form Number',
                  textColor: Colors.black,
                  controllers: formNoCont,
                  validators: (formNumber) {
                    if (formNumber == null || formNumber.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: DropdownButtonFormField(
                    style: Theme.of(context).textTheme.titleSmall,
                    initialValue: statusOrderCont.text.isEmpty
                        ? null
                        : statusOrderCont.text,
                    items: ["HOLDER", "NON HOLDER"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() {
                      statusOrderCont.text = val.toString();
                      servCommentCont.clear();
                    }),
                    decoration: InputDecoration(
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                      labelText: "Status Order",
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select !';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: DropdownButtonFormField(
                    style: Theme.of(context).textTheme.titleSmall,
                    initialValue: servCommentCont.text.isEmpty
                        ? null
                        : servCommentCont.text,
                    items:
                        (statusOrderCont.text == "HOLDER"
                                ? ["MISSING", "DAMAGE", "ADDITIONAL"]
                                : ["BUDGET", "NON BUDGET"])
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: statusOrderCont.text.isEmpty
                        ? null
                        : (val) => setState(
                            () => servCommentCont.text = val.toString(),
                          ),
                    decoration: InputDecoration(
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select !';
                      }
                      return null;
                    },
                  ),
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    IconButton(
                      onPressed: () {
                        selectDate(context, dateServNameCont, () {});
                      },
                      icon: Icon(Icons.date_range),
                    ),
                    Expanded(
                      child: TextFormFields(
                        labelTexts: 'Create Date',
                        textColor: Colors.black,
                        controllers: dateServNameCont,
                        validators: (dtCreateFm) {
                          if (dtCreateFm == null || dtCreateFm.isEmpty) {
                            return 'Required !';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormFields(
                  labelTexts: 'Serviceman',
                  textColor: Colors.black,
                  controllers: servNameCont,
                  validators: (cek) {
                    if (cek == null || cek.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                TextFormFields(
                  labelTexts: 'Supervisor / Foreman Approval',
                  textColor: Colors.black,
                  controllers: superiorAprdCont,
                  validators: (cmtReq) {
                    if (cmtReq == null || cmtReq.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                TextFormFields(
                  labelTexts: 'Supervisor / Foreman Comment',
                  textColor: Colors.black,
                  controllers: superiorCommentCont,
                  validators: (cmtSup) {
                    if (cmtSup == null || cmtSup.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                TextFormFields(
                  labelTexts: 'Check By',
                  textColor: Colors.black,
                  controllers: checkedByCont,
                  validators: (cmtReq) {
                    if (cmtReq == null || cmtReq.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    IconButton(
                      onPressed: () {
                        selectDate(context, dateCheckByCont, () {});
                      },
                      icon: Icon(Icons.date_range),
                    ),
                    Expanded(
                      child: TextFormFields(
                        labelTexts: 'Check Date',
                        textColor: Colors.black,
                        controllers: dateCheckByCont,
                        validators: (cmtReq) {
                          if (cmtReq == null || cmtReq.isEmpty) {
                            return 'Required !';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                TextFormFields(
                  labelTexts: 'Service Admin / Support Comment',
                  textColor: Colors.black,
                  controllers: sadminCommentCont,
                  validators: (cmtSup) {
                    if (cmtSup == null || cmtSup.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                TextFormFields(
                  labelTexts: 'Service Dept. Head Approval',
                  textColor: Colors.black,
                  controllers: sheadAprdCont,
                  validators: (cmtSup) {
                    if (cmtSup == null || cmtSup.isEmpty) {
                      return 'Required !';
                    }
                    return null;
                  },
                ),
                TextFormFields(
                  labelTexts: 'Service Dept. Head Comment',
                  textColor: Colors.black,
                  controllers: sheadCommentCont,
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
        ),
      ),
    );
  }
}
