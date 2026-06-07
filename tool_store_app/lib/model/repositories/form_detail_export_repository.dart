import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/view/var/var.dart';

class FormDetailExportFile {
  const FormDetailExportFile({
    required this.bytes,
    required this.filename,
  });

  final List<int> bytes;
  final String filename;
}

String? parseFilenameFromContentDisposition(String? header) {
  if (header == null || header.trim().isEmpty) return null;
  final quoted = RegExp(r'filename="([^"]+)"').firstMatch(header);
  if (quoted != null) {
    return quoted.group(1)?.trim();
  }
  final plain = RegExp(r'filename=([^;]+)').firstMatch(header);
  return plain?.group(1)?.trim().replaceAll('"', '');
}

bool _isXlsxContentType(String? contentType) {
  final ct = contentType?.toLowerCase() ?? '';
  return ct.contains('spreadsheetml') ||
      ct.contains(
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
}

String _parseJsonErrorMessage(List<int> bytes) {
  try {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map) {
      final message = decoded['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
  } catch (_) {}
  return '';
}

Future<FormDetailExportFile> fetchFormDetailExport({
  String? idForm,
  String? fromDateUpdate,
  String? toDateUpdate,
}) async {
  final body = <String, dynamic>{
    'param': paramExportDataFormDetail,
  };
  final id = idForm?.trim() ?? '';
  if (id.isNotEmpty) body['id_form'] = id;

  final from = fromDateUpdate?.trim() ?? '';
  if (from.isNotEmpty) {
    body['from_date_update'] = from;
    final to = toDateUpdate?.trim() ?? '';
    body['to_date_update'] = to.isNotEmpty ? to : from;
  }

  final payload = await withAuthFields(body);
  final response = await createApiDio().post<List<int>>(
    ApiUrl.contFormDetailExport,
    data: FormData.fromMap(payload),
    options: Options(
      responseType: ResponseType.bytes,
      receiveTimeout: const Duration(minutes: 3),
      validateStatus: (status) => status != null && status < 600,
    ),
  );

  final bytes = response.data ?? <int>[];
  if (bytes.isEmpty) {
    throw Exception(_parseJsonErrorMessage(bytes).isEmpty
        ? 'Export gagal: respons kosong.'
        : _parseJsonErrorMessage(bytes));
  }

  if (_isXlsxContentType(response.headers.value('content-type'))) {
    final filename = parseFilenameFromContentDisposition(
          response.headers.value('content-disposition'),
        ) ??
        'form_detail_export.xlsx';
    return FormDetailExportFile(bytes: bytes, filename: filename);
  }

  final errorMessage = _parseJsonErrorMessage(bytes);
  throw Exception(
    errorMessage.isNotEmpty ? errorMessage : 'Export gagal.',
  );
}
