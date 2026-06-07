import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/model/repositories/form_detail_export_repository.dart';
import 'package:tool_store_app/model/repositories/form_repository.dart';
import 'package:tool_store_app/view/menu/tool/tool_data_excel_filter_sheet.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolDataExportOutcome {
  const ToolDataExportOutcome({
    required this.success,
    required this.message,
    this.savedPath,
    this.cancelled = false,
  });

  final bool success;
  final String message;
  final String? savedPath;
  final bool cancelled;
}

Future<String?> resolveFormIdByFormNo(String formNo) async {
  final query = formNo.trim();
  if (query.isEmpty) return null;

  final parsed = await fetchFormList({
    'param': paramViewDataForm,
    'id_form': '',
    'form_no': '',
    'form_serv_name': '',
    'form_check_by': '',
    'form_date_check_by': '',
    'form_date_serv_name': '',
    'form_serv_comment': '',
    'form_superior_aprd': '',
    'form_superior_comment': '',
    'form_sadmin_comment': '',
    'form_milestone': '',
    'form_status_order': '',
    'form_shead_aprd': '',
    'form_shead_comment': '',
    'from_date_update': '',
    'form_user_update': '',
    'page': '1',
    'limit': '20',
    'keyword': query,
    'search_field': 'formNo',
  });

  for (final form in parsed.items) {
    if (form.formNo.trim() == query) {
      final id = form.idForm.trim();
      if (id.isNotEmpty) return id;
    }
  }

  if (parsed.items.isNotEmpty) {
    final id = parsed.items.first.idForm.trim();
    if (id.isNotEmpty) return id;
  }
  return null;
}

(DateTime from, DateTime to) intersectExportDateRange({
  required DateTime from,
  required DateTime to,
  DateTime? headerFrom,
  DateTime? headerTo,
}) {
  var effectiveFrom = from;
  var effectiveTo = to;

  if (headerFrom != null && headerTo != null) {
    effectiveFrom = effectiveFrom.isAfter(headerFrom)
        ? effectiveFrom
        : headerFrom;
    effectiveTo = effectiveTo.isBefore(headerTo) ? effectiveTo : headerTo;
    if (effectiveFrom.isAfter(effectiveTo)) {
      throw Exception(AppStrings.current.exportDateRangeNoOverlap);
    }
  }

  return (effectiveFrom, effectiveTo);
}

String _formatApiDate(DateTime date) =>
    DateFormat('yyyy-MM-dd').format(date);

Future<ToolDataExportOutcome> exportFormDetailWithFilter({
  required ToolDataExcelFilterSheetResult filter,
  DateTime? headerDateFrom,
  DateTime? headerDateTo,
}) async {
  final s = AppStrings.current;
  String? idForm;
  String? fromDateUpdate;
  String? toDateUpdate;

  switch (filter) {
    case ToolDataExcelFilterDateApplied(:final from, :final to):
      final range = intersectExportDateRange(
        from: from,
        to: to,
        headerFrom: headerDateFrom,
        headerTo: headerDateTo,
      );
      fromDateUpdate = _formatApiDate(range.$1);
      toDateUpdate = _formatApiDate(range.$2);
    case ToolDataExcelFilterFormNoApplied(:final formNo):
      idForm = await resolveFormIdByFormNo(formNo);
      if (idForm == null || idForm.isEmpty) {
        return ToolDataExportOutcome(
          success: false,
          message: s.exportFormNotFound(formNo),
        );
      }
      if (headerDateFrom != null && headerDateTo != null) {
        fromDateUpdate = _formatApiDate(headerDateFrom);
        toDateUpdate = _formatApiDate(headerDateTo);
      }
    case ToolDataExcelFilterCleared():
      return ToolDataExportOutcome(success: false, message: s.exportCancelled);
  }

  final exportFile = await fetchFormDetailExport(
    idForm: idForm,
    fromDateUpdate: fromDateUpdate,
    toDateUpdate: toDateUpdate,
  );

  final savedPath = await FilePicker.saveFile(
    dialogTitle: s.exportExcelSaveTitle,
    fileName: exportFile.filename,
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
  );

  if (savedPath == null) {
    return ToolDataExportOutcome(
      success: false,
      message: s.exportCancelled,
      cancelled: true,
    );
  }

  await File(savedPath).writeAsBytes(exportFile.bytes, flush: true);

  return ToolDataExportOutcome(
    success: true,
    message: s.exportExcelSuccess(savedPath),
    savedPath: savedPath,
  );
}
