import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';

const mobileWidth = 600;
double paddingForm = 5.0;
Color clrBtnPrimary = Colors.blue;
Color clrBtnPrimaryFgBlack = Colors.black;
Color clrOrange = Color.fromARGB(255, 255, 146, 21);
Color clrWhite = Colors.white;
Color clrBlack = Colors.black;
double btnFontSize = 15.0;
String paramViewDataUser = 'VIEW DATA USER';
String errors = "";
String messages = "";
String cekInternet = "Check Internet Connection";
String serverDown = "Server Down";
String titleApp = "Data Tool Request";

final formKey = GlobalKey<FormState>();
final formNumberController = TextEditingController();
final categoryController = TextEditingController();
final checkedBy = TextEditingController();
final dateCreateForm = TextEditingController();
final commentRequester = TextEditingController();
final commentSuperior = TextEditingController();
final commentServiceAdmin = TextEditingController();
final commentServiceHead = TextEditingController();

List<PostList?>? list;
late bool isLoading;
bool isLoadingLogin = true;
