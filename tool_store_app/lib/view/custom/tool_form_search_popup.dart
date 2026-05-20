import 'package:flutter/material.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Hasil pencarian form dari popup (keyword + field filter).
class ToolFormSearchResult {
  const ToolFormSearchResult({
    required this.query,
    required this.searchField,
  });

  final String query;
  final String searchField;
}

/// Label dropdown — sama dengan [tool_data.dart].
const Map<String, String> kToolFormSearchFieldLabels = {
  'all': 'All',
  'formNo': 'Form No',
  'serviceman': 'Serviceman',
  'status': 'Status',
  'idForm': 'Category',
  'pnGroup': 'PN Group',
  'pnDesc': 'Description',
};

/// Popup pencarian form (UI sama dengan search bar di tool list).
Future<ToolFormSearchResult?> showToolFormSearchPopup(
  BuildContext context, {
  String initialQuery = '',
  String initialSearchField = 'all',
}) {
  return showDialog<ToolFormSearchResult>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _ToolFormSearchDialog(
        initialQuery: initialQuery,
        initialSearchField: initialSearchField,
      );
    },
  );
}

class _ToolFormSearchDialog extends StatefulWidget {
  const _ToolFormSearchDialog({
    required this.initialQuery,
    required this.initialSearchField,
  });

  final String initialQuery;
  final String initialSearchField;

  @override
  State<_ToolFormSearchDialog> createState() => _ToolFormSearchDialogState();
}

class _ToolFormSearchDialogState extends State<_ToolFormSearchDialog> {
  late final TextEditingController _controller;
  late String _searchField;

  bool get _canSearch => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(() => setState(() {}));
    _searchField = kToolFormSearchFieldLabels.containsKey(widget.initialSearchField)
        ? widget.initialSearchField
        : 'all';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    Navigator.pop(
      context,
      ToolFormSearchResult(query: query, searchField: _searchField),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: clrOrange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.search, color: clrOrange, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cari Data Form',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.iconMuted),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: _canSearch ? (_) => _submit() : null,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari data form...',
                hintStyle: TextStyle(color: context.iconMuted),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _canSearch ? clrOrange : context.iconMuted,
                  ),
                  tooltip: 'Cari',
                  onPressed: _canSearch ? _submit : null,
                ),
                filled: true,
                fillColor: context.searchAccentFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.searchAccentBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.searchAccentBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: clrOrange, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.searchAccentFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.searchAccentBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _searchField,
                  isExpanded: true,
                  iconEnabledColor: clrOrange,
                  borderRadius: BorderRadius.circular(12),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  items: kToolFormSearchFieldLabels.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _searchField = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSearch ? _submit : null,
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Cari'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: clrOrange,
                  disabledBackgroundColor: clrOrange.withValues(alpha: 0.35),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
