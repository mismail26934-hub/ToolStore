import 'package:tool_store_app/controller/api_url/post_list.dart';

/// Redux slice + filtered rows for detail sections (PO, SO, Rcv, tools).
class DetailSectionVm {
  const DetailSectionVm({
    required this.items,
    required this.isLoading,
    this.errorMessage,
    this.salesOrderExists = false,
    this.whReceivedExists = false,
    this.toolRoomReceivedExists = false,
  });

  final List<PostList> items;
  final bool isLoading;
  final String? errorMessage;

  /// True when this tool line already has Sales Order / SO-PR data (gates PO actions).
  final bool salesOrderExists;

  /// True when this tool line already has Date WH Received data (gates SO actions).
  final bool whReceivedExists;

  /// True when this tool line already has Date Tool Room Received data (gates WH actions).
  final bool toolRoomReceivedExists;
}
