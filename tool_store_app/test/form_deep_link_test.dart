import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/config/app_links_config.g.dart';
import 'package:tool_store_app/services/form_deep_link.dart';

void main() {
  group('parseFormNoFromUri', () {
    test('reads form_no query parameter', () {
      final uri = Uri.parse(AppLinksConfig.sampleFormLink);
      expect(parseFormNoFromUri(uri), 'F-00123');
    });

    test('returns null when form_no is missing or empty', () {
      expect(parseFormNoFromUri(Uri.parse(AppLinksConfig.webBase)), isNull);
      expect(
        parseFormNoFromUri(
          Uri.parse(AppLinksConfig.webBase).replace(
            queryParameters: {AppLinksConfig.formNoQueryParam: ''},
          ),
        ),
        isNull,
      );
    });
  });

  group('matchesAppLinkUri', () {
    test('accepts configured host and path', () {
      expect(
        matchesAppLinkUri(
          Uri.parse('${AppLinksConfig.webBase}?${AppLinksConfig.formNoQueryParam}=X'),
        ),
        isTrue,
      );
      expect(
        matchesAppLinkUri(Uri.parse(AppLinksConfig.webBase)),
        isTrue,
      );
    });

    test('rejects other hosts and paths', () {
      expect(
        matchesAppLinkUri(
          Uri.parse(
            'https://example.com${AppLinksConfig.pathPrefix}/?${AppLinksConfig.formNoQueryParam}=X',
          ),
        ),
        isFalse,
      );
      expect(
        matchesAppLinkUri(Uri.parse('https://${AppLinksConfig.host}/other/')),
        isFalse,
      );
    });
  });

  group('buildFormLink', () {
    test('builds URL with encoded form_no', () {
      expect(buildFormLink('F-00123'), AppLinksConfig.sampleFormLink);
    });

    test('returns base URL when form_no is empty', () {
      expect(buildFormLink(''), FormDeepLinkConfig.defaultWebBase);
    });
  });

  group('FormDeepLinkService', () {
    test('captures and consumes pending form_no', () {
      final service = FormDeepLinkService.instance;
      service.captureFromUri(
        Uri.parse('https://example.test/?form_no=ABC-9'),
      );
      expect(service.peekPendingFormNo(), 'ABC-9');
      expect(service.consumePendingFormNo(), 'ABC-9');
      expect(service.hasPending, isFalse);
    });

    test('captures form_no from notification data', () {
      final service = FormDeepLinkService.instance;
      service.captureFromNotificationData({
        AppLinksConfig.formNoQueryParam: 'N-42',
      });
      expect(service.peekPendingFormNo(), 'N-42');
      service.consumePendingFormNo();
    });
  });
}
