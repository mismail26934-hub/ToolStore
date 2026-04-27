import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart'; // Pastikan formKey ada di sini

class ToolFormMultipleInput extends StatefulWidget {
  const ToolFormMultipleInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormMultipleInput> createState() => _ToolFormMultipleInputState();
}

class _ToolFormMultipleInputState extends State<ToolFormMultipleInput> {
  // Gunakan underscore (_) untuk menandakan variabel private
  // final List<TextEditingController> _controllers = [];
  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow() {
    setState(() {
      idFormToolCont.add(TextEditingController());
      idFormDetailCont.add(TextEditingController());
      formCommentCont.add(TextEditingController());
      pnGroupCont.add(TextEditingController());
      pnDescCont.add(TextEditingController());
      qtyCont.add(TextEditingController());
      explanCont.add(TextEditingController());
      actionNoteCont.add(TextEditingController());
      valTypeCont.add(TextEditingController());
      partValueCont.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    // Fungsi pembantu agar tidak menulis satu-satu
    void disposeList(List<TextEditingController> list) {
      for (var controller in list) {
        controller.dispose();
      }
      list.clear(); // Bersihkan list agar tidak duplikat saat buka kembali
    }

    disposeList(idFormToolCont);
    disposeList(idFormDetailCont);
    disposeList(formCommentCont);
    disposeList(pnGroupCont);
    disposeList(pnDescCont);
    disposeList(qtyCont);
    disposeList(explanCont);
    disposeList(actionNoteCont);
    disposeList(valTypeCont);
    disposeList(partValueCont);

    super.dispose();
  }

  void _removeRow(int i) {
    if (idFormToolCont.length > 1) {
      setState(() {
        idFormToolCont[i].dispose();
        idFormToolCont.removeAt(i);

        idFormDetailCont[i].dispose();
        idFormDetailCont.removeAt(i);

        formCommentCont[i].dispose();
        formCommentCont.removeAt(i);

        pnGroupCont[i].dispose();
        pnGroupCont.removeAt(i);

        pnDescCont[i].dispose();
        pnDescCont.removeAt(i);

        qtyCont[i].dispose();
        qtyCont.removeAt(i);

        explanCont[i].dispose();
        explanCont.removeAt(i);

        actionNoteCont[i].dispose();
        actionNoteCont.removeAt(i);

        valTypeCont[i].dispose();
        valTypeCont.removeAt(i);

        partValueCont[i].dispose();
        partValueCont.removeAt(i);
      });
    }
  }

  void _submitData() {
    if (formKey.currentState!.validate()) {
      List<Map<String, dynamic>> allItems = [];
      for (var i = 0; i < idFormToolCont.length; i++) {
        allItems.add({
          "pn_group": pnGroupCont[i].text,
          "qty": qtyCont[i].text,
          "description": pnDescCont[i].text,
          "explanation": explanCont[i].text,
          "action_note": actionNoteCont[i].text,
        });
      }
      print("Data siap kirim ke API: $allItems");
      // Lanjutkan dengan http.post ke PHP di sini
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subtitle),
        actions: [
          widget.subtitle == "ADD DATA"
              ? IconButton(onPressed: _addRow, icon: Icon(Icons.add_circle))
              : Container(),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: widget.subtitle == "ADD DATA"
                      ? idFormToolCont.length
                      : 1,
                  itemBuilder: (context, i) {
                    return Card(
                      color: clrWhite,
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.subtitle == "ADD DATA"
                                      ? "ITEM ${i + 1}"
                                      : "ITEM ${itemCont.text}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: widget.subtitle == "ADD DATA"
                                      ? () {
                                          _removeRow(i);
                                        }
                                      : () {
                                          ShowDialogBox.show(
                                            context: context,
                                            title:
                                                'Delete ${pnGroupCont[i].text}',
                                            contentTitle:
                                                ' Are you sure delete this data ?',
                                            onPressedNo: () {
                                              if (!context.mounted) return;
                                              Navigator.pop(context);
                                            },
                                            onPressedYes: () async {
                                              // Tutup dialog dulu
                                              Navigator.pop(context);
                                              if (!context.mounted) return;
                                            },
                                            textNo: 'Cancel',
                                            textYes: 'Yes',
                                            textColorNo: clrBlack,
                                            textColorYes: clrOrange,
                                          );
                                        },
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormFields(
                                    labelTexts: 'PN GROUP CONSIST',
                                    textColor: Colors.black,
                                    controllers: pnGroupCont[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormFields(
                                    labelTexts: 'QTY',
                                    textColor: Colors.black,
                                    controllers: qtyCont[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormFields(
                                    labelTexts: 'DESCRIPTION',
                                    textColor: Colors.black,
                                    controllers: pnDescCont[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormFields(
                                    labelTexts: 'EXPLANATION',
                                    textColor: Colors.black,
                                    controllers: explanCont[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormFields(
                                    labelTexts: 'ACTION NOTE (A/B/C/D)',
                                    textColor: Colors.black,
                                    controllers: actionNoteCont[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
                    ShowDialogBox.show(
                      context: context,
                      title: 'Please make sure all data is correct',
                      contentTitle: widget.subtitle == "ADD DATA"
                          ? 'Are you sure save data ?'
                          : ' Are you sure edit data ?',
                      onPressedNo: () {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      onPressedYes: () async {
                        // Tutup dialog dulu
                        Navigator.pop(context);
                        _submitData();
                        if (!context.mounted) return;
                      },
                      textNo: 'Cancel',
                      textYes: 'Yes',
                      textColorNo: clrBlack,
                      textColorYes: clrOrange,
                    );
                  },
                  child: Text(
                    widget.subtitle == "ADD DATA" ? 'SAVE' : 'UPDATE',
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
    );
  }
}
