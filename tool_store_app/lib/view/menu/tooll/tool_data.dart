import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/build_detail.dart/build_detail.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolData extends StatefulWidget {
  const ToolData({super.key});
  @override
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> with MixinPref {
  // 1. Buat variabel key di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    refreshPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: clrWhite,
      drawer: DrawerMenu(title: name),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await store.dispatch(
              getDataTool(
                param: paramViewDataForm,
                idFrom: '',
                formNo: '',
                formServName: '',
                formCheckBy: '',
                formDateCheckBy: '',
                formDateServName: '',
                formServComment: '',
                formSuperiorAprd: '',
                formSuperiorComment: '',
                formSadminComment: '',
                formSheadAprd: '',
                formSheadComment: '',
                fromDateUpdate: '',
                formUserUpdate: '',
              ),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverAppbars(
                title: titleDataTool,
                onPressTailing: () {
                  postContForm(
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    context,
                  );
                },
                onPressLeading: () {},
                textColor: Colors.black,
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, FormsState>(
                converter: (store) => store.state.formsState,
                builder: (context, state) {
                  // 1. Tampilan saat Loading
                  if (state.isLoadingTool) {
                    return SliverFillRemaiings(
                      errors: "Loading",
                      hasScrollBodys: false,
                    );
                  }
                  // 2. Tampilan saat Error
                  if (state.error != null) {
                    return SliverFillRemaiings(
                      errors: state.error ?? '${state.error}',
                      hasScrollBodys: false,
                    );
                  }
                  // 3. Tampilan saat Data Kosong
                  if (state.forms.isEmpty) {
                    return SliverFillRemaiings(
                      errors: state.error ?? "No Record Data Found",
                      hasScrollBodys: false,
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final forms = state.forms[index];
                      return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Card(
                          color: isExpanded ? clrWhite : clrOrange,
                          child: ExpansionTile(
                            shape: const Border(),
                            onExpansionChanged: (expandeds) {
                              setState(() {
                                isExpanded = expandeds;
                              });
                            },
                            initiallyExpanded: isExpanded,
                            title: SelectableText(
                              forms.formNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: SelectableText(
                              'Status: ${forms.formServComment}',
                            ),
                            leading: CircleAvatar(
                              backgroundColor: clrOrange,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(color: clrBlack),
                              ),
                            ),
                            // Bagian Detail yang Muncul Saat Diklik (Sub Items)
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: BuildDetail(
                                            label: "Category",
                                            value: forms.idForm,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_document,
                                            color: clrOrange,
                                          ),
                                          onPressed: () {
                                            postContForm(
                                              forms.idForm,
                                              forms.formNo,
                                              forms.formServName,
                                              forms.formServComment,
                                              forms.formDateServName,
                                              forms.formCheckBy,
                                              forms.formDateCheckBy,
                                              forms.formSuperiorAprd,
                                              forms.formSuperiorComment,
                                              forms.formSadminComment,
                                              forms.formSheadAprd,
                                              forms.formSheadComment,
                                              forms.fromDateUpdate,
                                              forms.formUserUpdate,
                                              forms.formDateSuperiorAprd,
                                              forms.formDateSadminComment,
                                              forms.formDateSheadAprd,
                                              forms.formMilestone,
                                              forms.formStatusOrder,
                                              context,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
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
                                    Card(
                                      color: clrOrange,
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: TextButton.icon(
                                                icon: Icon(
                                                  Icons.cancel,
                                                  size: 15.0,
                                                ),
                                                onPressed: () {
                                                  ShowDialogBox.show(
                                                    context: context,
                                                    title:
                                                        'Reject Request Approval',
                                                    contentTitle:
                                                        ' Are you sure reject ?',
                                                    onPressedNo: () {
                                                      if (!context.mounted)
                                                        return;
                                                      Navigator.pop(context);
                                                    },
                                                    onPressedYes: () async {
                                                      // Tutup dialog dulu
                                                      Navigator.pop(context);
                                                      if (!context.mounted)
                                                        return;
                                                    },
                                                    textNo: 'Cancel',
                                                    textYes: 'Yes',
                                                    textColorNo: clrBlack,
                                                    textColorYes: clrOrange,
                                                  );
                                                },
                                                label: Text(
                                                  'Reject',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: clrWhite,
                                                      ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  shadowColor: clrWhite,
                                                  iconColor: clrWhite,
                                                  backgroundColor: clrRed,
                                                  minimumSize: const Size(
                                                    100,
                                                    40,
                                                  ),
                                                  // Mengatur warna teks dan ikon
                                                  foregroundColor: clrWhite,
                                                  // Menambahkan border
                                                  side: BorderSide(
                                                    color: clrRed,
                                                    width: 1,
                                                  ),
                                                  // Mengatur kelengkungan sudut (rounded)
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              flex: 1,
                                              child: TextButton.icon(
                                                icon: Icon(
                                                  Icons.approval,
                                                  size: 15.0,
                                                ),
                                                onPressed: () {
                                                  ShowDialogBox.show(
                                                    context: context,
                                                    title:
                                                        'Please make sure all data is correct',
                                                    contentTitle:
                                                        ' Are you sure approve ?',
                                                    onPressedNo: () {
                                                      if (!context.mounted)
                                                        return;
                                                      Navigator.pop(context);
                                                    },
                                                    onPressedYes: () async {
                                                      // Tutup dialog dulu
                                                      Navigator.pop(context);
                                                      if (!context.mounted)
                                                        return;
                                                    },
                                                    textNo: 'Cancel',
                                                    textYes: 'Yes',
                                                    textColorNo: clrBlack,
                                                    textColorYes: clrOrange,
                                                  );
                                                },
                                                label: Text(
                                                  'Approve',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: clrWhite,
                                                      ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  shadowColor: clrWhite,
                                                  iconColor: clrWhite,
                                                  backgroundColor: clrGreen,
                                                  minimumSize: const Size(
                                                    100,
                                                    40,
                                                  ),
                                                  // Mengatur warna teks dan ikon
                                                  foregroundColor: clrWhite,
                                                  // Menambahkan border
                                                  side: BorderSide(
                                                    color: clrGreen,
                                                    width: 1,
                                                  ),
                                                  // Mengatur kelengkungan sudut (rounded)
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              flex: 1,
                                              child: TextButton.icon(
                                                icon: Icon(
                                                  Icons.add,
                                                  size: 15.0,
                                                ),
                                                onPressed: () {
                                                  PageRoutes.routeUserFormDetail(
                                                    context,
                                                    'ADD DATA',
                                                  );
                                                },
                                                label: Text(
                                                  'Add',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: clrWhite,
                                                      ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  shadowColor: clrWhite,
                                                  iconColor: clrWhite,
                                                  backgroundColor: Colors.blue,
                                                  minimumSize: const Size(
                                                    100,
                                                    40,
                                                  ),
                                                  // Mengatur warna teks dan ikon
                                                  foregroundColor: clrWhite,
                                                  // Menambahkan border
                                                  side: BorderSide(
                                                    color: Colors.blue,
                                                    width: 1,
                                                  ),
                                                  // Mengatur kelengkungan sudut (rounded)
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                    StoreConnector<AppState, List<PostList>>(
                                      converter: (store) {
                                        final allTool = store
                                            .state
                                            .formsDetailState
                                            .formsDetail;
                                        return allTool
                                            .where(
                                              (itemTool) =>
                                                  itemTool.idForm ==
                                                  forms.idForm,
                                            )
                                            .toList();
                                      },
                                      builder: (context, filteredList) {
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: filteredList.length,
                                          itemBuilder: (context, ii) {
                                            final itemTool = filteredList[ii];
                                            // Sekarang 'filteredList' bisa dikenali
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'ITEM : ${ii + 1}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleSmall,
                                                    ),
                                                    Card(
                                                      child: TextButton.icon(
                                                        onPressed: () {
                                                          postMultipleToolCont(
                                                            '${ii + 1}',
                                                            itemTool.idForm,
                                                            itemTool
                                                                .idFormDetail,
                                                            itemTool
                                                                .formComment,
                                                            itemTool.pnGroup,
                                                            itemTool.pnDesc,
                                                            itemTool.qty,
                                                            itemTool.explan,
                                                            itemTool.actionNote,
                                                            itemTool.valType,
                                                            itemTool.partValue,
                                                            context,
                                                          );
                                                        },
                                                        icon: Icon(Icons.edit),
                                                        label: Text(
                                                          'Edit Data Tool',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Part No : ",
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge,
                                                    ),
                                                    Expanded(
                                                      child: SelectableText(
                                                        itemTool.pnGroup,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Part Desc : ",
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge,
                                                    ),
                                                    Expanded(
                                                      child: SelectableText(
                                                        itemTool.pnDesc,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Qty : ",
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge,
                                                    ),
                                                    Expanded(
                                                      child: SelectableText(
                                                        itemTool.qty,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Explanation : ",
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge,
                                                    ),
                                                    Expanded(
                                                      child: SelectableText(
                                                        itemTool.explan,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Action Note : A/B/C/D : ",
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge,
                                                    ),
                                                    Expanded(
                                                      child: SelectableText(
                                                        itemTool.actionNote,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // PO
                                                StoreConnector<
                                                  AppState,
                                                  List<PostList>
                                                >(
                                                  converter: (store) {
                                                    final allDataPO = store
                                                        .state
                                                        .posDetailState
                                                        .posDetail;
                                                    return allDataPO
                                                        .where(
                                                          (itemPO) =>
                                                              itemPO
                                                                  .idFormDetail ==
                                                              itemTool
                                                                  .idFormDetail,
                                                        )
                                                        .toList();
                                                  },
                                                  builder: (context, filteredListPO) {
                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          filteredListPO.length,
                                                      itemBuilder: (context, ii) {
                                                        final itemPO =
                                                            filteredListPO[ii];
                                                        // Sekarang 'filteredList' bisa dikenali
                                                        return Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                SelectableText(
                                                                  'PO : ${itemPO.poNo}',
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.labelLarge,
                                                                ),
                                                                TextButton.icon(
                                                                  onPressed:
                                                                      () {},
                                                                  icon: Icon(
                                                                    Icons.edit,
                                                                  ),
                                                                  label: Text(
                                                                    'Update PO',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                                // SO
                                                StoreConnector<
                                                  AppState,
                                                  List<PostList>
                                                >(
                                                  converter: (store) {
                                                    final allDataSO = store
                                                        .state
                                                        .sosDetailState
                                                        .sosDetail;
                                                    return allDataSO
                                                        .where(
                                                          (itemSO) =>
                                                              itemSO
                                                                  .idFormDetail ==
                                                              itemTool
                                                                  .idFormDetail,
                                                        )
                                                        .toList();
                                                  },
                                                  builder: (context, filteredListSO) {
                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          filteredListSO.length,
                                                      itemBuilder: (context, ii) {
                                                        final itemSO =
                                                            filteredListSO[ii];
                                                        // Sekarang 'filteredList' bisa dikenali
                                                        return Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                SelectableText(
                                                                  'SO : ${itemSO.so}',
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.labelLarge,
                                                                ),
                                                                TextButton.icon(
                                                                  onPressed:
                                                                      () {},
                                                                  icon: Icon(
                                                                    Icons.edit,
                                                                  ),
                                                                  label: Text(
                                                                    'Update SO',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "ETA : ",
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.labelLarge,
                                                                ),
                                                                Expanded(
                                                                  child: SelectableText(
                                                                    itemSO.eta,
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Note SO : ",
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.labelLarge,
                                                                ),
                                                                Expanded(
                                                                  child: SelectableText(
                                                                    itemSO
                                                                        .noteSo,
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const Divider(),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: state.forms.length),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
