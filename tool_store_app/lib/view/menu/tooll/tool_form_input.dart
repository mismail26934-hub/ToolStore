import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolFormInput extends StatefulWidget {
  const ToolFormInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormInput> createState() => ToolFormInputState();
}

class ToolFormInputState extends State<ToolFormInput> {
  bool get _isEditMode => idFormCont.text.isNotEmpty;
  bool _isSubmitting = false;

  Future<bool> _submitFormData(String param) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    try {
      final responseList = await store.dispatch(
        getDataTool(
          param: param,
          idForm: idFormCont.text,
          formNo: formNoCont.text,
          formServName: servNameCont.text,
          formCheckBy: checkedByCont.text,
          formDateCheckBy: dateCheckByCont.text,
          formDateServName: dateServNameCont.text,
          formServComment: servCommentCont.text,
          formSuperiorAprd: superiorAprdCont.text,
          formSuperiorComment: superiorCommentCont.text,
          formSadminComment: sadminCommentCont.text,
          formMilestone: milestoneCont.text,
          formStatusOrder: statusOrderCont.text,
          formSheadAprd: sheadAprdCont.text,
          formSheadComment: sheadCommentCont.text,
          fromDateUpdate: dateUpdateCont.text,
          formUserUpdate: userUpdateCont.text,
        ),
      );

      final apiResponse = responseList is List && responseList.isNotEmpty
          ? responseList.last
          : null;
      final String responseValue = apiResponse?.valueResponse.toString() ?? "";
      final String responseMessage =
          apiResponse?.messageResponse.toString() ?? "";
      final bool isSuccess = responseValue == "1";

      if (isSuccess) {
        await store.dispatch(
          getDataTool(
            param: paramViewDataForm,
            idForm: '',
            formNo: '',
            formServName: '',
            formCheckBy: '',
            formDateCheckBy: '',
            formDateServName: '',
            formServComment: '',
            formSuperiorAprd: '',
            formSuperiorComment: '',
            formSadminComment: '',
            formMilestone: '',
            formStatusOrder: '',
            formSheadAprd: '',
            formSheadComment: '',
            fromDateUpdate: '',
            formUserUpdate: '',
          ),
        );
      }

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          content: Text(
            responseMessage.isNotEmpty
                ? responseMessage
                : (isSuccess ? "Success" : "Failed process data"),
          ),
        ),
      );

      return isSuccess;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed process data'),
        ),
      );
      return false;
    } finally {
      _isSubmitting = false;
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

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          height: 48,
          width: 48,
          child: OutlinedButton(
            onPressed: () => selectDate(context, controller, () {}),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Icon(Icons.date_range, color: clrOrange, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormFields(
            labelTexts: label,
            textColor: Colors.black,
            controllers: controller,
            validators: (value) {
              if (value == null || value.isEmpty) {
                return 'Required !';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    ShowDialogBox.show(
      context: context,
      title: 'Delete ${formNoCont.text}',
      contentTitle: ' Are you sure delete this data ?',
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        if (!mounted) return;
        final isSuccess = await _submitFormData(paramDeleteDataForm);
        if (!mounted || !isSuccess) return;
        await PageRoutes.routeTool(context);
      },
      textNo: 'Cancel',
      textYes: 'Yes',
      textColorNo: clrBlack,
      textColorYes: clrOrange,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusOrderOptions = ["HOLDER", "NON HOLDER"];
    final selectedStatusOrder =
        statusOrderOptions.contains(statusOrderCont.text)
        ? statusOrderCont.text
        : null;
    final categoryOptions = statusOrderCont.text == "HOLDER"
        ? ["MISSING", "DAMAGE", "ADDITIONAL"]
        : ["BUDGET", "NON BUDGET"];
    final selectedCategory = categoryOptions.contains(servCommentCont.text)
        ? servCommentCont.text
        : null;

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
              _isEditMode ? "Edit Data Tool" : "Add Data Tool",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: clrOrange,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formNoCont.text.isEmpty ? "Tool Request Form" : formNoCont.text,
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
          if (_isEditMode)
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
                  tooltip: "Delete data",
                  onPressed: _showDeleteDialog,
                  icon: const Icon(Icons.delete_outline_rounded),
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
                _buildSectionCard(
                  context: context,
                  title: 'Request Information',
                  icon: Icons.description_outlined,
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
                      child: DropdownButtonFormField<String>(
                        style: Theme.of(context).textTheme.labelMedium,
                        initialValue: selectedStatusOrder,
                        items: statusOrderOptions
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
                        onChanged: (val) => setState(() {
                          statusOrderCont.text = val.toString();
                          servCommentCont.clear();
                        }),
                        decoration: _dropdownDecoration(
                          context,
                          "Status Order",
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
                      child: DropdownButtonFormField<String>(
                        style: Theme.of(context).textTheme.labelMedium,
                        initialValue: selectedCategory,
                        items: categoryOptions
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
                        onChanged: statusOrderCont.text.isEmpty
                            ? null
                            : (val) => setState(
                                () => servCommentCont.text = val.toString(),
                              ),
                        decoration: _dropdownDecoration(context, "Category"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select !';
                          }
                          return null;
                        },
                      ),
                    ),
                    _buildDateField(
                      context: context,
                      label: 'Create Date',
                      controller: dateServNameCont,
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
                    _buildDateField(
                      context: context,
                      label: 'Check Date',
                      controller: dateCheckByCont,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(paddingForm),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 2,
                      shadowColor: clrBlack.withValues(alpha: 0.18),
                      backgroundColor: _isEditMode ? clrOrange : clrBtnPrimary,
                      foregroundColor: clrBtnPrimaryFgBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ShowDialogBox.show(
                        context: context,
                        title: 'Please make sure all data is correct',
                        contentTitle: _isEditMode
                            ? ' Are you sure edit data ?'
                            : 'Are you sure save data ?',
                        onPressedNo: (dialogContext) {
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                        onPressedYes: (dialogContext) async {
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                          if (!mounted) return;
                          if (formKey.currentState!.validate()) {
                            final actionParam = _isEditMode
                                ? paramEditDataForm
                                : paramAddDataForm;
                            final isSuccess = await _submitFormData(
                              actionParam,
                            );
                            if (!mounted || !isSuccess) return;
                            await PageRoutes.routeTool(context);
                          }
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
                          _isEditMode ? Icons.save : Icons.save_outlined,
                          size: btnFontSize + 4,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isEditMode ? 'Update Data' : 'Save Data',
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
