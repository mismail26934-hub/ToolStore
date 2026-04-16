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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                ShowDialogBox.show(
                  context: context,
                  title: 'WARNING !',
                  contentTitle: 'Are you sure delete data ?',
                  onPressedNo: () {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  onPressedYes: () async {
                    // Tutup dialog dulu
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    submitData(paramDeleteDataUser);
                  },
                  textNo: 'Back',
                  textYes: 'Yes',
                  textColorNo: clrBlack,
                  textColorYes: clrRed,
                );
              },
              icon: Icon(Icons.delete, color: clrRed),
            ),
          ),
        ],
        title: Text(
          iduserFormCont.text == ""
              ? "Input Data User ${namaFormCont.text}"
              : "Edit Data User ${namaFormCont.text}",
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
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
                    _buildTextField(telpFormCont, "No. Telp", isPhone: true),
                    const SizedBox(height: 20),
                    _buildTextField(tuidFormCont, "ID "),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
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
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) =>
                          setState(() => levelFormCont.text = val.toString()),
                      decoration: const InputDecoration(
                        labelText: "Level",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a Level !';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ShowDialogBox.show(
                              context: context,
                              title: 'Please make sure all data is correct',
                              contentTitle: iduserFormCont.text == ""
                                  ? 'Are you sure save data ?'
                                  : ' Are you sure edit data ?',
                              onPressedNo: () {
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                              onPressedYes: () async {
                                // Tutup dialog dulu
                                Navigator.pop(context);
                                submitData(
                                  iduserFormCont.text == ""
                                      ? paramAddDataUser
                                      : paramEditDataUser,
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
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          iduserFormCont.text == "" ? "SAVE" : "UPDATE",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "Required !" : null,
    );
  }
}
