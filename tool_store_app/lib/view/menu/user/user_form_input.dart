import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart';

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
            color: Colors.black.withOpacity(0.04),
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
                  color: clrOrange.withOpacity(0.12),
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

  void _showDeleteDialog() {
    ShowDialogBox.show(
      context: context,
      title: 'WARNING !',
      contentTitle: 'Are you sure delete data ?',
      onPressedNo: () {
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      onPressedYes: () async {
        if (!context.mounted) return;
        Navigator.pop(context);
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
              color: clrOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: clrOrange.withOpacity(0.2)),
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
                color: clrOrange.withOpacity(0.75),
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
                clrOrange.withOpacity(0.14),
                clrOrange.withOpacity(0.05),
                clrOrange.withOpacity(0.14),
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
                  border: Border.all(color: clrOrange.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: clrOrange.withOpacity(0.22),
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
                                onPressedNo: () {
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                                onPressedYes: () async {
                                  Navigator.pop(context);
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
                            shadowColor: clrBlack.withOpacity(0.18),
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
