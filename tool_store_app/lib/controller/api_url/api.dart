class ApiUrl {
  static String server = 'http://192.168.1.31:8080/';
  // static String server = 'http://10.157.164.69:8080/';
  static String fApiTool = 'api_tool';
  static String fApi = 'api_toolstore';
  static String fCnt = 'v1';
  // static String folderUser = 'user';
  static String fUser = 'user';
  static String fForm = 'form';
  static String fFormDetail = 'form/detail';
  static String fPo = 'po';
  static String fSo = 'so';
  static String fReceiveWh = 'receive/wh';
  static String fReceiveTool = 'receive/tool';
  static String fSuperior = 'superior';
  static String fAlogin = 'auth/login';

  static String contDataUser = "$server/$fApiTool/$fApi/$fCnt/$fUser";
  static String contDataTool = "$server/$fApiTool/$fApi/$fCnt/$fForm";
  static String contLogin = "$server/$fApiTool/$fApi/$fCnt/$fAlogin";
  static String contDataToolDetail =
      "$server/$fApiTool/$fApi/$fCnt/$fFormDetail";

  static String contPO = "$server/$fApiTool/$fApi/$fCnt/$fPo";
  static String contSO = "$server/$fApiTool/$fApi/$fCnt/$fSo";
  static String contSuperrior = "$server/$fApiTool/$fApi/$fCnt/$fSuperior";
  static String contRcvWh = "$server/$fApiTool/$fApi/$fCnt/$fReceiveWh";
  static String contRcvTool = "$server/$fApiTool/$fApi/$fCnt/$fReceiveTool";
}
