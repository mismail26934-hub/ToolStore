import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_utils.dart';
import 'package:tool_store_app/view/custom/picker/show_post_list_picker.dart';
import 'package:tool_store_app/view/var/var.dart';

class UserFormInput extends StatefulWidget {
  const UserFormInput({
    super.key,
    required this.title,
    required this.onPressTailing,
    this.levelReadOnly = false,
    this.popOnSuccess = false,
  });
  final String title;
  final void Function()? onPressTailing;
  final bool levelReadOnly;
  final bool popOnSuccess;

  @override
  State<UserFormInput> createState() => _UserFormInputState();
}

class _UserFormInputState extends State<UserFormInput> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool get _isEditMode => iduserFormCont.text.isNotEmpty;

  Future<void> _clearSessionAndRouteLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    PageRoutes.routeLoginFast(context);
  }

  Future<void> submitData(String params) async {
    final isDelete = params == paramDeleteDataUser;
    if (!isDelete && !_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final responseList = await store.dispatch(
        getDataUser(
          param: params,
          idUsers: iduserFormCont.text.trim(),
          username: usernameFormCont.text.trim(),
          password: passwordFormCont.text,
          namaUser: namaFormCont.text.trim(),
          foto: '',
          idTU: tuidFormCont.text.trim(),
          noTelp: telpFormCont.text.trim(),
          token: '',
          level: levelFormCont.text.trim(),
          status: statusFormCont.text.trim(),
          superiorId: superiorIdFormCont.text.trim(),
        ),
      );

      if (!mounted) return;

      PostList? apiEnvelope;
      if (responseList is List && responseList.isNotEmpty) {
        for (var i = responseList.length - 1; i >= 0; i--) {
          final row = responseList[i];
          if (row is PostList && row.valueResponse.trim().isNotEmpty) {
            apiEnvelope = row;
            break;
          }
        }
        apiEnvelope ??= responseList.last is PostList
            ? responseList.last as PostList
            : null;
      }

      final String responseValue = apiEnvelope?.valueResponse.trim() ?? '';
      final String responseMessage = apiEnvelope?.messageResponse.trim() ?? '';
      final bool isSuccess = responseValue == '1';

      if (isSuccess) {
        if (!mounted) return;
        final msg = responseMessage.isNotEmpty
            ? responseMessage
            : (isDelete
                  ? AppStrings.current.userDeletedSuccess
                  : (_isEditMode
                        ? AppStrings.current.userUpdatedSuccess
                        : AppStrings.current.userAddedSuccess));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.green, content: Text(msg)),
        );
        if (params == paramEditDataUser) {
          final prefs = await SharedPreferences.getInstance();
          final currentLevel = (prefs.getString('level') ?? '')
              .trim()
              .toUpperCase();
          if (currentLevel != 'SUPERADMIN') {
            await _clearSessionAndRouteLogin();
            return;
          }
        }
        if (!mounted) return;
        if (widget.popOnSuccess || Navigator.canPop(context)) {
          Navigator.of(context).pop(true);
        } else {
          await PageRoutes.routeUser(context);
        }
      } else {
        if (!mounted) return;
        final msg = responseMessage.isNotEmpty
            ? responseMessage
            : AppStrings.current.userProcessFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(msg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          ...children,
        ],
      ),
    );
  }

  void _applySuperiorFromPost(PostList s) {
    namaSuperiorFormCont.text = superiorPickerTitle(s);
    superiorIdFormCont.text = s.superiorId.trim();
  }

  Future<void> _openSuperiorPicker({
    List<PostList> initialSuperiors = const [],
    void Function()? onSuperiorChanged,
  }) async {
    if (!mounted) return;
    await showSuperiorPickerDialog(
      context: context,
      initialSuperiors: initialSuperiors,
      onSelected: (s) {
        if (!mounted) return;
        setState(() {
          _applySuperiorFromPost(s);
          onSuperiorChanged?.call();
        });
      },
    );
  }

  void _showDeleteDialog() {
    ShowDialogBox.show(
      context: context,
      title: context.s.warning,
      contentTitle: context.s.confirmDeleteData,
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        await submitData(paramDeleteDataUser);
      },
      textNo: context.s.back,
      textYes: context.s.yes,
      textColorNo: clrBlack,
      textColorYes: clrRed,
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
              _isEditMode ? context.s.editDataUser : context.s.addDataUser,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: clrOrange,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              namaFormCont.text.isEmpty
                  ? context.s.userAccountForm
                  : namaFormCont.text,
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
          if (_isEditMode && !widget.levelReadOnly)
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
                  tooltip: context.s.deleteDataTooltip,
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
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        context: context,
                        title: context.s.userInformationSection,
                        icon: Icons.person_outline_rounded,
                        children: [
                          _buildTextField(usernameFormCont, context.s.username),
                          const SizedBox(height: 10),
                          _buildTextField(
                            passwordFormCont,
                            context.s.password,
                            isPassword: true,
                            showClearButton: true,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            confirmPasswordFormCont,
                            context.s.confirmPassword,
                            isPassword: true,
                            showClearButton: true,
                            confirmMatchesPassword: true,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(namaFormCont, context.s.fieldName),
                          const SizedBox(height: 10),
                          _buildTextField(
                            telpFormCont,
                            context.s.fieldPhone,
                            isPhone: true,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context: context,
                        title: context.s.accessAndRoleSection,
                        icon: Icons.verified_user_outlined,
                        children: [
                          _buildTextField(tuidFormCont, context.s.fieldId),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            style: Theme.of(context).textTheme.labelMedium,
                            initialValue: levelFormCont.text.isEmpty
                                ? null
                                : levelFormCont.text,
                            items:
                                [
                                      "USER",
                                      "SUPERADMIN",
                                      "MECHANIC",
                                      "SERVICE_ADMIN",
                                      "SUPERIOR",
                                      "HEAD_SERVICE",
                                      "TOOL_KEEPER",
                                      "COUNTER",
                                      "GA",
                                      "WH",
                                    ]
                                    .map(
                                      (e) => DropdownMenuItem<String>(
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
                            onChanged: widget.levelReadOnly
                                ? null
                                : (val) => setState(
                                    () => levelFormCont.text = val ?? '',
                                  ),
                            decoration: _dropdownDecoration(context, context.s.fieldLevel),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.s.pleaseSelectLevel;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          StoreConnector<AppState, SuperriorState>(
                            converter: (s) => s.state.superriorState,
                            builder: (context, supState) {
                              final hasValue = namaSuperiorFormCont.text
                                  .trim()
                                  .isNotEmpty;
                              return FormField<String>(
                                validator: (_) {
                                  if (namaSuperiorFormCont.text
                                      .trim()
                                      .isEmpty) {
                                    return context.s.required;
                                  }
                                  return null;
                                },
                                builder: (field) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _openSuperiorPicker(
                                            initialSuperiors:
                                                supState.superriorS,
                                            onSuperiorChanged: () =>
                                                field.didChange(
                                                  superiorIdFormCont.text,
                                                ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: InputDecorator(
                                            decoration:
                                                _dropdownDecoration(
                                                  context,
                                                  context.s.fieldSuperior,
                                                ).copyWith(
                                                  errorText: field.errorText,
                                                  suffixIcon: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (hasValue)
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.clear_rounded,
                                                            size: 22,
                                                          ),
                                                          onPressed: () =>
                                                              setState(() {
                                                                namaSuperiorFormCont
                                                                    .clear();
                                                                superiorIdFormCont
                                                                    .clear();
                                                                field.didChange(
                                                                  null,
                                                                );
                                                              }),
                                                          tooltip: context.s.remove,
                                                        ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 8,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .manage_search_rounded,
                                                          color: clrOrange,
                                                          size: 26,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            child: Text(
                                              hasValue
                                                  ? namaSuperiorFormCont.text
                                                  : context.s.tapToPickSuperior,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: hasValue
                                                        ? null
                                                        : context.iconMuted,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
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
                                  await submitData(
                                    _isEditMode
                                        ? paramEditDataUser
                                        : paramAddDataUser,
                                  );
                                },
                                textNo: context.s.cancel,
                                textYes: context.s.yes,
                                textColorNo: clrBlack,
                                textColorYes: clrOrange,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            elevation: 2,
                            shadowColor: clrBlack.withValues(alpha: 0.18),
                            backgroundColor: _isEditMode
                                ? clrOrange
                                : Colors.blueAccent,
                            foregroundColor: clrWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isEditMode ? Icons.save : Icons.save_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditMode ? context.s.updateData : context.s.saveData,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isPhone = false,
    bool optional = false,
    bool showClearButton = false,
    bool confirmMatchesPassword = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      onChanged: onChanged,
      autovalidateMode: confirmMatchesPassword
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      decoration: InputDecoration(
        labelText: optional ? '$label (opsional)' : label,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        suffixIcon: showClearButton && controller.text.isNotEmpty
            ? IconButton(
                tooltip: context.s.clear,
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                  setState(() {});
                },
              )
            : null,
      ),
      validator: (value) {
        if (optional && (value == null || value.trim().isEmpty)) {
          return null;
        }
        if (confirmMatchesPassword) {
          if (value == null || value.isEmpty) {
            controller.text = passwordFormCont.text;
            return null;
          }
          if (value != passwordFormCont.text) {
            return context.s.passwordMismatch;
          }
          return null;
        }
        if (value == null || value.isEmpty) return context.s.requiredField;
        return null;
      },
    );
  }
}
