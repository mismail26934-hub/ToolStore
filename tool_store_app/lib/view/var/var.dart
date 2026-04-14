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
String paramViewDataUser = 'VIEW DATA USER';
String paramAddDataUser = 'ADD DATA USER';
String paramEditDataUser = 'EDIT DATA USER';
String paramDeleteDataUser = 'DELETED DATA USER';
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

List<PostList?>? list;
late bool isLoading;
bool isLoadingLogin = true;
bool loadingLogin = false;

// Controller Data Tool
final formKey = GlobalKey<FormState>();
final formNumberController = TextEditingController();
final categoryController = TextEditingController();
final checkedBy = TextEditingController();
final dateCreateForm = TextEditingController();
final commentRequester = TextEditingController();
final commentSuperior = TextEditingController();
final commentServiceAdmin = TextEditingController();
final commentServiceHead = TextEditingController();
// Controller Login
final username = TextEditingController();
final password = TextEditingController();
// Controller User
final TextEditingController iduserFormCont = TextEditingController();
final TextEditingController usernameFormCont = TextEditingController();
final TextEditingController passwordFormCont = TextEditingController();
final TextEditingController namaFormCont = TextEditingController();
final TextEditingController telpFormCont = TextEditingController();
final TextEditingController tuidFormCont = TextEditingController();
final TextEditingController levelFormCont = TextEditingController();
