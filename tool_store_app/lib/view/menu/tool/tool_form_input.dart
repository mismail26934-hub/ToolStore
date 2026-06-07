import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/navigation_helpers.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_utils.dart';
import 'package:tool_store_app/view/custom/picker/show_post_list_picker.dart';
import 'package:tool_store_app/view/var/var.dart';


bool _currentFormHasToolListItems(AppState state) {
  final idForm = idFormCont.text.trim();
  if (idForm.isEmpty) return false;
  return state.formsDetailState.formsDetail.any(
    (item) => item.idForm.trim() == idForm,
  );
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
      if (!st.isLoading) {
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
      final editFormId = idFormCont.text.trim();
      if (editFormId.isNotEmpty &&
          !store.state.formsDetailState.isLoadingToolDetail) {
        store.dispatch(
          getDataToolDetail(
            param: paramViewDataTool,
            idFormDetail: '',
            idFrom: editFormId,
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
            mergeForForm: true,
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
                : (isSuccess ? AppStrings.current.success : AppStrings.current.failedProcessData),
          ),
        ),
      );

      return isSuccess;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppStrings.current.failedProcessData),
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

  Future<void> _openToolUserPicker({
    required String userLevel,
    required List<PostList> initialUsers,
    required TextEditingController targetCont,
    required String dialogTitle,
    VoidCallback? onPicked,
  }) async {
    if (!mounted) return;
    await showToolUserPickerDialog(
      context: context,
      userLevel: userLevel,
      initialUsers: initialUsers,
      dialogTitle: dialogTitle,
      onSelected: (u) {
        if (!mounted) return;
        setState(() {
          targetCont.text = userPickerTitle(u);
          onPicked?.call();
        });
      },
    );
  }

  Widget _buildToolUserPickerField({
    required BuildContext context,
    required String userLevel,
    required List<PostList> users,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required String dialogTitle,
  }) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasValue = controller.text.trim().isNotEmpty;
        return FormField<String>(
          validator: (_) {
            if (controller.text.trim().isEmpty) {
              return AppStrings.current.required;
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
                      userLevel: userLevel,
                      initialUsers: users,
                      targetCont: controller,
                      dialogTitle: dialogTitle,
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
                                tooltip: context.s.remove,
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
                return context.s.requiredField;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _returnToToolList(BuildContext context) async {
    final formId = idFormCont.text.trim();
    final formNo = formNoCont.text.trim();
    if (Navigator.canPop(context)) {
      Navigator.pop(context, formId);
      return;
    }
    await PageRoutes.routeTool(
      context,
      initialExpandedFormId: formId.isNotEmpty ? formId : null,
      initialSearchQuery: formNo.isNotEmpty ? formNo : null,
      initialSearchField: 'formNo',
    );
  }

  void _showDeleteDialog() {
    ShowDialogBox.show(
      context: context,
      title: AppStrings.current.deleteFormTitle(formNoCont.text),
      contentTitle: AppStrings.current.confirmDeleteThisData,
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        if (!mounted) return;
        final isSuccess = await _submitFormData(paramDeleteDataForm);
        if (!mounted || !isSuccess) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return;
        }
        await PageRoutes.routeTool(context);
      },
      textNo: AppStrings.current.cancel,
      textYes: AppStrings.current.yes,
      textColorNo: clrBlack,
      textColorYes: clrOrange,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusOrderOptions = [
      context.s.statusHolder,
      context.s.statusNonHolder,
    ];
    final selectedStatusOrder =
        statusOrderOptions.contains(statusOrderCont.text)
        ? statusOrderCont.text
        : null;
    final categoryOptions = statusOrderCont.text == context.s.statusHolder
        ? [
            context.s.categoryMissing,
            context.s.categoryDamage,
            context.s.categoryAdditional,
          ]
        : [context.s.categoryBudget, context.s.categoryNonBudget];
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
              _isEditMode ? context.s.editDataTool : context.s.addDataTool,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: clrOrange,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formNoCont.text.isEmpty
                  ? context.s.toolRequestForm
                  : formNoCont.text,
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
            StoreConnector<AppState, bool>(
              converter: (store) => _currentFormHasToolListItems(store.state),
              builder: (context, hasToolListData) {
                final canDelete = !hasToolListData;
                return Padding(
                  padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
                  child: Opacity(
                    opacity: canDelete ? 1 : 0.45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: canDelete
                            ? clrOrange
                            : clrOrange.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: clrOrange.withValues(alpha: 0.05),
                        ),
                        boxShadow: canDelete
                            ? [
                                BoxShadow(
                                  color: clrOrange.withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        tooltip: canDelete
                            ? context.s.deleteDataTooltip
                            : context.s.cannotDeleteToolListHasData,
                        onPressed: canDelete ? _showDeleteDialog : null,
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: clrWhite,
                      ),
                    ),
                  ),
                );
              },
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
                  title: context.s.requestInformationSection,
                  icon: Icons.description_outlined,
                  children: [
                    TextFormFields(
                      labelTexts: context.s.formNumber,
                      textColor: Colors.black,
                      controllers: formNoCont,
                      validators: (formNumber) {
                        if (formNumber == null || formNumber.isEmpty) {
                          return context.s.requiredField;
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
                          context.s.statusOrder,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.s.pleaseSelect;
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
                        decoration: _dropdownDecoration(
                          context,
                          context.s.searchFieldCategory,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.s.pleaseSelect;
                          }
                          return null;
                        },
                      ),
                    ),
                    _buildDateField(
                      context: context,
                      label: context.s.createDate,
                      controller: dateServNameCont,
                    ),
                    StoreConnector<AppState, UserState>(
                      converter: (store) => store.state.userState,
                      builder: (context, userState) {
                        final users = List<PostList>.from(
                          dedupeUsersById(userState.users),
                        )..sort(
                            (a, b) => userPickerTitle(
                              a,
                            ).toLowerCase().compareTo(
                              userPickerTitle(b).toLowerCase(),
                            ),
                          );
                        final mechanicUsers = List<PostList>.from(
                          filterUsersByLevel(users, 'MECHANIC'),
                        );
                        final toolKeeperUsers = List<PostList>.from(
                          filterUsersByLevel(users, 'TOOL_KEEPER'),
                        );
                        if (userState.isLoading && users.isEmpty) {
                          return const AppShimmer(
                            child: Column(
                              children: [
                                FieldSkeleton(),
                                FieldSkeleton(),
                              ],
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
                                userLevel: 'MECHANIC',
                                users: mechanicUsers,
                                controller: servNameCont,
                                label: context.s.searchFieldServiceman,
                                placeholder: context.s.tapToPickServiceman,
                                dialogTitle: context.s.pickServicemanTitle,
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
                                userLevel: 'TOOL_KEEPER',
                                users: toolKeeperUsers,
                                controller: checkedByCont,
                                label: context.s.checkBy,
                                placeholder: context.s.tapToPickCheckBy,
                                dialogTitle: context.s.pickCheckByTitle,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    _buildDateField(
                      context: context,
                      label: context.s.checkDate,
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
                        title: context.s.confirmDataCorrectTitle,
                        contentTitle: _isEditMode
                            ? context.s.confirmEditData
                            : context.s.confirmSaveData,
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
                            await _returnToToolList(context);
                          }
                        },
                        textNo: context.s.cancel,
                        textYes: context.s.yes,
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
                          _isEditMode ? context.s.updateData : context.s.saveData,
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
