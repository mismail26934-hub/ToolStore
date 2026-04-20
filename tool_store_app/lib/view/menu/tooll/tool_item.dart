import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/custom/build_detail.dart/build_detail.dart';

class ToolItem extends StatefulWidget {
  const ToolItem({super.key});

  @override
  State<ToolItem> createState() => _ToolItemState();
}

class _ToolItemState extends State<ToolItem> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FormsState>(
      converter: (store) => store.state.formsState,
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final forms = state.forms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      forms.formNo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Status: ${forms.formServComment}'),
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    // Bagian Detail yang Muncul Saat Diklik (Sub Items)
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BuildDetail(label: "Category", value: forms.idForm),
                            BuildDetail(
                              label: "Serviceman",
                              value: forms.formServName,
                            ),
                            BuildDetail(
                              label: "Create Date",
                              value: forms.formDateServName,
                            ),
                            BuildDetail(
                              label: "Checked By",
                              value: forms.formCheckBy,
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // Panggil fungsi postContForm kamu di sini
                                    // postContForm(forms.idForm, forms.formNo, ... , context);
                                  },
                                ),
                                // Tombol Edit yang kamu buat sebelumnya
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Panggil fungsi postContForm kamu di sini
                                    // postContForm(forms.idForm, forms.formNo, ... , context);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextButton.icon(
                                    onPressed: () {},
                                    label: Text('Reject'),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(100, 40),
                                      // Mengatur warna teks dan ikon
                                      foregroundColor: Colors.black,
                                      // Menambahkan border
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                      // Mengatur kelengkungan sudut (rounded)
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextButton.icon(
                                    onPressed: () {},
                                    label: Text('Approve'),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(100, 40),
                                      // Mengatur warna teks dan ikon
                                      foregroundColor: Colors.black,
                                      // Menambahkan border
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      // Mengatur kelengkungan sudut (rounded)
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            StoreConnector<AppState, List<PostList>>(
                              converter: (store) {
                                final allData =
                                    store.state.formsDetailState.formsDetail;
                                return allData
                                    .where(
                                      (item) => item.idForm == forms.idForm,
                                    )
                                    .toList();
                              },
                              builder: (context, filteredList) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredList[index];
                                    // Sekarang 'filteredList' bisa dikenali
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Form No : ",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item.formComment,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: state.forms.length),
            ),
          ],
        );
      },
    );
  }
}
