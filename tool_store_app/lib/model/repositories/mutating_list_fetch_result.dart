import 'package:tool_store_app/controller/api_url/post_list.dart';

/// Result of PO / SO / tool-detail / receive fetch. PHP may append
/// `{"value":"1","message":"..."}` for ADD / EDIT / DELETE; that envelope must
/// not be parsed as a [PostList] row.
class PoFetchResult {
  final List<PostList> list;

  /// Server `message` for ADD/EDIT/DELETE (`value` from envelope).
  final String? serverMessage;

  /// Envelope `value` when `param` is ADD/EDIT/DELETE; `'1'` means success.
  final String? statusValue;

  const PoFetchResult({
    required this.list,
    this.serverMessage,
    this.statusValue,
  });
}

typedef SoFetchResult = PoFetchResult;
typedef ToolDetailFetchResult = PoFetchResult;
typedef RcvWhFetchResult = PoFetchResult;
typedef RcvToolFetchResult = PoFetchResult;
