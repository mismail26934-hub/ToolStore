import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/menu/tooll/tool_form.dart';
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

  void _postContForm(
    String idForm,
    formNo,
    servName,
    servComment,
    dateServName,
    checkedBy,
    dateCheckBy,
    superiorAprd,
    superiorComment,
    sadminComment,
    sheadAprd,
    sheadComment,
    dateUpdate,
    userUpdate,
    dateSuperiorAprd,
    dateSadminComment,
    dateSheadAprd,
  ) {
    setState(() {
      idFormCont.text = idForm;
      formNoCont.text = formNo;
      servNameCont.text = servName;
      servCommentCont.text = servComment;
      dateServNameCont.text = dateServName;
      checkedByCont.text = checkedBy;
      dateCheckByCont.text = dateCheckBy;
      superiorAprdCont.text = superiorAprd;
      superiorCommentCont.text = superiorComment;
      sadminCommentCont.text = sadminComment;
      sheadAprdCont.text = sheadAprd;
      sheadCommentCont.text = sheadComment;
      dateUpdateCont.text = dateUpdate;
      userUpdateCont.text = userUpdate;
      formDateSuperiorAprd.text = dateSuperiorAprd;
      formDateSadminComment.text = dateSadminComment;
      formDateSheadAprd.text = dateSheadAprd;
      if (idForm == "") {
        servCommentCategoryCont.clear();
      } else {
        if (servCommentCategoryCont.text == "MISSING" ||
            servCommentCategoryCont.text == "DAMAGE" ||
            servCommentCategoryCont.text == "ADDITIONAL") {
          servNameCont.text = "HOLDER";
        } else {
          servNameCont.text = "NON HOLDER";
        }
      }
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToolForm(
          title: iduserFormCont.text.isEmpty ? 'ADD DATA' : 'EDIT DATA',
          onPressTailing: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: clrWhite,
      drawer: DrawerMenu(title: name),
      body: RefreshIndicator(
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
                _postContForm(
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
                    errors: state.error ?? "Loading",
                    hasScrollBodys: false,
                  );
                }
                // 2. Tampilan saat Error
                if (state.error != null) {
                  return SliverFillRemaiings(
                    errors: state.error ?? "Loading",
                    hasScrollBodys: false,
                  );
                }
                // 3. Tampilan saat Data Kosong
                if (state.forms.isEmpty) {
                  return SliverFillRemaiings(
                    errors: state.error ?? "Loading",
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
                            SelectableText('Category : ${forms.formServName}'),
                          ],
                        ),
                        leading: Icon(Icons.remove_red_eye),
                        trailing: Icon(Icons.edit_document),
                      ),
                    );
                  }, childCount: state.forms.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
