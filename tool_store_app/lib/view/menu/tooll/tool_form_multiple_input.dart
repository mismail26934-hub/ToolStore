import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolFormMultipleInput extends StatefulWidget {
  const ToolFormMultipleInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormMultipleInput> createState() => _ToolFormMultipleInputState();
}

class _ToolFormMultipleInputState extends State<ToolFormMultipleInput> {
  bool get _isAddMode => widget.subtitle == "ADD DATA";

  static const List<String> _actionNoteOptions = [
    'A = Order Small Tool Account',
    'B = Order Rep & Maint Account',
    'C = Charge Personal Account',
    'D = Charge to ______________',
  ];

  static const List<String> _actionTypeOptions = ['CAT', 'VENDOR'];

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: clrOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: clrOrange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _showDeleteDialog(int i) {
    ShowDialogBox.show(
      context: context,
      title: 'Delete ${pnGroupCont[i].text}',
      contentTitle: ' Are you sure delete this data ?',
      onPressedNo: () {
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      onPressedYes: () async {
        Navigator.pop(context);
        if (!context.mounted) return;
      },
      textNo: 'Cancel',
      textYes: 'Yes',
      textColorNo: clrBlack,
      textColorYes: clrOrange,
    );
  }

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
    void disposeList(List<TextEditingController> list) {
      for (var controller in list) {
        controller.dispose();
      }
      list.clear();
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
      debugPrint("Data siap kirim ke API: $allItems");
    }
  }

  InputDecoration _dropdownDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.labelMedium,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: clrOrange, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: clrWhite,
        foregroundColor: clrOrange,
        toolbarHeight: 84,
        titleSpacing: 18,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: clrOrange.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: clrOrange,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isAddMode ? "Add Tool Items" : "Edit Tool Item",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: clrOrange,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _isAddMode ? "Multiple Detail Input" : "Single Detail Input",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: clrOrange.withValues(alpha: 0.75),
                letterSpacing: 0.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                clrOrange.withValues(alpha: 0.14),
                clrOrange.withValues(alpha: 0.05),
                clrOrange.withValues(alpha: 0.14),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
        ),
        actions: [
          if (_isAddMode)
            Padding(
              padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: clrOrange,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: clrOrange.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: clrOrange.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  tooltip: "Add item row",
                  onPressed: _addRow,
                  icon: const Icon(Icons.add_rounded),
                  color: clrWhite,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _isAddMode ? idFormToolCont.length : 1,
                  itemBuilder: (context, i) {
                    return _buildSectionCard(
                      context: context,
                      title: _isAddMode
                          ? "Item ${i + 1}"
                          : "Item ${itemCont.text}",
                      icon: Icons.inventory_2_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              onPressed: _isAddMode
                                  ? () => _removeRow(i)
                                  : () => _showDeleteDialog(i),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
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
                              const SizedBox(width: 8),
                              Expanded(
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
                          TextFormFields(
                            labelTexts: 'DESCRIPTION',
                            textColor: Colors.black,
                            controllers: pnDescCont[i],
                            validators: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Required !'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormFields(
                                  labelTexts: 'PRICE',
                                  textColor: Colors.black,
                                  controllers: partValueCont[i],
                                  validators: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Required !'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 1.0,
                                    right: 1.0,
                                    top: 5.0,
                                    bottom: 5.0,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                    initialValue: () {
                                      final t = valTypeCont[i].text;
                                      if (t.isEmpty) return null;
                                      return _actionTypeOptions.contains(t)
                                          ? t
                                          : null;
                                    }(),
                                    items: _actionTypeOptions
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelMedium,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) => setState(
                                      () => actionNoteCont[i].text = val
                                          .toString(),
                                    ),
                                    decoration: _dropdownDecoration(
                                      context,
                                      "ACTION NOTE (A/B/C/D)",
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select !';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
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
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 1.0,
                                    right: 1.0,
                                    top: 5.0,
                                    bottom: 5.0,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                    initialValue: () {
                                      final t = actionNoteCont[i].text;
                                      if (t.isEmpty) return null;
                                      return _actionNoteOptions.contains(t)
                                          ? t
                                          : null;
                                    }(),
                                    items: _actionNoteOptions
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelMedium,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) => setState(
                                      () => actionNoteCont[i].text = val
                                          .toString(),
                                    ),
                                    decoration: _dropdownDecoration(
                                      context,
                                      "ACTION NOTE (A/B/C/D)",
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select !';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(paddingForm),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 2,
                      shadowColor: clrBlack.withValues(alpha: 0.18),
                      backgroundColor: _isAddMode ? clrBtnPrimary : clrOrange,
                      foregroundColor: clrBtnPrimaryFgBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ShowDialogBox.show(
                        context: context,
                        title: 'Please make sure all data is correct',
                        contentTitle: _isAddMode
                            ? 'Are you sure save data ?'
                            : ' Are you sure edit data ?',
                        onPressedNo: () {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        onPressedYes: () async {
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAddMode ? Icons.save_outlined : Icons.save,
                          size: btnFontSize + 4,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAddMode ? 'Save Data' : 'Update Data',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: btnFontSize,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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
