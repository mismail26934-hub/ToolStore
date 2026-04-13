class ApiUrl {
  // static String server = 'http://10.50.102.69:8080/';
  static String server = 'http://192.168.1.22:8080/';
  static String folderApiTool = 'api_tool';
  static String folderApiToolStore = 'api_toolstore';
  static String folderController = 'controller';
  static String folderUser = 'user';
  static String fileContUser = 'cont_user.php';
  static String fileLogin = 'login.php';

  static String contDataUser =
      "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileContUser";
  // static String contLogin = "$server/$folderApiTool/$folderApiToolStore/$folderController/$fileLogin";
  static String contLogin =
      "http://192.168.1.22:8080/api_tool/api_toolstore/controller/login.php";
}
