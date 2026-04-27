class ApiUrl {
  // static String server = 'http://10.50.102.69:8080/';
  static String server = 'http://10.74.115.69:8080/';
  static String folderApiTool = 'api_tool';
  static String folderApiToolStore = 'api_toolstore';
  static String folderController = 'controller';
  static String folderUser = 'user';
  static String fileContUser = 'cont_user.php';
  static String fileContTool = 'cont_form.php';
  static String fileContToolDetail = 'cont_form_detail.php';
  static String fileContPO = 'cont_po.php';
  static String fileContSO = 'cont_so.php';
  static String fileContSuperrior = 'cont_superrior.php';
  static String fileLogin = 'login.php';

  static String contDataUser =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContUser";
  static String contDataTool =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContTool";
  static String contLogin =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileLogin";
  static String contDataToolDetail =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContToolDetail";

  static String contPO =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContPO";
  static String contSO =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContSO";
  static String contSuperrior =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContSuperrior";
}
