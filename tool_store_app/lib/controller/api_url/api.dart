class ApiUrl {
  static String serv = 'http://192.168.1.11:8080/';
  // static String serv = 'http://10.157.164.69:8080/';
  static String fApiTool = 'api_tool';
  static String fApi = 'api_toolstore';
  static String fCnt = 'v1';
  static String fUser = 'user';
  static String fForm = 'form';
  static String fFormDetail = 'form/detail';
  static String fPo = 'po';
  static String fSo = 'so';
  static String fReceiveWh = 'receive/wh';
  static String fReceiveTool = 'receive/tool';
  static String fSuperior = 'superior';
  static String fAlogin = 'auth/login';

  static String contDataUser = "$serv/$fApiTool/$fApi/$fCnt/$fUser";
  static String contDataTool = "$serv/$fApiTool/$fApi/$fCnt/$fForm";
  static String contLogin = "$serv/$fApiTool/$fApi/$fCnt/$fAlogin";
  static String contDataToolDetail = "$serv/$fApiTool/$fApi/$fCnt/$fFormDetail";

  static String contPO = "$serv/$fApiTool/$fApi/$fCnt/$fPo";
  static String contSO = "$serv/$fApiTool/$fApi/$fCnt/$fSo";
  static String contSuperrior = "$serv/$fApiTool/$fApi/$fCnt/$fSuperior";
  static String contRcvWh = "$serv/$fApiTool/$fApi/$fCnt/$fReceiveWh";
  static String contRcvTool = "$serv/$fApiTool/$fApi/$fCnt/$fReceiveTool";
}
