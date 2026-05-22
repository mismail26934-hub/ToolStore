import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/menu/tooll/tool_form.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/view/var/var.dart';

void postContUser(
  String idUsers,
  username,
  password,
  namaUser,
  noTelp,
  idTU,
  level,
  String superiorId,
  String namaSuperior,
  BuildContext context, {
  bool levelReadOnly = false,
  bool popOnSuccess = false,
}) {
  iduserFormCont.text = idUsers;
  usernameFormCont.text = username;
  passwordFormCont.text = password;
  confirmPasswordFormCont.text = password;
  namaFormCont.text = namaUser;
  telpFormCont.text = noTelp;
  tuidFormCont.text = idTU;
  levelFormCont.text = level;
  superiorIdFormCont.text = superiorId;
  namaSuperiorFormCont.text = namaSuperior;
  PageRoutes.routeUserForm(
    context,
    iduserFormCont.text.isEmpty
        ? AppStrings.current.addData
        : AppStrings.current.editData,
    () {},
    levelReadOnly: levelReadOnly,
    popOnSuccess: popOnSuccess,
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
        title: idFormCont.text.isEmpty
            ? AppStrings.current.addData
            : AppStrings.current.editData,
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

Future<void> postMultipleToolCont(
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
  BuildContext context, {

  /// True when opening the form to add new tool rows (API ADD) while still
  /// pre-filling parent [idFormTool] / [idFormDetail] from the list context.
  bool navigateAsAdd = false,
}) async {
  parentIdFormForToolDetail = (idFormTool ?? '').toString().trim();
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

  idFormToolCont.add(TextEditingController(text: parentIdFormForToolDetail));
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
  formDetailDateCont.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(
    DateTime.now(),
  );
  var detailUser = idUsersApp.trim();
  if (detailUser.isEmpty) {
    final prefs = await SharedPreferences.getInstance();
    detailUser = (prefs.getString('idUsersApp') ?? '').trim();
    if (detailUser.isNotEmpty) {
      idUsersApp = detailUser;
    }
  }
  formDetailUserCont.text = detailUser;

  await PageRoutes.routeUserFormDetail(
    context,
    navigateAsAdd ? AppStrings.current.addData : AppStrings.current.editData,
    parentIdForm: parentIdFormForToolDetail,
  );
}
