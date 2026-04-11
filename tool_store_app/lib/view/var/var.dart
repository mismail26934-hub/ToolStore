import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';

const mobileWidth = 600;
double paddingForm = 5.0;
Color clrBtnPrimary = Colors.blue;
Color clrBtnPrimaryFgBlack = Colors.black;
double btnFontSize = 15.0;
String paramViewDataUser = 'VIEW DATA USER';
String errors = "";
String messages = "";
String cekInternet = "Check Internet Connection";
String serverDown = "Server Down";

final formKey = GlobalKey<FormState>();
final formNumberController = TextEditingController();
final categoryController = TextEditingController();
final checkedBy = TextEditingController();
final dateCreateForm = TextEditingController();
final commentRequester = TextEditingController();
final commentSuperior = TextEditingController();
final commentServiceAdmin = TextEditingController();
final commentServiceHead = TextEditingController();

List<PostList?>? listUser;
late bool isLoading;
