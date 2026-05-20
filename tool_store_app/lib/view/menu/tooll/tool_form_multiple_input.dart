import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolFormMultipleInput extends StatefulWidget {
  const ToolFormMultipleInput({
    super.key,
    required this.subtitle,
    this.parentIdForm = '',
  });
  final String subtitle;
  final String parentIdForm;

  @override
  State<ToolFormMultipleInput> createState() => _ToolFormMultipleInputState();
}

class _ToolFormMultipleInputState extends State<ToolFormMultipleInput> {
  bool get _isAddMode => widget.subtitle == "ADD DATA";
  bool _isSubmitting = false;

  static const List<String> _actionNoteOptions = [
    // A  = Order Small Tool Account
    'A  = Order Small Tool Account',
    // B = Order Rep & Maint Account
    'B = Order Rep & Maint Account',
    // C = Charge Personal Account
    'C = Charge Personal Account',
    // D = Charge to ______________
    'D = Charge to ...',
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
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
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
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        if (!mounted) return;
      },
      textNo: 'Cancel',
      textYes: 'Yes',
      textColorNo: clrBlack,
      textColorYes: clrOrange,
    );
  }

  Future<void> _seedToolDetailMeta() async {
    final parentId = widget.parentIdForm.trim().isNotEmpty
        ? widget.parentIdForm.trim()
        : parentIdFormForToolDetail.trim();
    if (parentId.isNotEmpty && parentId != '0') {
      parentIdFormForToolDetail = parentId;
      for (final c in idFormToolCont) {
        if (c.text.trim().isEmpty || c.text.trim() == '0') {
          c.text = parentId;
        }
      }
    }

    if (formDetailDateCont.text.trim().isEmpty) {
      formDetailDateCont.text = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());
    }

    var userId = formDetailUserCont.text.trim();
    if (userId.isEmpty) {
      userId = idUsersApp.trim();
    }
    if (userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = (prefs.getString('idUsersApp') ?? '').trim();
      if (userId.isNotEmpty) {
        idUsersApp = userId;
      }
    }
    if (userId.isNotEmpty) {
      formDetailUserCont.text = userId;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.parentIdForm.trim().isNotEmpty) {
      parentIdFormForToolDetail = widget.parentIdForm.trim();
    }
    final bool hasSeededRows =
        idFormToolCont.isNotEmpty || idFormDetailCont.isNotEmpty;
    if (_isAddMode && !hasSeededRows) {
      _addRow();
    } else if (!_isAddMode && idFormDetailCont.isEmpty) {
      _addRow();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _seedToolDetailMeta());
  }

  int _resolveSubmitIndex(int fallbackIndex) {
    if (_isAddMode) return fallbackIndex;
    final idx = idFormDetailCont.indexWhere((c) => c.text.trim().isNotEmpty);
    return idx >= 0 ? idx : fallbackIndex;
  }

  String _resolveParentIdForm(int index) {
    final widgetParent = widget.parentIdForm.trim();
    if (widgetParent.isNotEmpty && widgetParent != '0') return widgetParent;
    final rowId = idFormToolCont[index].text.trim();
    if (rowId.isNotEmpty && rowId != '0') return rowId;
    if (parentIdFormForToolDetail.isNotEmpty &&
        parentIdFormForToolDetail != '0') {
      return parentIdFormForToolDetail;
    }
    final headerId = idFormCont.text.trim();
    if (headerId.isNotEmpty && headerId != '0') return headerId;
    return '';
  }

  Future<Map<String, String>> _resolveToolDetailMeta(int index) async {
    final submitIndex = _resolveSubmitIndex(index);
    final idForm = _resolveParentIdForm(submitIndex);
    if (idForm.isEmpty) {
      throw Exception('ID form tidak valid. Buka ulang dari daftar order.');
    }

    var formDetailDate = formDetailDateCont.text.trim();
    if (formDetailDate.isEmpty) {
      formDetailDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    }

    var formDetailUser = formDetailUserCont.text.trim();
    if (formDetailUser.isEmpty) {
      formDetailUser = idUsersApp.trim();
      if (formDetailUser.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        formDetailUser = (prefs.getString('idUsersApp') ?? '').trim();
      }
    }
    if (formDetailUser.isEmpty) {
      throw Exception('User login tidak ditemukan. Silakan login ulang.');
    }

    return {
      'idForm': idForm,
      'formDetailDate': formDetailDate,
      'formDetailUser': formDetailUser,
    };
  }

  void _addRow() {
    final parentIdForm = parentIdFormForToolDetail.isNotEmpty
        ? parentIdFormForToolDetail
        : (idFormToolCont.isNotEmpty ? idFormToolCont.first.text.trim() : '');
    setState(() {
      idFormToolCont.add(TextEditingController(text: parentIdForm));
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

  Future<String> _submitRowToApi({
    required int index,
    required String param,
  }) async {
    final submitIndex = _resolveSubmitIndex(index);
    final meta = await _resolveToolDetailMeta(index);
    idFormToolCont[submitIndex].text = meta['idForm']!;
    formDetailDateCont.text = meta['formDetailDate']!;
    formDetailUserCont.text = meta['formDetailUser']!;
    final ToolDetailFetchResult result =
        await StoreProvider.of<AppState>(context).dispatch(
          getDataToolDetail(
            param: param,
            idFormDetail: idFormDetailCont[submitIndex].text.trim(),
            idFrom: meta['idForm']!,
            formComment: formCommentCont[submitIndex].text.trim(),
            pnGroup: pnGroupCont[submitIndex].text.trim(),
            pnDesc: pnDescCont[submitIndex].text.trim(),
            qty: qtyCont[submitIndex].text.trim(),
            explan: explanCont[submitIndex].text.trim(),
            actionNote: actionNoteCont[submitIndex].text.trim().isEmpty
                ? ''
                : actionNoteCont[submitIndex].text.trim().substring(0, 1),
            valType: valTypeCont[submitIndex].text.trim(),
            partValue: partValueCont[submitIndex].text.trim(),
            formDetailDate: meta['formDetailDate']!,
            formDetailUser: meta['formDetailUser']!,
          ),
        );

    if (result.statusValue != null && result.statusValue != '1') {
      throw Exception(result.serverMessage ?? 'Proses gagal');
    }
    return result.serverMessage ??
        (_isAddMode ? 'ADD DATA TOOL SUCCESS' : 'EDIT DATA TOOL SUCCESS');
  }

  Future<void> _submitData() async {
    if (_isSubmitting || !formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      String successMessage = _isAddMode
          ? 'Data berhasil ditambahkan'
          : 'Data berhasil diupdate';
      for (var i = 0; i < idFormToolCont.length; i++) {
        successMessage = await _submitRowToApi(
          index: i,
          param: _isAddMode ? paramAddDataTool : paramEditDataTool,
        );
      }

      if (!mounted) return;
      await StoreProvider.of<AppState>(context).dispatch(
        getDataToolDetail(
          param: paramViewDataTool,
          idFormDetail: '',
          idFrom: '',
          formComment: '',
          pnGroup: '',
          pnDesc: '',
          qty: '',
          explan: '',
          actionNote: '',
          valType: '',
          partValue: '',
          formDetailDate: '',
          formDetailUser: '',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: clrGreen, content: Text(successMessage)),
      );
      Navigator.maybePop(context, true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(backgroundColor: clrRed, content: Text(msg)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  InputDecoration _dropdownDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.labelMedium,
      filled: true,
      fillColor: context.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.cardBorder),
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
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: context.appBarSurface,
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
              _isAddMode ? "Add Tool Items " : "Edit Tool Item",
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
              bottom: BorderSide(color: context.cardBorder, width: 1),
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
                  color: context.cardSurface,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: context.cardBorder,
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
                          ? "Item ${i + 1} - ${idFormToolCont[i].text}"
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
                                      () =>
                                          valTypeCont[i].text = val.toString(),
                                    ),
                                    decoration: _dropdownDecoration(
                                      context,
                                      "CAT / LOCAL VENDOR",
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
                                      try {
                                        return _actionNoteOptions.firstWhere(
                                          (element) => element.startsWith(t),
                                        );
                                      } catch (e) {
                                        return null; // Jika tidak ada yang cocok, kembalikan null
                                      }
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
                        onPressedNo: (dialogContext) {
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                        onPressedYes: (dialogContext) async {
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                          await _submitData();
                          if (!mounted) return;
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
                          _isSubmitting
                              ? 'Processing...'
                              : (_isAddMode ? 'Save Data' : 'Update Data'),
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
