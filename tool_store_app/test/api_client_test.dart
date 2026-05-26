import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/model/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('withAuthFields', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'token': 'tok123',
        'idUsersApp': 'user1',
      });
    });

    test('merges token and auth fields when body keys are empty', () async {
      final result = await withAuthFields({'param': 'VIEW DATA FORM'});
      expect(result['param'], 'VIEW DATA FORM');
      expect(result['token'], 'tok123');
      expect(result['auth_id_users'], 'user1');
      expect(result['id_users_app'], 'user1');
    });

    test('does not overwrite non-empty token in body', () async {
      final result = await withAuthFields({'token': 'existing'});
      expect(result['token'], 'existing');
      expect(result['auth_id_users'], 'user1');
    });

    test('does not overwrite non-empty id_users filter field', () async {
      final result = await withAuthFields({
        'auth_id_users': 'filter-user',
        'id_users_app': 'filter-app',
      });
      expect(result['auth_id_users'], 'filter-user');
      expect(result['id_users_app'], 'filter-app');
    });

    test('skips auth fields when credentials are empty', () async {
      SharedPreferences.setMockInitialValues({});
      final result = await withAuthFields({'param': 'X'});
      expect(result.containsKey('token'), isFalse);
      expect(result['param'], 'X');
    });
  });

  group('resolveDioException', () {
    final s = AppStrings.current;

    test('maps connection errors to checkInternet', () {
      final resolved = resolveDioException(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(resolved.label, s.checkInternet);
      expect(resolved.throwMessage, s.checkInternet);
    });

    test('maps connection timeout to checkInternet', () {
      final resolved = resolveDioException(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(resolved.label, s.checkInternet);
    });

    test('maps 401/403 to sessionExpired', () {
      for (final code in [401, 403]) {
        final resolved = resolveDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: code,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        expect(resolved.label, s.sessionExpired);
      }
    });

    test('maps 5xx to serverDown', () {
      final resolved = resolveDioException(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(resolved.label, s.serverDown);
    });

    test('maps other bad responses to serverDown', () {
      final resolved = resolveDioException(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(resolved.label, s.serverDown);
    });
  });

  group('messageForApiError', () {
    test('returns serverDown for FormatException', () {
      expect(messageForApiError(FormatException('bad json')), AppStrings.current.serverDown);
    });
  });

  group('createApiDio', () {
    tearDown(resetSharedApiDio);

    test('returns the same instance on repeated calls', () {
      final a = createApiDio();
      final b = createApiDio();
      expect(identical(a, b), isTrue);
    });

    test('resetSharedApiDio allows a new instance', () {
      final a = createApiDio();
      resetSharedApiDio();
      final b = createApiDio();
      expect(identical(a, b), isFalse);
      expect(a.options.connectTimeout, b.options.connectTimeout);
      expect(a.options.receiveTimeout, b.options.receiveTimeout);
    });
  });
}
