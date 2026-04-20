import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/menu/tooll/tool_form.dart';
import 'package:tool_store_app/view/var/var.dart';

void postContUser(
  String idUsers,
  username,
  password,
  namaUser,
  noTelp,
  idTU,
  level,
  BuildContext context,
) {
  iduserFormCont.text = idUsers;
  usernameFormCont.text = username;
  passwordFormCont.text = password;
  namaFormCont.text = namaUser;
  telpFormCont.text = noTelp;
  tuidFormCont.text = idTU;
  levelFormCont.text = level;
  PageRoutes.routeUserForm(
    context,
    iduserFormCont.text.isEmpty ? 'ADD DATA' : 'EDIT DATA',
    () {},
  );
}

void postContForm(
  String idForm,
  dynamic formNo,
  dynamic servName,
  dynamic servComment,
  dynamic dateServName,
  dynamic checkedBy,
  dynamic dateCheckBy,
  dynamic superiorAprd,
  dynamic superiorComment,
  dynamic sadminComment,
  dynamic sheadAprd,
  dynamic sheadComment,
  dynamic dateUpdate,
  dynamic userUpdate,
  dynamic dateSuperiorAprd,
  dynamic dateSadminComment,
  dynamic dateSheadAprd,
  dynamic milestone,
  dynamic statusOrder,
  BuildContext context,
) {
  idFormCont.text = idForm;
  formNoCont.text = formNo ?? "";
  servNameCont.text = servName ?? "";
  servCommentCont.text = servComment ?? "";
  dateServNameCont.text = dateServName ?? "";
  checkedByCont.text = checkedBy ?? "";
  dateCheckByCont.text = dateCheckBy ?? "";
  superiorAprdCont.text = superiorAprd ?? "";
  superiorCommentCont.text = superiorComment ?? "";
  sadminCommentCont.text = sadminComment ?? "";
  sheadAprdCont.text = sheadAprd ?? "";
  sheadCommentCont.text = sheadComment ?? "";
  dateUpdateCont.text = dateUpdate ?? "";
  userUpdateCont.text = userUpdate ?? "";
  dateSuperiorAprdCont.text = dateSuperiorAprd ?? "";
  dateSadminCommentCont.text = dateSadminComment ?? "";
  dateSheadAprdCont.text = dateSheadAprd ?? "";
  milestoneCont.text = milestone ?? "";
  statusOrderCont.text = statusOrder ?? "";

  UpdateToolFormAction({
    'idForm': idForm,
    'formNo': formNo,
    'servName': servName,
    'servComment': servComment,
    'dateServName': dateServName,
    'checkedBy': checkedBy,
    'dateCheckBy': dateCheckBy,
    'superiorAprd': superiorAprd,
    'superiorComment': superiorComment,
    'sadminComment': sadminComment,
    'sheadAprd': sheadAprd,
    'sheadComment': sheadComment,
    'dateUpdate': dateUpdate,
    'userUpdate': userUpdate,
    'dateSuperiorAprd': dateSuperiorAprd,
    'dateSadminComment': dateSadminComment,
    'dateSheadAprd': dateSheadAprd,
    'milestone': milestone,
    'statusOrder': statusOrder,
  });

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ToolForm(
        title: idFormCont.text.isEmpty ? 'ADD DATA' : 'EDIT DATA',
        onPressTailing: () {},
      ),
    ),
  );
}

// Tambahkan BuildContext context sebagai parameter
Future<void> selectDate(
  BuildContext context,
  TextEditingController controller,
  VoidCallback onSelected,
  // Gunakan callback untuk menggantikan setState
) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    // Set value ke controller
    controller.text = "${pickedDate.toLocal()}".split(' ')[0];
    // Panggil callback untuk memicu UI update di widget
    onSelected();
  }
}

void postMultipleToolCont(
  String ii,
  idFormTool,
  idFormDetail,
  formComment,
  pnGroup,
  pnDesc,
  qty,
  explan,
  actionNote,
  valType,
  partValue,
  BuildContext context,
) {
  idFormToolCont.clear();
  idFormDetailCont.clear();
  formCommentCont.clear();
  pnGroupCont.clear();
  pnDescCont.clear();
  qtyCont.clear();
  explanCont.clear();
  actionNoteCont.clear();
  valTypeCont.clear();
  partValueCont.clear();

  idFormToolCont.add(TextEditingController(text: idFormTool ?? ""));
  idFormDetailCont.add(TextEditingController(text: idFormDetail ?? ""));
  formCommentCont.add(TextEditingController(text: formComment ?? ""));
  pnGroupCont.add(TextEditingController(text: pnGroup ?? ""));
  pnDescCont.add(TextEditingController(text: pnDesc ?? ""));
  qtyCont.add(TextEditingController(text: qty ?? ""));
  explanCont.add(TextEditingController(text: explan ?? ""));
  actionNoteCont.add(TextEditingController(text: actionNote ?? ""));
  valTypeCont.add(TextEditingController(text: valType ?? ""));
  partValueCont.add(TextEditingController(text: partValue ?? ""));
  itemCont.text = ii.toString();

  PageRoutes.routeUserFormDetail(
    context,
    idFormToolCont.isEmpty ? 'ADD DATA' : 'EDIT DATA',
  );
}
