import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/controller/api_url/api.dart';

void main() {
  group('ApiUrl', () {
    test('default serv matches legacy dev URL', () {
      expect(ApiUrl.defaultServ, 'http://192.168.1.35:8080/');
      expect(ApiUrl.serv, ApiUrl.defaultServ);
    });

    test('contLogin includes path segments', () {
      expect(
        ApiUrl.contLogin,
        '${ApiUrl.serv}api_tool/api_toolstore/v1/auth/login',
      );
    });

    test('contSuperior aliases contSuperrior', () {
      expect(ApiUrl.contSuperior, ApiUrl.contSuperrior);
    });
  });
}
