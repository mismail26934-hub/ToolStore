import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Result from the date filter dialog.
sealed class ToolDataDateFilterSheetResult {}

class ToolDataDateFilterApplied extends ToolDataDateFilterSheetResult {
  ToolDataDateFilterApplied({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}

class ToolDataDateFilterCleared extends ToolDataDateFilterSheetResult {}

/// Centered dialog with separate start/end [showDatePicker] fields.
Future<ToolDataDateFilterSheetResult?> showToolDataDateFilterSheet({
  required BuildContext context,
  DateTime? initialFrom,
  DateTime? initialTo,
  required bool showClearAction,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return showDialog<ToolDataDateFilterSheetResult>(
    context: context,
    builder: (dialogContext) {
      return _ToolDataDateFilterSheetBody(
        initialFrom: initialFrom ?? today.subtract(const Duration(days: 30)),
        initialTo: initialTo ?? today,
        showClearAction: showClearAction,
      );
    },
  );
}

class _ToolDataDateFilterSheetBody extends StatefulWidget {
  const _ToolDataDateFilterSheetBody({
    required this.initialFrom,
    required this.initialTo,
    required this.showClearAction,
  });

  final DateTime initialFrom;
  final DateTime initialTo;
  final bool showClearAction;

  @override
  State<_ToolDataDateFilterSheetBody> createState() =>
      _ToolDataDateFilterSheetBodyState();
}

class _ToolDataDateFilterSheetBodyState
    extends State<_ToolDataDateFilterSheetBody> {
  static final _firstDate = DateTime(2000);
  static final _lastDate = DateTime(2100);

  late DateTime _from;
  late DateTime _to;

  AppStrings get strings => AppStrings.current;

  @override
  void initState() {
    super.initState();
    _from = _dateOnly(widget.initialFrom);
    _to = _dateOnly(widget.initialTo);
    _normalizeRange();
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  void _normalizeRange() {
    if (_from.isAfter(_to)) {
      final swap = _from;
      _from = _to;
      _to = swap;
    }
  }

  String _formatDisplay(DateTime date) =>
      DateFormat.yMd(Localizations.localeOf(context).toString()).format(date);

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _firstDate,
      lastDate: _lastDate,
      helpText: isFrom
          ? strings.dateFilterFromLabel
          : strings.dateFilterToLabel,
    );
    if (picked == null || !mounted) return;
    setState(() {
      final day = _dateOnly(picked);
      if (isFrom) {
        _from = day;
      } else {
        _to = day;
      }
      _normalizeRange();
    });
  }

  void _apply() {
    Navigator.pop(context, ToolDataDateFilterApplied(from: _from, to: _to));
  }

  void _clear() {
    Navigator.pop(context, ToolDataDateFilterCleared());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      title: Text(
        strings.dateUpdateFilterTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DatePickerField(
            label: strings.dateFilterFromLabel,
            value: _formatDisplay(_from),
            onTap: () => _pickDate(isFrom: true),
          ),
          const SizedBox(height: 12),
          _DatePickerField(
            label: strings.dateFilterToLabel,
            value: _formatDisplay(_to),
            onTap: () => _pickDate(isFrom: false),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _apply,
            style: FilledButton.styleFrom(
              backgroundColor: clrOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(strings.applyDateFilter),
          ),
          if (widget.showClearAction) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _clear,
              child: Text(strings.clearDateFilter),
            ),
          ],
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: TextStyle(color: clrOrange),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: clrOrange, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          suffixIcon: Icon(Icons.calendar_month_outlined, color: clrOrange),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
