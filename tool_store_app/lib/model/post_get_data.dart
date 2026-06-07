/// Barrel: API thunks, repositories, and parsers (Fase 4.3).
///
/// Prefer direct imports from `model/repositories/` or `model/thunks/` in new code.
library;

export 'package:tool_store_app/model/parsers/dashboard_counts_parser.dart';
export 'package:tool_store_app/model/parsers/form_list_parser.dart';
export 'package:tool_store_app/model/parsers/legacy_array_parser.dart';
export 'package:tool_store_app/model/parsers/user_list_parser.dart';

export 'package:tool_store_app/model/repositories/auth_repository.dart';
export 'package:tool_store_app/model/repositories/form_repository.dart';
export 'package:tool_store_app/model/repositories/list_merge_utils.dart';
export 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
export 'package:tool_store_app/model/repositories/po_repository.dart';
export 'package:tool_store_app/model/repositories/rcv_tool_repository.dart';
export 'package:tool_store_app/model/repositories/rcv_wh_repository.dart';
export 'package:tool_store_app/model/repositories/so_repository.dart';
export 'package:tool_store_app/model/repositories/superior_repository.dart';
export 'package:tool_store_app/model/repositories/tool_detail_repository.dart';
export 'package:tool_store_app/model/repositories/user_repository.dart';

export 'package:tool_store_app/model/thunks/form_related_details_thunks.dart';
export 'package:tool_store_app/model/thunks/form_thunks.dart';
export 'package:tool_store_app/model/thunks/po_thunks.dart';
export 'package:tool_store_app/model/thunks/rcv_thunks.dart';
export 'package:tool_store_app/model/thunks/so_thunks.dart';
export 'package:tool_store_app/model/thunks/superior_thunks.dart';
export 'package:tool_store_app/model/thunks/tool_detail_thunks.dart';
export 'package:tool_store_app/model/thunks/user_thunks.dart';
