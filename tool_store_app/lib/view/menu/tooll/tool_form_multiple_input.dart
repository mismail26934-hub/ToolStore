import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/var/var.dart'; // Pastikan formKey ada di sini

class ToolFormMultipleInput extends StatefulWidget {
  const ToolFormMultipleInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormMultipleInput> createState() => _ToolFormMultipleInputState();
}

class _ToolFormMultipleInputState extends State<ToolFormMultipleInput> {
  // Gunakan underscore (_) untuk menandakan variabel private
  final List<TextEditingController> _controllers = [];

  void _addRow() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_controllers.length > 1) {
      // Sisakan minimal 1 baris
      setState(() {
        _controllers[i].dispose();
        _controllers.removeAt(i);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _addRow(); // Tambah baris pertama saat startup
  }

  @override
  void dispose() {
    // BERSIHKAN MEMORI: Wajib dilakukan di Flutter
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitData() {
    if (formKey.currentState!.validate()) {
      // Ambil semua data teks
      List<String> dataValues = _controllers.map((c) => c.text).toList();
      print("Data siap kirim ke API: $dataValues");
      // Lanjutkan dengan http.post ke PHP di sini
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Data ${widget.subtitle}"),
        actions: [
          IconButton(onPressed: _addRow, icon: const Icon(Icons.add_circle)),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _controllers.length,
                  itemBuilder: (context, i) {
                    return Card(
                      // Menggunakan Card agar tiap grup input lebih rapi
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ITEM ${i + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeRow(i),
                                ),
                              ],
                            ),
                            const Divider(),
                            // JANGAN gunakan Expanded di sini
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormFields(
                                    labelTexts: 'PN GROUP CONSIST',
                                    textColor: Colors.black,
                                    controllers: _controllers[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormFields(
                                    labelTexts: 'QTY',
                                    textColor: Colors.black,
                                    controllers: _controllers[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormFields(
                                    labelTexts: 'DESCRIPTION',
                                    textColor: Colors.black,
                                    controllers: _controllers[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Tambahkan field lain jika perlu, tanpa Expanded
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormFields(
                                    labelTexts: 'EXPLANATION',
                                    textColor: Colors.black,
                                    controllers: _controllers[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormFields(
                                    labelTexts: 'ACTION NOTE (A/B/C/D)',
                                    textColor: Colors.black,
                                    controllers: _controllers[i],
                                    validators: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Required !'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tombol Simpan di bagian bawah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _submitData,
                  child: const Text(
                    "SIMPAN SEMUA DATA",
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
}
