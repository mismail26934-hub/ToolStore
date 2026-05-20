import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';

String _userPickLabel(PostList u) {
  final n = u.namaUser.trim();
  if (n.isNotEmpty) return n;
  final un = u.username.trim();
  if (un.isNotEmpty) return un;
  return u.idUsers.trim();
}

List<PostList> _dedupeUsersById(List<PostList> list) {
  final seen = <String>{};
  final out = <PostList>[];
  for (final u in list) {
    final id = u.idUsers.trim();
    if (id.isEmpty) continue;
    if (seen.contains(id)) continue;
    seen.add(id);
    out.add(u);
  }
  return out;
}

List<PostList> _filterUserPickerRows(List<PostList> list, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  return list.where((u) {
    return u.namaUser.toLowerCase().contains(q) ||
        u.username.toLowerCase().contains(q) ||
        u.idUsers.toLowerCase().contains(q);
  }).toList();
}

class _ToolUserPickerDialog extends StatefulWidget {
  const _ToolUserPickerDialog({
    required this.users,
    required this.title,
    required this.onSelected,
  });

  final List<PostList> users;
  final String title;
  final ValueChanged<PostList> onSelected;

  @override
  State<_ToolUserPickerDialog> createState() => _ToolUserPickerDialogState();
}

class _ToolUserPickerDialogState extends State<_ToolUserPickerDialog> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deduped = _dedupeUsersById(widget.users);
    final filtered = List<PostList>.from(
      _filterUserPickerRows(deduped, _search.text),
    )..sort(
        (a, b) => _userPickLabel(
          a,
        ).toLowerCase().compareTo(_userPickLabel(b).toLowerCase()),
      );
    final h = min(MediaQuery.sizeOf(context).height * 0.72, 520.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Container(
        width: min(MediaQuery.sizeOf(context).width - 40, 420),
        height: h,
        decoration: BoxDecoration(
          color: context.pageBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
              decoration: BoxDecoration(
                color: context.cardSurface,
                border: Border(bottom: BorderSide(color: context.cardBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: clrOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.person_search_rounded,
                      color: clrOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cari lalu ketuk salah satu nama',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: context.chipNeutralBg,
                      foregroundColor: context.chipNeutralFg,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Nama atau username…',
                  prefixIcon: Icon(Icons.search_rounded, color: clrOrange),
                  filled: true,
                  fillColor: context.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: clrOrange, width: 1.6),
                  ),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              size: 48,
                              color: context.iconMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.users.isEmpty
                                  ? 'Belum ada data user'
                                  : 'Tidak ada hasil untuk pencarian ini',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final u = filtered[i];
                        final title = _userPickLabel(u);
                        final un = u.username.trim();
                        final showUserLine = un.isNotEmpty &&
                            un.toLowerCase() != title.toLowerCase();
                        return Material(
                          color: context.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 0,
                          child: InkWell(
                            onTap: () => widget.onSelected(u),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.cardBorder),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: clrOrange.withValues(
                                      alpha: 0.14,
                                    ),
                                    foregroundColor: clrOrange,
                                    radius: 22,
                                    child: Text(
                                      title.isNotEmpty
                                          ? title.characters.first.toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        if (showUserLine) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '@$un',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: context.iconMuted,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: context.iconMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToolFormInput extends StatefulWidget {
  const ToolFormInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormInput> createState() => ToolFormInputState();
}

class ToolFormInputState extends State<ToolFormInput> {
  bool get _isEditMode => idFormCont.text.isNotEmpty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = store.state.userState;
      if (st.users.isEmpty && !st.isLoading) {
        store.dispatch(
          getDataUser(
            param: paramViewDataUser,
            idUsers: '',
            username: '',
            password: '',
            namaUser: '',
            foto: '',
            idTU: '',
            noTelp: '',
            token: '',
            level: '',
            status: '',
            superiorId: '',
            limit: kUserFullFetchLimit,
          ),
        );
      }
    });
  }

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

  Future<void> _openToolUserPicker(
    List<PostList> raw, {
    required TextEditingController targetCont,
    required String dialogTitle,
    required String emptyDataMessage,
    VoidCallback? onPicked,
  }) async {
    if (!mounted) return;
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emptyDataMessage)),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _ToolUserPickerDialog(
        users: raw,
        title: dialogTitle,
        onSelected: (u) {
          Navigator.pop(ctx);
          if (!mounted) return;
          setState(() {
            targetCont.text = _userPickLabel(u);
            onPicked?.call();
          });
        },
      ),
    );
  }

  Widget _buildToolUserPickerField({
    required BuildContext context,
    required List<PostList> users,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required String dialogTitle,
    required String emptyDataMessage,
  }) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasValue = controller.text.trim().isNotEmpty;
        return FormField<String>(
          validator: (_) {
            if (controller.text.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openToolUserPicker(
                      users,
                      targetCont: controller,
                      dialogTitle: dialogTitle,
                      emptyDataMessage: emptyDataMessage,
                      onPicked: () => field.didChange(
                        controller.text.trim().isNotEmpty
                            ? controller.text
                            : null,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: _dropdownDecoration(context, label).copyWith(
                        errorText: field.errorText,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasValue)
                              IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 22,
                                ),
                                onPressed: () => setState(() {
                                  controller.clear();
                                  field.didChange(null);
                                }),
                                tooltip: 'Hapus',
                              ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.manage_search_rounded,
                                color: clrOrange,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Text(
                        hasValue ? controller.text : placeholder,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: hasValue ? null : context.iconMuted,
                          fontWeight: hasValue
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
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
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder),
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
              side: BorderSide(color: context.cardBorder),
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
              bottom: BorderSide(color: context.cardBorder, width: 1),
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
                    StoreConnector<AppState, UserState>(
                      converter: (store) => store.state.userState,
                      builder: (context, userState) {
                        final users = List<PostList>.from(
                          _dedupeUsersById(userState.users),
                        )..sort(
                            (a, b) => _userPickLabel(
                              a,
                            ).toLowerCase().compareTo(
                              _userPickLabel(b).toLowerCase(),
                            ),
                          );
                        if (userState.isLoading && users.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(8),
                              color: clrOrange,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: _buildToolUserPickerField(
                                context: context,
                                users: users,
                                controller: servNameCont,
                                label: 'Serviceman',
                                placeholder: 'Ketuk untuk pilih serviceman',
                                dialogTitle: 'Pilih serviceman',
                                emptyDataMessage: 'Data user belum dimuat',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: _buildToolUserPickerField(
                                context: context,
                                users: users,
                                controller: checkedByCont,
                                label: 'Check By',
                                placeholder: 'Ketuk untuk pilih check by',
                                dialogTitle: 'Pilih check by',
                                emptyDataMessage: 'Data user belum dimuat',
                              ),
                            ),
                          ],
                        );
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
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (!mounted) return;
                          if (formKey.currentState!.validate()) {
                            final actionParam = _isEditMode
                                ? paramEditDataForm
                                : paramAddDataForm;
                            final isSuccess = await _submitFormData(
                              actionParam,
                            );
                            if (!mounted || !isSuccess) return;
                            if (!context.mounted) return;
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
