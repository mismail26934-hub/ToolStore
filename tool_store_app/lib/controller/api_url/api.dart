/// API path segments and full endpoint URLs for the Tool Store backend.
class ApiUrl {
  /// Default dev server when [serv] is not overridden via `--dart-define=API_BASE=...`.
  static const String defaultServ = 'http://192.168.1.5:8080/';

  /// Base URL with trailing slash. Override at build/run time:
  /// `flutter run --dart-define=API_BASE=http://10.0.0.1:8080`
  static String get serv {
    const fromEnv = String.fromEnvironment('API_BASE');
    if (fromEnv.isEmpty) return defaultServ;
    return fromEnv.endsWith('/') ? fromEnv : '$fromEnv/';
  }

  static const String fApiTool = 'api_tool';
  static const String fApi = 'api_toolstore';
  static const String fCnt = 'v1';
  static const String fUser = 'user';
  static const String fForm = 'form';
  static const String fFormDetail = 'form/detail';
  static const String fPo = 'po';
  static const String fSo = 'so';
  static const String fReceiveWh = 'receive/wh';
  static const String fReceiveTool = 'receive/tool';
  static const String fSuperior = 'superior';
  static const String fAlogin = 'auth/login';
  static const String fFcm = 'device/fcm';

  static String get contDataUser => '$serv$fApiTool/$fApi/$fCnt/$fUser';
  static String get contDataTool => '$serv$fApiTool/$fApi/$fCnt/$fForm';
  static String get contLogin => '$serv$fApiTool/$fApi/$fCnt/$fAlogin';
  static String get contFcmToken => '$serv$fApiTool/$fApi/$fCnt/$fFcm';
  static String get contDataToolDetail =>
      '$serv$fApiTool/$fApi/$fCnt/$fFormDetail';
  static String get contFormDetailExport =>
      '$serv$fApiTool/$fApi/$fCnt/$fFormDetail/export';

  static String get contPO => '$serv$fApiTool/$fApi/$fCnt/$fPo';
  static String get contSO => '$serv$fApiTool/$fApi/$fCnt/$fSo';
  static String get contSuperrior => '$serv$fApiTool/$fApi/$fCnt/$fSuperior';

  /// Alias for [contSuperrior] (typo preserved for backward compatibility).
  static String get contSuperior => contSuperrior;
  static String get contRcvWh => '$serv$fApiTool/$fApi/$fCnt/$fReceiveWh';
  static String get contRcvTool => '$serv$fApiTool/$fApi/$fCnt/$fReceiveTool';
}
