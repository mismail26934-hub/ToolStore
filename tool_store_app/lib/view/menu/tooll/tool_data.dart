import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
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
                      return Card(
                        child: ListTile(
                          title: SelectableText(
                            forms.formNo,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                'Category : ${forms.formServName}',
                              ),
                            ],
                          ),
                          leading: IconButton(
                            onPressed: () {
                              PageRoutes.routeUserFormDetail(
                                context,
                                'multiple',
                              );
                            },
                            icon: Icon(Icons.add),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              postContForm(
                                idFormCont.text = forms.idForm,
                                formNoCont.text = forms.formNo,
                                servNameCont.text = forms.formServName,
                                servCommentCont.text = forms.formServComment,
                                dateServNameCont.text = forms.formDateServName,
                                checkedByCont.text = forms.formCheckBy,
                                dateCheckByCont.text = forms.formDateCheckBy,
                                superiorAprdCont.text = forms.formSuperiorAprd,
                                superiorCommentCont.text =
                                    forms.formSuperiorComment,
                                sadminCommentCont.text =
                                    forms.formSadminComment,
                                sheadAprdCont.text = forms.formSheadAprd,
                                sheadCommentCont.text = forms.formSheadComment,
                                dateUpdateCont.text = forms.fromDateUpdate,
                                userUpdateCont.text = forms.formUserUpdate,
                                dateSuperiorAprdCont.text =
                                    forms.formDateSuperiorAprd,
                                dateSadminCommentCont.text =
                                    forms.formDateSadminComment,
                                dateSheadAprdCont.text =
                                    forms.formDateSheadAprd,
                                milestoneCont.text = forms.formMilestone,
                                statusOrderCont.text = forms.formStatusOrder,
                                context,
                              );
                            },
                            icon: Icon(Icons.edit),
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
