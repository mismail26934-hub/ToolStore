import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';

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
String titleApp = "Data Tool Request";
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
List<PostList?>? list;
late bool isLoading;
bool isLoadingLogin = true;
bool loadingLogin = false;

// Controller Login
final username = TextEditingController();
final password = TextEditingController();

// Controller Data Tool
String titleDataTool = 'DATA TOOL ';
String paramViewDataForm = 'VIEW DATA FORM';
String paramAddDataForm = 'ADD DATA FORM';
String paramEditDataForm = 'EDIT DATA FORM';
String paramDeleteDataForm = 'DELETED DATA FORM';

final idFormCont = TextEditingController();
final formNoCont = TextEditingController();
final servNameCont = TextEditingController();
final servCommentCont = TextEditingController();
final servCommentCategoryCont = TextEditingController();
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
final formDateSuperiorAprd = TextEditingController();
final formDateSadminComment = TextEditingController();
final formDateSheadAprd = TextEditingController();

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
