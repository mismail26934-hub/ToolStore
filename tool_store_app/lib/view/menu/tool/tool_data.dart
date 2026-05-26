import 'package:flutter/material.dart';
import 'tool_data_state.dart';

class ToolData extends StatefulWidget {
  const ToolData({
    super.key,
    this.title,
    this.formMilestoneFilter,
    this.formMilestoneFilters = const <String>[],
    this.excludeFormMilestoneFilter = false,
    this.excludeFormMilestoneFilters = const <String>[],
    this.filterBlankFormMilestone = false,
    this.initialSearchQuery,
    this.initialSearchField = 'all',
    this.initialExpandedFormId,
  });

  final String? title;
  final String? formMilestoneFilter;
  final List<String> formMilestoneFilters;
  final bool excludeFormMilestoneFilter;
  final List<String> excludeFormMilestoneFilters;
  final bool filterBlankFormMilestone;
  final String? initialSearchQuery;
  final String initialSearchField;

  /// Keeps the matching form card expanded when opening the list (e.g. after edit).
  final String? initialExpandedFormId;

  @override
  State<ToolData> createState() => ToolDataState();
}
