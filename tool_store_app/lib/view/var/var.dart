import 'package:flutter/material.dart';

const mobileWidth = 600;
double paddingForm = 5.0;
Color clrBtnPrimary = Colors.blue;
Color clrBtnPrimaryFgBlack = Colors.black;
Color clrOrange = Color.fromARGB(255, 255, 146, 21);
Color clrWhite = Colors.white;
Color clrBlack = Colors.black;
Color clrRed = Colors.red;
Color clrGreen = Colors.green;
double btnFontSize = 15.0;

String errors = "";
String messages = "";
String cekInternet = "Check Internet Connection";
String serverDown = "Server Down";
String titleApp = "";
String usernameApp = "";
String passwordApp = "";
String messageLogin = "";
String valueLogin = "";

String value = "";
String idUsersApp = "";
String name = "";
String usernamePref = "";
String passwordPref = "";
String address = "";
String level = "";
String email = "";
String noTelp = "";
String token = "";
String idTu = "";
String status = "";
String foto = "";

final formKey = GlobalKey<FormState>();
// List<PostList?>? list;
// late bool isLoading;
bool isLoadingLogin = true;
bool loadingLogin = false;
bool expandeds = true;
bool isExpanded = true;

// Controller Login
final username = TextEditingController();
final password = TextEditingController();

// Controller FORM
String titleDataTool = 'Data Tool';
String paramViewDataForm = 'VIEW DATA FORM';
String paramAddDataForm = 'ADD DATA FORM';
String paramEditDataForm = 'EDIT DATA FORM';
String paramDeleteDataForm = 'DELETED DATA FORM';

final idFormCont = TextEditingController();
final formNoCont = TextEditingController();
final servNameCont = TextEditingController();
final servCommentCont = TextEditingController();
final dateServNameCont = TextEditingController();
final checkedByCont = TextEditingController();
final dateCheckByCont = TextEditingController();
final superiorAprdCont = TextEditingController();
final superiorCommentCont = TextEditingController();
final sadminCommentCont = TextEditingController();
final sheadAprdCont = TextEditingController();
final sheadCommentCont = TextEditingController();
final dateUpdateCont = TextEditingController();
final userUpdateCont = TextEditingController();
final dateSuperiorAprdCont = TextEditingController();
final dateSadminCommentCont = TextEditingController();
final dateSheadAprdCont = TextEditingController();
final milestoneCont = TextEditingController();
final statusOrderCont = TextEditingController();

// Controller FORM DETAIL
String paramViewDataTool = 'VIEW DATA TOOL';
String paramAddDataTool = 'ADD DATA TOOL';
String paramEditDataTool = 'EDIT DATA TOOL';
String paramDeleteDataTool = 'DELETED DATA TOOL';
final itemCont = TextEditingController();
List<TextEditingController> totalFormDetailCont = [];
List<TextEditingController> idFormToolCont = [];
List<TextEditingController> idFormDetailCont = [];
List<TextEditingController> formCommentCont = [];
List<TextEditingController> pnGroupCont = [];
List<TextEditingController> pnDescCont = [];
List<TextEditingController> qtyCont = [];
List<TextEditingController> explanCont = [];
List<TextEditingController> actionNoteCont = [];
List<TextEditingController> valTypeCont = [];
List<TextEditingController> partValueCont = [];
final formDetailDateCont = TextEditingController();
final formDetailUserCont = TextEditingController();

// Controller PO
String paramViewDataPO = 'VIEW DATA PO';
String paramAddDataPO = 'ADD DATA PO';
String paramEditDataPO = 'EDIT DATA PO';
String paramDeleteDataPO = 'DELETED DATA PO';

// Controller SO
String paramViewDataSO = 'VIEW DATA SO';
String paramAddDataSO = 'ADD DATA SO';
String paramEditDataSO = 'EDIT DATA SO';
String paramDeleteDataSO = 'DELETED DATA SO';

// Controller Superrior
String paramViewDataSuperrior = 'VIEW DATA SUPERRIOR';
String paramAddDataSuperrior = 'ADD DATA SUPERRIOR';
String paramEditDataSuperrior = 'EDIT DATA SUPERRIOR';
String paramDeleteDataSuperrior = 'DELETED DATA SUPERRIOR';

// Controller User
String titleDataUser = 'DATA USER ';
String paramViewDataUser = 'VIEW DATA USER';
String paramAddDataUser = 'ADD DATA USER';
String paramEditDataUser = 'EDIT DATA USER';
String paramDeleteDataUser = 'DELETED DATA USER';
final TextEditingController iduserFormCont = TextEditingController();
final TextEditingController usernameFormCont = TextEditingController();
final TextEditingController passwordFormCont = TextEditingController();
final TextEditingController namaFormCont = TextEditingController();
final TextEditingController telpFormCont = TextEditingController();
final TextEditingController tuidFormCont = TextEditingController();
final TextEditingController levelFormCont = TextEditingController();
