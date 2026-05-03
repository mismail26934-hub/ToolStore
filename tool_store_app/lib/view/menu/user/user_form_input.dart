import 'dart:math' show min;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart';

String _labelSuperiorPick(PostList s) {
  if (s.namaSuperior.trim().isNotEmpty) return s.namaSuperior.trim();
  if (s.namaUser.trim().isNotEmpty) return s.namaUser.trim();
  return s.username;
}

List<PostList> _dedupeSuperiorRows(List<PostList> list) {
  final seen = <String>{};
  final out = <PostList>[];
  for (final s in list) {
    final id = s.idUsers.trim();
    final key = id.isNotEmpty
        ? id
        : '${s.namaUser.trim()}|${s.namaSuperior.trim()}|${s.username.trim()}';
    if (key.replaceAll('|', '').trim().isEmpty) continue;
    if (seen.contains(key)) continue;
    seen.add(key);
    out.add(s);
  }
  return out;
}

List<PostList> _filterSuperiorRows(List<PostList> list, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  return list.where((s) {
    final namaUser = s.namaUser.toLowerCase();
    final namaSup = s.namaSuperior.toLowerCase();
    final user = s.username.toLowerCase();
    return namaUser.contains(q) || namaSup.contains(q) || user.contains(q);
  }).toList();
}

class _SuperiorPickerDialog extends StatefulWidget {
  const _SuperiorPickerDialog({
    required this.superiors,
    required this.onSelected,
  });

  final List<PostList> superiors;
  final ValueChanged<PostList> onSelected;

  @override
  State<_SuperiorPickerDialog> createState() => _SuperiorPickerDialogState();
}

class _SuperiorPickerDialogState extends State<_SuperiorPickerDialog> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _dedupeSuperiorRows(
      _filterSuperiorRows(widget.superiors, _search.text),
    );
    final h = min(MediaQuery.sizeOf(context).height * 0.72, 520.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Container(
        width: min(MediaQuery.sizeOf(context).width - 40, 420),
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
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
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
                      Icons.supervisor_account_outlined,
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
                          'Pilih superior',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cari lalu ketuk salah satu nama',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
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
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
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
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.superiors.isEmpty
                                  ? 'Belum ada data superior'
                                  : 'Tidak ada hasil untuk pencarian ini',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
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
                        final s = filtered[i];
                        final title = _labelSuperiorPick(s);
                        final sub =
                            s.namaUser.trim().isNotEmpty &&
                                s.namaUser.trim() != title
                            ? s.namaUser.trim()
                            : null;
                        final userLine = s.username.isEmpty
                            ? null
                            : '@${s.username}';
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 0,
                          child: InkWell(
                            onTap: () => widget.onSelected(s),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
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
                                        if (sub != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            sub,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade700,
                                                ),
                                          ),
                                        ],
                                        if (userLine != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            userLine,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade500,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
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

class UserFormInput extends StatefulWidget {
  const UserFormInput({
    super.key,
    required this.title,
    required this.onPressTailing,
  });
  final String title;
  final void Function()? onPressTailing;

  @override
  State<UserFormInput> createState() => _UserFormInputState();
}

class _UserFormInputState extends State<UserFormInput> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio(); // Inisialisasi Dio
  bool _isLoading = false;
  bool get _isEditMode => iduserFormCont.text.isNotEmpty;

  Future<void> submitData(String params) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Persiapkan data FormData (sama seperti $_POST di PHP)
    FormData formData = FormData.fromMap({
      "param": params,
      "id_users": iduserFormCont.text,
      "username": usernameFormCont.text,
      "password": passwordFormCont.text,
      "nama_user": namaFormCont.text,
      "foto": "", // Kosongkan jika belum ada upload file
      "id_tu": tuidFormCont.text,
      "superior_id": superiorIdFormCont.text,
      "no_telp": telpFormCont.text,
      "token": "",
      "level": levelFormCont.text,
      "status": "Active",
    });

    try {
      // Ganti URL dengan endpoint PHP kamu
      final response = await _dio.post(
        "https://your-api-url.com",
        data: formData,
      );

      if (response.statusCode == 200) {
        // Dio otomatis mendeteksi jika response adalah JSON
        debugPrint("Respon Server: ${response.data}");

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Save Data Success")));
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      // Handle error spesifik Dio
      String errorMessage = e.response?.data?.toString() ?? cekInternet;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $errorMessage")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _applySuperiorFromPost(PostList s) {
    namaSuperiorFormCont.text = _labelSuperiorPick(s);
    superiorIdFormCont.text = s.idUsers.trim();
  }

  Future<void> _openSuperiorPicker(
    List<PostList> raw, {
    void Function()? onSuperiorChanged,
  }) async {
    if (!mounted) return;
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data superior belum dimuat')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _SuperiorPickerDialog(
        superiors: raw,
        onSelected: (s) {
          Navigator.pop(ctx);
          if (!mounted) return;
          setState(() {
            _applySuperiorFromPost(s);
            onSuperiorChanged?.call();
          });
        },
      ),
    );
  }

  void _showDeleteDialog() {
    ShowDialogBox.show(
      context: context,
      title: 'WARNING !',
      contentTitle: 'Are you sure delete data ?',
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        submitData(paramDeleteDataUser);
      },
      textNo: 'Back',
      textYes: 'Yes',
      textColorNo: clrBlack,
      textColorYes: clrRed,
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
              _isEditMode ? "Edit Data User" : "Add Data User",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: clrOrange,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              namaFormCont.text.isEmpty
                  ? "User Account Form"
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        context: context,
                        title: 'User Information',
                        icon: Icons.person_outline_rounded,
                        children: [
                          _buildTextField(usernameFormCont, "Username"),
                          const SizedBox(height: 10),
                          _buildTextField(
                            passwordFormCont,
                            "Password",
                            isPassword: true,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(namaFormCont, "Nama Lengkap"),
                          const SizedBox(height: 10),
                          _buildTextField(
                            telpFormCont,
                            "No. Telp",
                            isPhone: true,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context: context,
                        title: 'Access & Role',
                        icon: Icons.verified_user_outlined,
                        children: [
                          _buildTextField(tuidFormCont, "ID"),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            style: Theme.of(context).textTheme.labelMedium,
                            initialValue: levelFormCont.text.isEmpty
                                ? null
                                : levelFormCont.text,
                            items:
                                [
                                      "USER",
                                      "ADMIN",
                                      "MECHANIC",
                                      "SERVICE_ADMIN",
                                      "SUPERIOR",
                                      "HEAD_SERVICE",
                                      "TOOL_KEEPER",
                                      "COUNTER",
                                      "GA",
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
                            onChanged: (val) =>
                                setState(() => levelFormCont.text = val ?? ''),
                            decoration: _dropdownDecoration(context, "Level"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a Level !';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          StoreConnector<AppState, SuperriorState>(
                            converter: (s) => s.state.superriorState,
                            builder: (context, supState) {
                              if (supState.isLoadingSuperrior &&
                                  supState.superriorS.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: LinearProgressIndicator(
                                    borderRadius: BorderRadius.circular(8),
                                    color: clrOrange,
                                  ),
                                );
                              }
                              final hasValue = namaSuperiorFormCont.text
                                  .trim()
                                  .isNotEmpty;
                              return FormField<String>(
                                validator: (_) {
                                  if (namaSuperiorFormCont.text
                                      .trim()
                                      .isEmpty) {
                                    return 'Required';
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
                                                  'Superior',
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
                                                          tooltip: 'Hapus',
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
                                                  : 'Ketuk untuk pilih superior',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: hasValue
                                                        ? null
                                                        : Colors.grey.shade500,
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
                                  await submitData(
                                    _isEditMode
                                        ? paramEditDataUser
                                        : paramAddDataUser,
                                  );
                                  if (!context.mounted) return;
                                  PageRoutes.routeUser(context);
                                },
                                textNo: 'Cancel',
                                textYes: 'Yes',
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isEditMode ? Icons.save : Icons.save_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditMode ? 'Update Data' : 'Save Data',
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      validator: (value) => value!.isEmpty ? "Required !" : null,
    );
  }
}
