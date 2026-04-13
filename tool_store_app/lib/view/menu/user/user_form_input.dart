import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio(); // Inisialisasi Dio

  // Controller
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();

  String selectedLevel = 'User';
  bool _isLoading = false;

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Persiapkan data FormData (sama seperti $_POST di PHP)
    FormData formData = FormData.fromMap({
      "param": "ADD DATA USER",
      "id_users": "0",
      "username": _usernameController.text,
      "password": _passwordController.text, // Akan di-MD5 oleh PHP
      "nama_user": _namaController.text,
      "foto": "", // Kosongkan jika belum ada upload file
      "id_tu": "1",
      "no_telp": _telpController.text,
      "token": "your_device_token",
      "level": selectedLevel,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menyimpan data via Dio!")),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      // Handle error spesifik Dio
      String errorMessage =
          e.response?.data?.toString() ?? "Terjadi kesalahan jaringan";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $errorMessage")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input User (Dio)")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_usernameController, "Username"),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _passwordController,
                      "Password",
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_namaController, "Nama Lengkap"),
                    const SizedBox(height: 10),
                    _buildTextField(_telpController, "No. Telp", isPhone: true),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
                      value: selectedLevel,
                      items: ["Admin", "User"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedLevel = val.toString()),
                      decoration: const InputDecoration(
                        labelText: "Level",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Text(
                          "KIRIM DATA",
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
      validator: (value) =>
          value!.isEmpty ? "Bidang ini tidak boleh kosong" : null,
    );
  }
}
