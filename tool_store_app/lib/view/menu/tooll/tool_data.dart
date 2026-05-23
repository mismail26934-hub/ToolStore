import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/detail_section_vm.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';
import 'package:tool_store_app/debug/agent_log.dart';
import 'package:tool_store_app/view/custom/tool_form_search_popup.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

Widget _formCardSkeletonItem(BuildContext context, int index) =>
    const FormCardSkeleton();

/// Redux [StoreConnector] equality for order timeline rebuilds.
class _OrderTimelineViewModel {
  const _OrderTimelineViewModel({
    required this.orangeCompleted,
    this.redStepIndex,
    this.partialStepIndex,
    this.partialProgress,
    this.partialCountLabel,
  });

  /// Number of leading steps (0–7) shown as completed (orange) when [redStepIndex] is null.
  final int orangeCompleted;

  /// When set, this step is shown in red (rejection / hold) instead of orange.
  final int? redStepIndex;

  /// Step index (0–6) shown as partially complete (e.g. WH / Tool partial received).
  final int? partialStepIndex;

  /// Fill ratio 0.0–1.0 for [partialStepIndex] (lines received / total lines).
  final double? partialProgress;

  /// Optional label e.g. "2/5" for partial step subtitle.
  final String? partialCountLabel;

  @override
  bool operator ==(Object other) =>
      other is _OrderTimelineViewModel &&
      other.orangeCompleted == orangeCompleted &&
      other.redStepIndex == redStepIndex &&
      other.partialStepIndex == partialStepIndex &&
      other.partialProgress == partialProgress &&
      other.partialCountLabel == partialCountLabel;

  @override
  int get hashCode => Object.hash(
    orangeCompleted,
    redStepIndex,
    partialStepIndex,
    partialProgress,
    partialCountLabel,
  );
}

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
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> with MixinPref {
  AppStrings get _s => AppStrings.current;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _expandedForms = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchField = 'all';
  int _currentPage = 1;

  String get _pageTitle {
    final customTitle = widget.title?.trim();
    return customTitle != null && customTitle.isNotEmpty
        ? customTitle
        : titleDataTool;
  }

  String get _milestoneFilterNorm =>
      _normFormMilestone(widget.formMilestoneFilter ?? '');

  bool get _hasMilestoneFilter => _milestoneFilterNorm.isNotEmpty;

  Set<String> get _milestoneFiltersNorms => {
    ...widget.formMilestoneFilters.map(_normFormMilestone),
    if (_hasMilestoneFilter) _milestoneFilterNorm,
  }..removeWhere((value) => value.isEmpty);

  bool get _hasMilestoneFilters => _milestoneFiltersNorms.isNotEmpty;

  /// Dashboard counts use [kToolFormDashboardFetchLimit]; list must load enough rows
  /// before client-side milestone filter or matches show "Not Found" incorrectly.
  int get _formsFetchLimit =>
      _hasMilestoneFilters ? kToolFormDashboardFetchLimit : kToolFormPageSize;

  Set<String> get _excludeMilestoneFilterNorms => widget
      .excludeFormMilestoneFilters
      .map(_normFormMilestone)
      .where((value) => value.isNotEmpty)
      .toSet();

  @override
  void initState() {
    super.initState();
    refreshPref();
    final initialQuery = widget.initialSearchQuery?.trim() ?? '';
    if (initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
      _searchQuery = initialQuery;
      _searchField =
          kToolFormSearchFieldKeys.contains(widget.initialSearchField)
          ? widget.initialSearchField
          : 'all';
    }
    final expandedId = widget.initialExpandedFormId?.trim() ?? '';
    if (expandedId.isNotEmpty) {
      _expandedForms.add(expandedId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Dialog routes may still detach [TextFormField]s one frame after [showDialog]
  /// completes; disposing controllers immediately causes "used after disposed".
  void _disposeTextControllersAfterFrame(
    List<TextEditingController> controllers,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  Future<void> _fetchFormsPage({
    required int page,
    required bool append,
  }) async {
    await store.dispatch(
      getDataTool(
        param: paramViewDataForm,
        idForm: '',
        formNo: '',
        formServName: '',
        formCheckBy: '',
        formDateCheckBy: '',
        formDateServName: '',
        formServComment: '',
        formSuperiorAprd: '',
        formSuperiorComment: '',
        formSadminComment: '',
        formMilestone: '',
        formStatusOrder: '',
        formSheadAprd: '',
        formSheadComment: '',
        fromDateUpdate: '',
        formUserUpdate: '',
        page: page,
        limit: _formsFetchLimit,
        append: append,
        viewKeyword: _searchQuery,
        viewSearchField: _searchField,
      ),
    );
  }

  bool get _canSubmitSearch => _searchController.text.trim().isNotEmpty;

  /// Memanggil API dengan keyword dari field (saat ikon search diklik).
  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searchQuery = query;
    });
    _refreshData();
  }

  void _onSearchTextEdited() => setState(() {});

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _currentPage = 1);
    await _fetchFormsPage(page: 1, append: false);
    // #region agent log
    final fs = store.state.formsState;
    agentDebugLog(
      hypothesisId: 'A',
      location: 'tool_data.dart:_refreshData',
      message: 'after fetch page 1',
      data: {
        'formsLoaded': fs.forms.length,
        'totalForms': fs.totalForms,
        'hasMore': fs.hasMore,
        'error': fs.error,
        'fetchLimit': _formsFetchLimit,
        'searchQuery': _searchQuery,
        'searchField': _searchField,
        'pageTitle': _pageTitle,
        'milestoneFilters': widget.formMilestoneFilters,
        'milestoneFilter': widget.formMilestoneFilter,
        'milestoneFiltersNorms': _milestoneFiltersNorms.toList(),
        'sampleMilestones': fs.forms
            .take(5)
            .map((f) => f.formMilestone.trim())
            .toList(),
      },
    );
    // #endregion
    await _loadToolDetailsOnly();
  }

  Future<void> _loadToolDetailsOnly() async {
    await store.dispatch(
      getDataToolDetail(
        param: paramViewDataTool,
        idFormDetail: '',
        idFrom: '',
        formComment: '',
        pnGroup: '',
        pnDesc: '',
        qty: '',
        explan: '',
        actionNote: '',
        valType: '',
        partValue: '',
        formDetailDate: '',
        formDetailUser: '',
      ),
    );
  }

  void _rememberExpandedForm(String idForm) {
    final id = idForm.trim();
    if (id.isEmpty) return;
    _expandedForms.add(id);
  }

  Future<void> _pickDateIntoController(
    BuildContext dialogContext,
    TextEditingController controller,
  ) async {
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);
    final parsed = DateTime.tryParse(controller.text.trim());
    final now = DateTime.now();
    final fallbackDate = now.isBefore(firstDate)
        ? firstDate
        : now.isAfter(lastDate)
        ? lastDate
        : now;
    final initialDate =
        parsed != null &&
            !parsed.isBefore(firstDate) &&
            !parsed.isAfter(lastDate)
        ? parsed
        : fallbackDate;
    final picked = await showDatePicker(
      context: dialogContext,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    controller.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchField = 'all';
    });
    _refreshData();
  }

  /// After a successful save on a form, focus the list search on that form's number.
  Future<void> _setSearchToFormNumber(PostList formHeader) async {
    if (!mounted) return;
    final no = formHeader.formNo.trim();
    if (no.isEmpty) return;
    _rememberExpandedForm(formHeader.idForm);
    _searchController.text = no;
    setState(() {
      _searchQuery = no;
      _searchField = 'formNo';
    });
    await _refreshData();
  }

  String _formLoadSummary(FormsState state, int visibleCount) {
    final n = visibleCount;
    final loaded = state.forms.length;
    final t = state.totalForms;
    if (t != null) {
      return _s.formsShownSummary(n, loaded, t);
    }
    return _s.formsShownCount(n, loaded);
  }

  Future<void> _loadMoreForms() async {
    if (store.state.formsState.isLoadingMore ||
        !store.state.formsState.hasMore) {
      return;
    }
    final nextPage = _currentPage + 1;
    try {
      await _fetchFormsPage(page: nextPage, append: true);
      if (mounted) setState(() => _currentPage = nextPage);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
  }

  bool _matchesMilestoneFilter(PostList form) {
    if (widget.filterBlankFormMilestone) {
      final isBlank = form.formMilestone.trim().isEmpty;
      if (widget.excludeFormMilestoneFilter) return !isBlank;
      return isBlank;
    }
    final currentMilestoneNorm = _normFormMilestone(form.formMilestone);
    final excludeMilestoneFilterNorms = _excludeMilestoneFilterNorms;
    if (excludeMilestoneFilterNorms.isNotEmpty &&
        excludeMilestoneFilterNorms.contains(currentMilestoneNorm)) {
      return false;
    }
    if (!_hasMilestoneFilters) return true;
    final isMatch = _milestoneFiltersNorms.contains(currentMilestoneNorm);
    if (widget.excludeFormMilestoneFilter) return !isMatch;
    return isMatch;
  }

  Color _statusColor(String value) {
    final status = value.toLowerCase();
    if (status.contains('approve') || status.contains('done')) {
      return Colors.green;
    }
    if (status.contains('reject') || status.contains('cancel')) {
      return Colors.red;
    }
    if (status.contains('process') || status.contains('pending')) {
      return Colors.orange;
    }
    return const Color.fromARGB(255, 231, 169, 14);
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  bool _isApprovedValue(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized == 'APPROVED' ||
        normalized == 'APPROVE' ||
        normalized == 'Y' ||
        normalized == 'YES';
  }

  bool _isRejectedValue(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized == 'REJECTED' ||
        normalized == 'REJECT' ||
        normalized == 'N' ||
        normalized == 'NO';
  }

  /// Service admin milestone → CONTINUE / HOLD for the Service Support tile.
  ({String? text, Color? color, IconData? icon})
  _serviceSupportMilestoneStatusVisual(String formMilestone) {
    final m = formMilestone.trim().toUpperCase();
    if (m == 'CONTINUE' || m == 'REVIEWED BY SERVICE ADMIN') {
      return (
        text: _s.continueLabel,
        color: clrGreen,
        icon: Icons.play_circle_outline,
      );
    }
    if (m == 'HOLD' || m == 'HOLD BY SERVICE ADMIN') {
      return (
        text: _s.holdLabel,
        color: Colors.orange.shade800,
        icon: Icons.pause_circle_outline,
      );
    }
    return (text: null, color: null, icon: null);
  }

  Widget _buildServiceSupportCommentInfoTile(PostList forms) {
    final milestoneUi = _serviceSupportMilestoneStatusVisual(
      forms.formMilestone,
    );
    return _buildInfoTile(
      icon: Icons.comment_bank_outlined,
      label: _s.serviceSupportComment,
      value: forms.formSadminComment,
      statusText: milestoneUi.text,
      statusColor: milestoneUi.color,
      statusIcon: milestoneUi.icon,
      trailing: _canAccessRequestOrderTool
          ? _buildCommentCardTrailingAction(
              icon: Icons.rate_review_outlined,
              label: _s.serviceSupportReview,
              backgroundColor: Colors.indigo,
              tooltip: _canServiceSupportReviewByMilestone(forms)
                  ? _s.serviceSupportReview
                  : _s.serviceSupportReviewDisabled,
              onPressed: _canServiceSupportReviewByMilestone(forms)
                  ? () => _showServiceAdminReviewDialog(forms)
                  : null,
            )
          : null,
    );
  }

  bool get _canAccessRequestOrderTool {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SERVICE_ADMIN' || currentLevel == 'SUPERADMIN';
  }

  bool get _canAccessDeptHeadApproval {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'HEAD_SERVICE' || currentLevel == 'SUPERADMIN';
  }

  bool _canAccessSupervisorApproval(PostList forms) {
    final currentLevel = level.trim().toUpperCase();
    if (currentLevel == 'SUPERADMIN') return true;
    final currentUserId = superiorId.trim();
    final formSuperiorId = forms.superiorId.trim();
    if (currentUserId.isEmpty || formSuperiorId.isEmpty) return false;
    return currentUserId == formSuperiorId;
  }

  /// Superior Approval hanya saat milestone CHECK BY TOOL STORE.
  bool _canSuperiorApprovalByMilestone(PostList forms) {
    return _normFormMilestone(forms.formMilestone) == 'CHECK BY TOOL STORE';
  }

  /// Service Support Review hanya saat milestone SUPERIOR APPROVED atau HOLD BY SERVICE ADMIN.
  bool _canServiceSupportReviewByMilestone(PostList forms) {
    final n = _normFormMilestone(forms.formMilestone);
    return n == 'SUPERIOR APPROVED' || n == 'HOLD BY SERVICE ADMIN';
  }

  /// Dept Head Approval hanya saat milestone REVIEWED BY SERVICE ADMIN atau REJECTED BY SERVICE DEPT. HEAD.
  bool _canDeptHeadApprovalByMilestone(PostList forms) {
    final n = _normFormMilestone(forms.formMilestone);
    return n == 'REVIEWED BY SERVICE ADMIN' ||
        n == 'REJECTED BY SERVICE DEPT HEAD';
  }

  bool get _canEditDeletePurchaseOrder {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'TOOL_KEEPER';
  }

  /// PO Add/Edit/Delete hanya saat belum ada data Sales Order untuk baris tool ini.
  bool _canManagePurchaseOrderWhenSalesOrderBlank(bool salesOrderExists) {
    return !salesOrderExists;
  }

  String get _poActionsBlockedTooltip => AppStrings.current.poLockedBeforeSo;

  /// SO Add/Edit/Delete hanya saat belum ada Date WH Received untuk baris tool ini.
  bool _canManageSalesOrderWhenWhReceivedBlank(bool whReceivedExists) {
    return !whReceivedExists;
  }

  String get _soActionsBlockedTooltip => AppStrings.current.soLockedBeforeWh;

  /// Date WH Received Add/Edit/Delete hanya saat belum ada Date Tool Room Received.
  bool _canManageWhReceivedWhenToolRoomBlank(bool toolRoomReceivedExists) {
    return !toolRoomReceivedExists;
  }

  String get _whReceivedActionsBlockedTooltip =>
      AppStrings.current.whLockedBeforeToolRoom;

  bool get _canManageSalesOrderPr {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' ||
        currentLevel == 'COUNTER' ||
        currentLevel == 'GA';
  }

  bool get _canManageRcvWhDate {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'WH';
  }

  bool get _canManageRcvToolDate {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'TOOL_KEEPER';
  }

  bool get _canAddToolToForm {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'TOOL_KEEPER';
  }

  bool _formHasTools(AppState state, PostList forms) {
    return state.formsDetailState.formsDetail.any(
      (itemTool) => itemTool.idForm == forms.idForm,
    );
  }

  /// Request Order hanya saat milestone kosong, DRAFT, atau CHECK BY TOOL STORE.
  bool _canRequestOrderByMilestone(PostList forms) {
    final n = _normFormMilestone(forms.formMilestone);
    return n.isEmpty || n == 'DRAFT';
  }

  /// Add Tool hanya saat milestone kosong (blank) atau DRAFT.
  bool _canAddToolByMilestone(PostList forms) {
    final n = _normFormMilestone(forms.formMilestone);
    return n.isEmpty || n == 'DRAFT';
  }

  Future<void> _openAddToolForm(PostList forms) async {
    _rememberExpandedForm(forms.idForm);
    await postMultipleToolCont(
      '',
      forms.idForm,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      context,
      navigateAsAdd: true,
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openEditRequestForm(PostList forms) async {
    _rememberExpandedForm(forms.idForm);
    final returnedId = await postContForm<String>(
      forms.idForm,
      forms.formNo,
      forms.formServName,
      forms.formServComment,
      forms.formDateServName,
      forms.formCheckBy,
      forms.formDateCheckBy,
      forms.formSuperiorAprd,
      forms.formSuperiorComment,
      forms.formSadminComment,
      forms.formSheadAprd,
      forms.formSheadComment,
      forms.fromDateUpdate,
      forms.formUserUpdate,
      forms.formDateSuperiorAprd,
      forms.formDateSadminComment,
      forms.formDateSheadAprd,
      forms.formMilestone,
      forms.formStatusOrder,
      context,
    );
    if (!mounted) return;
    if (returnedId == null || returnedId.trim().isEmpty) return;
    _rememberExpandedForm(returnedId);
    await _refreshData();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openEditToolDetail(
    PostList forms,
    PostList itemTool,
    int index,
  ) async {
    _rememberExpandedForm(forms.idForm);
    await postMultipleToolCont(
      '${index + 1}',
      itemTool.idForm,
      itemTool.idFormDetail,
      itemTool.formComment,
      itemTool.pnGroup,
      itemTool.pnDesc,
      itemTool.qty,
      itemTool.explan,
      itemTool.actionNote,
      itemTool.valType,
      itemTool.partValue,
      context,
    );
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildCheckByInfoTileTrailing(PostList forms) {
    return StoreConnector<AppState, bool>(
      converter: (store) => _formHasTools(store.state, forms),
      builder: (context, hasTools) {
        final s = context.s;
        if (!hasTools && _canAddToolToForm) {
          final canAdd = _canAddToolByMilestone(forms);
          return _buildCommentCardTrailingAction(
            icon: Icons.add_circle_outline,
            label: s.addTool,
            backgroundColor: Colors.orange.shade700,
            tooltip: canAdd ? s.addTool : s.addToolDisabled,
            onPressed: canAdd ? () => _openAddToolForm(forms) : null,
          );
        }
        if (hasTools && _canAccessRequestOrderTool) {
          final canRequest = _canRequestOrderByMilestone(forms);
          return _buildCommentCardTrailingAction(
            icon: Icons.local_mall_outlined,
            label: s.requestOrder,
            backgroundColor: Colors.deepOrange.shade600,
            tooltip: canRequest ? s.requestOrderTool : s.requestOrderDisabled,
            onPressed: canRequest
                ? () => _showRequestOrderToolDialog(forms)
                : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildToolListHeaderTrailing(PostList forms) {
    return StoreConnector<AppState, bool>(
      converter: (store) => _formHasTools(store.state, forms),
      builder: (context, hasTools) {
        if (hasTools && _canAddToolToForm) {
          return _buildAddToolHeaderAction(forms);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
    String? statusText,
    Color? statusColor,
    IconData? statusIcon,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= mobileWidth;
    final tilePadding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 7)
        : const EdgeInsets.all(12);
    return Container(
      padding: tilePadding,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.black : context.mutedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: clrOrange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (statusText != null && statusText.isNotEmpty) ...[
                        TextSpan(
                          text: ' - ',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (statusIcon != null)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                statusIcon,
                                size: 13,
                                color: statusColor ?? context.textSecondary,
                              ),
                            ),
                          ),
                        TextSpan(
                          text: statusText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: statusColor ?? context.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  _displayValue(value),
                  maxLines: 2,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    IconData icon = Icons.label_outline,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: clrOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  static const int _orderTimelineStepCount = 7;

  /// Canonical [PostList.formMilestone] values aligned with [_buildOrderStatusTimeline] steps.
  static const List<String> _orderTimelineNextMilestoneLabels = [
    '1. CHECK BY TOOL STORE',
    '2. SUPERIOR APPROVED',
    '3. REVIEWED BY SERVICE ADMIN',
    '4. APPROVED BY SERVICE DEPT HEAD',
    '5. PROCESSING ORDER',
    '6. RECEIVED BY WH/GA',
    '7. RECEIVED TOOL STORE',
  ];

  static const double _timelineAboveBand = 80;
  static const double _timelineBelowBand = 80;
  static const double _timelineNodeDiameter = 28;
  static const double _timelineVConnectorHeight = 8;

  /// Milestone text normalized for comparisons (case, dots, runs of spaces).
  static String _normFormMilestone(String raw) {
    return raw
        .trim()
        .toUpperCase()
        .replaceAll('.', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Highest completed step count (0–7) from [forms.formMilestone] alone.
  static int _filledStepsFromMilestoneNorm(String n) {
    if (n.isEmpty || n == 'DRAFT') return 0;
    if (n == 'RECEIVED TOOL STORE' || n == 'RECEIVED BY TOOL STORE') {
      return 7;
    }
    if (n == 'PARTIAL RECEIVED TOOL STORE' ||
        n == 'PARTIAL RECEIVED BY TOOL STORE') {
      return 6;
    }
    if (n == 'RECEIVED BY WH/GA') {
      return 6;
    }
    if (n == 'PARTIAL RECEIVED BY WH/GA') {
      return 5;
    }
    if (n == 'ORDER PROCESSED' || n == 'PROCESSING ORDER') return 5;
    if (n == 'APPROVED BY SERVICE DEPT HEAD') return 4;
    if (n == 'REVIEWED BY SERVICE ADMIN' || n == 'CONTINUE') return 3;
    if (n == 'SUPERIOR APPROVED') return 2;
    if (n == 'CHECK BY TOOL STORE') return 1;
    return 0;
  }

  /// Timeline segment fill and per-step styling for the order workflow.
  _OrderTimelineViewModel _computeOrderTimelineViewModel(
    Store<AppState> store,
    PostList forms,
  ) {
    if (forms.idForm.trim().isEmpty) {
      return const _OrderTimelineViewModel(orangeCompleted: 0);
    }

    final mUpper = forms.formMilestone.trim().toUpperCase();
    final n = _normFormMilestone(forms.formMilestone);

    if (mUpper == 'REJECTED BY SUPERIOR' || n == 'REJECTED BY SUPERIOR') {
      return const _OrderTimelineViewModel(orangeCompleted: 1, redStepIndex: 1);
    }
    if (n == 'REJECTED BY SERVICE DEPT HEAD') {
      return const _OrderTimelineViewModel(orangeCompleted: 3, redStepIndex: 3);
    }
    if (mUpper == 'HOLD BY SERVICE ADMIN' || n == 'HOLD BY SERVICE ADMIN') {
      return const _OrderTimelineViewModel(orangeCompleted: 2, redStepIndex: 2);
    }

    var filled = _filledStepsFromMilestoneNorm(n);

    if (_isApprovedValue(forms.formSuperiorAprd)) {
      filled = max(filled, 2);
    }
    if (forms.formSadminComment.trim().isNotEmpty) {
      filled = max(filled, 3);
    }
    if (_isApprovedValue(forms.formSheadAprd)) {
      filled = max(filled, 4);
    }

    final tools = store.state.formsDetailState.formsDetail
        .where((t) => t.idForm.trim() == forms.idForm.trim())
        .toList();
    int? partialStepIndex;
    double? partialProgress;
    String? partialCountLabel;

    if (filled >= 5 && tools.isNotEmpty) {
      final detailIds = tools
          .map((e) => e.idFormDetail.trim())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (detailIds.isNotEmpty) {
        final total = detailIds.length;
        final rcvWhFilledIds = store.state.rcvWhState.rcvWhs
            .map((r) => r.idFormDetail.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        final rcvToolFilledIds = store.state.rcvToolState.rcvTools
            .map((r) => r.idFormDetail.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        final whCount = detailIds.where(rcvWhFilledIds.contains).length;
        final toolCount = detailIds.where(rcvToolFilledIds.contains).length;
        final allRcvWh = whCount == total;
        final anyRcvWh = whCount > 0;
        final allRcvTool = toolCount == total;
        final anyRcvTool = toolCount > 0;

        // Step 7 (index 6) Tool received / Step 6 (index 5) WH received.
        if (allRcvTool) {
          filled = max(filled, 7);
        } else if (anyRcvTool) {
          filled = max(filled, 6);
          partialStepIndex = 6;
          partialProgress = toolCount / total;
          partialCountLabel = '$toolCount/$total';
        } else if (allRcvWh) {
          filled = max(filled, 6);
        } else if (anyRcvWh) {
          filled = max(filled, 5);
          partialStepIndex = 5;
          partialProgress = whCount / total;
          partialCountLabel = '$whCount/$total';
        }
      }
    }

    // Milestone mengikat step 6 (WH) dan 7 (Tool) — sama seperti logika partial WH.
    switch (n) {
      case 'RECEIVED TOOL STORE':
      case 'RECEIVED BY TOOL STORE':
        filled = _orderTimelineStepCount;
        partialStepIndex = null;
        partialProgress = null;
        partialCountLabel = null;
        break;
      case 'PARTIAL RECEIVED TOOL STORE':
      case 'PARTIAL RECEIVED BY TOOL STORE':
        filled = max(filled, 6);
        partialStepIndex = 6;
        partialProgress = 0.5;
        partialCountLabel ??= _s.partial;
        break;
      case 'RECEIVED BY WH/GA':
        filled = max(filled, 6);
        if (partialStepIndex == 6) {
          partialStepIndex = null;
          partialProgress = null;
          partialCountLabel = null;
        }
        break;
      case 'PARTIAL RECEIVED BY WH/GA':
        filled = max(filled, 5);
        partialStepIndex = 5;
        partialProgress = partialProgress ?? 0.5;
        partialCountLabel ??= _s.partial;
        break;
      default:
        break;
    }

    return _OrderTimelineViewModel(
      orangeCompleted: filled.clamp(0, _orderTimelineStepCount),
      partialStepIndex: partialStepIndex,
      partialProgress: partialProgress?.clamp(0.0, 1.0),
      partialCountLabel: partialCountLabel,
    );
  }

  /// Milestone string for the upcoming workflow step (matches timeline step cards).
  static String _nextOrderTimelineMilestoneLabel(_OrderTimelineViewModel vm) {
    if (vm.redStepIndex != null) {
      final i = vm.redStepIndex!.clamp(0, _orderTimelineStepCount - 1);
      return _orderTimelineNextMilestoneLabels[i];
    }
    final nextIdx = vm.orangeCompleted.clamp(0, _orderTimelineStepCount);
    if (nextIdx >= _orderTimelineStepCount) {
      return AppStrings.current.completedStatus;
    }
    return _orderTimelineNextMilestoneLabels[nextIdx];
  }

  bool _timelineStepIsPartial(_OrderTimelineViewModel vm, int stepIndex) {
    if (vm.redStepIndex != null) return false;
    final p = vm.partialProgress;
    return vm.partialStepIndex == stepIndex && p != null && p > 0 && p < 1;
  }

  double _timelinePartialProgress(_OrderTimelineViewModel vm, int stepIndex) {
    if (!_timelineStepIsPartial(vm, stepIndex)) return 0;
    return vm.partialProgress!.clamp(0.0, 1.0);
  }

  Widget _buildPartialFilledCircle({
    required double diameter,
    required double progress,
    required Color activeColor,
    required Color inactiveFill,
    required Color borderColor,
    Widget? centerChild,
  }) {
    final t = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          SizedBox(
            width: diameter,
            height: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inactiveFill,
                border: Border.all(color: borderColor, width: 2),
              ),
            ),
          ),
          SizedBox(
            width: diameter,
            height: diameter,
            child: ClipOval(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: t,
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: ColoredBox(color: activeColor),
                ),
              ),
            ),
          ),
          SizedBox(
            width: diameter,
            height: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t >= 1
                      ? activeColor
                      : activeColor.withValues(alpha: 0.85),
                  width: 2,
                ),
              ),
            ),
          ),
          ?centerChild,
        ],
      ),
    );
  }

  /// Lingkaran penuh seragam untuk timeline mobile (sama bentuk semua step).
  Widget _buildMobileTimelineCircle({
    required double size,
    required Color fill,
    required Color borderColor,
    required Widget child,
    double borderWidth = 2,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildHorizontalTrackSegments({
    required int completed,
    required double trackHeight,
    _OrderTimelineViewModel? partialVm,
  }) {
    final activeColor = clrOrange;
    final connectorMuted = context.connectorMuted;
    final capR = trackHeight / 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        for (int k = 0; k < _orderTimelineStepCount - 1; k++)
          Expanded(
            flex: 2,
            child: Builder(
              builder: (context) {
                final partialStep = partialVm?.partialStepIndex;
                final partialT = partialVm?.partialProgress;
                final isApproachPartial =
                    partialStep != null &&
                    partialT != null &&
                    partialT > 0 &&
                    partialT < 1 &&
                    k == partialStep - 1;
                if (isApproachPartial) {
                  final t = partialT.clamp(0.0, 1.0);
                  final leftFlex = (t * 1000).round().clamp(1, 999);
                  final rightFlex = ((1 - t) * 1000).round().clamp(1, 999);
                  return ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                      left: k == 0 ? Radius.circular(capR) : Radius.zero,
                      right: k == _orderTimelineStepCount - 2
                          ? Radius.circular(capR)
                          : Radius.zero,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: leftFlex,
                          child: Container(
                            height: trackHeight,
                            color: activeColor,
                          ),
                        ),
                        Expanded(
                          flex: rightFlex,
                          child: Container(
                            height: trackHeight,
                            color: connectorMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: k < completed ? activeColor : connectorMuted,
                    borderRadius: BorderRadius.horizontal(
                      left: k == 0 ? Radius.circular(capR) : Radius.zero,
                      right: k == _orderTimelineStepCount - 2
                          ? Radius.circular(capR)
                          : Radius.zero,
                    ),
                  ),
                );
              },
            ),
          ),
        const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }

  Widget _buildOrderStatusTimeline(
    _OrderTimelineViewModel vm, {
    bool wrapInPanel = true,
  }) {
    final steps = _s.workflowSteps;

    final panelBg = context.isDarkMode
        ? Colors.black
        : clrOrange.withValues(alpha: 0.08);
    final activeColor = clrOrange;
    final errorColor = Colors.red.shade700;
    final inactiveCardBg = context.mutedSurface;
    final inactiveTitle = context.inactiveTitle;
    final connectorMuted = context.connectorMuted;
    final isMobile = MediaQuery.sizeOf(context).width < mobileWidth;
    final orangeSteps = vm.orangeCompleted.clamp(0, _orderTimelineStepCount);
    final trackOrangeThrough = (vm.redStepIndex ?? vm.orangeCompleted).clamp(
      0,
      _orderTimelineStepCount,
    );
    const trackHeight = 3.0;
    final mobileStepSize = 36.0;
    final mobileNodeSize = _timelineNodeDiameter;
    final aboveBand = isMobile ? 62.0 : _timelineAboveBand + 18;
    final belowBand = isMobile ? 62.0 : _timelineBelowBand + 18;
    final connectorGap = isMobile ? 4.0 : 4.0;
    final panelPadding = wrapInPanel
        ? (isMobile
              ? const EdgeInsets.fromLTRB(6, 6, 6, 6)
              : const EdgeInsets.fromLTRB(8, 8, 8, 8))
        : (isMobile
              ? const EdgeInsets.fromLTRB(6, 2, 6, 6)
              : const EdgeInsets.fromLTRB(8, 2, 8, 8));

    Widget timelineNode(int i) {
      final isRed = vm.redStepIndex == i;
      final isPartial = _timelineStepIsPartial(vm, i);
      final isOrangeDone = !isRed && !isPartial && i < orangeSteps;
      final accent = isRed ? errorColor : activeColor;
      if (isPartial) {
        final t = _timelinePartialProgress(vm, i);
        if (isMobile) {
          return _buildMobileTimelineCircle(
            size: mobileNodeSize,
            fill: context.cardSurface,
            borderColor: accent,
            child: Icon(Icons.more_horiz, size: 14, color: accent),
          );
        }
        return _buildPartialFilledCircle(
          diameter: _timelineNodeDiameter,
          progress: t,
          activeColor: accent,
          inactiveFill: context.cardSurface,
          borderColor: accent,
          centerChild: Text(
            '${(t * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }
      return Container(
        width: isMobile ? mobileNodeSize : _timelineNodeDiameter,
        height: isMobile ? mobileNodeSize : _timelineNodeDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isOrangeDone || isRed) ? accent : context.cardSurface,
          border: Border.all(
            color: (isOrangeDone || isRed) ? accent : context.connectorMuted,
            width: 2,
          ),
          boxShadow: (isOrangeDone || isRed)
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: isRed
            ? const Icon(Icons.close, color: Colors.white, size: 15)
            : (isOrangeDone
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : null),
      );
    }

    Widget stepCard(int i) {
      final isRed = vm.redStepIndex == i;
      final isPartial = _timelineStepIsPartial(vm, i);
      final isOrangeDone = !isRed && !isPartial && i < orangeSteps;
      final title = steps[i].$1;
      final subtitle = steps[i].$2;
      final accent = isRed ? errorColor : activeColor;
      final partialLabel = isPartial && vm.partialCountLabel != null
          ? _s.partialWithCount(vm.partialCountLabel!)
          : isPartial
          ? _s.partial
          : subtitle;
      if (isMobile) {
        final stepSize = mobileStepSize;
        Widget circle;
        if (isPartial) {
          circle = _buildMobileTimelineCircle(
            size: stepSize,
            fill: inactiveCardBg,
            borderColor: accent,
            child: Text(
              '${i + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          );
        } else {
          circle = _buildMobileTimelineCircle(
            size: stepSize,
            fill: (isOrangeDone || isRed) ? accent : inactiveCardBg,
            borderColor: (isOrangeDone || isRed) ? accent : context.cardBorder,
            child: Text(
              '${i + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: (isOrangeDone || isRed) ? Colors.white : inactiveTitle,
              ),
            ),
          );
        }
        final tooltipMsg = isPartial && vm.partialCountLabel != null
            ? '$title\n$partialLabel (${vm.partialCountLabel})'
            : '$title\n$partialLabel';
        return Tooltip(
          message: tooltipMsg,
          waitDuration: const Duration(milliseconds: 300),
          showDuration: const Duration(seconds: 5),
          preferBelow: i.isEven,
          child: Center(child: circle),
        );
      }
      if (isPartial) {
        final t = _timelinePartialProgress(vm, i);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: inactiveCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  height: 1.15,
                  color: inactiveTitle,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                partialLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  height: 1.2,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: t,
                  minHeight: 4,
                  backgroundColor: connectorMuted,
                  color: accent,
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: (isOrangeDone || isRed) ? accent : inactiveCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isOrangeDone || isRed) ? accent : context.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1.15,
                color: (isOrangeDone || isRed) ? Colors.white : inactiveTitle,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 8,
                height: 1.2,
                color: (isOrangeDone || isRed)
                    ? Colors.white.withValues(alpha: 0.9)
                    : context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    Widget verticalConnector(int i) {
      final isPartial = _timelineStepIsPartial(vm, i);
      if (isPartial) {
        final t = _timelinePartialProgress(vm, i);
        final h = _timelineVConnectorHeight;
        final activeH = (h * t).clamp(1.0, h);
        return SizedBox(
          width: 2,
          height: h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 2,
                height: activeH,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 2,
                height: h - activeH,
                decoration: BoxDecoration(
                  color: connectorMuted,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        );
      }
      final lineActive = vm.redStepIndex != null
          ? i <= vm.redStepIndex!
          : i < orangeSteps;
      return Container(
        width: 2,
        height: _timelineVConnectorHeight,
        decoration: BoxDecoration(
          color: lineActive ? activeColor : connectorMuted,
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }

    final nodeBand = isMobile ? mobileNodeSize : _timelineNodeDiameter;
    final trackTop = aboveBand + nodeBand / 2 - trackHeight / 2;
    final stackHeight = aboveBand + nodeBand + belowBand;

    final timelineBody = SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: trackTop,
            height: trackHeight,
            child: _buildHorizontalTrackSegments(
              completed: trackOrangeThrough,
              trackHeight: trackHeight,
              partialVm: vm,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_orderTimelineStepCount, (i) {
              final cardAbove = i.isEven;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 2,
                    right: i == _orderTimelineStepCount - 1 ? 0 : 2,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: aboveBand,
                        child: cardAbove
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  stepCard(i),
                                  SizedBox(height: connectorGap),
                                  verticalConnector(i),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(
                        height: isMobile
                            ? mobileNodeSize
                            : _timelineNodeDiameter,
                        child: Center(child: timelineNode(i)),
                      ),
                      SizedBox(
                        height: belowBand,
                        child: !cardAbove
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  verticalConnector(i),
                                  SizedBox(height: connectorGap),
                                  stepCard(i),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );

    if (!wrapInPanel) {
      return Padding(padding: panelPadding, child: timelineBody);
    }

    return Container(
      width: double.infinity,
      padding: panelPadding,
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? context.cardBorder
              : clrOrange.withValues(alpha: 0.18),
        ),
      ),
      child: timelineBody,
    );
  }

  Future<bool> _showSubmitConfirmationDialog({
    required BuildContext dialogContext,
    required String title,
    required String message,
    IconData icon = Icons.task_alt_outlined,
  }) async {
    final confirmed = await showGeneralDialog<bool>(
      context: dialogContext,
      barrierDismissible: true,
      barrierLabel: 'confirm-submit',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (confirmContext, animation, secondaryAnimation) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: clrOrange.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: clrOrange, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(confirmContext).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: Theme.of(
              confirmContext,
            ).textTheme.bodyMedium?.copyWith(color: context.bodyMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext, false),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(confirmContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: clrOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_s.yes),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
    return confirmed == true;
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToolHeaderAction(PostList forms) {
    final canAdd = _canAddToolByMilestone(forms);
    final tooltip = canAdd ? _s.addTool : _s.addToolDisabled;
    final isMobile = MediaQuery.sizeOf(context).width < mobileWidth;
    if (isMobile) {
      return IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          disabledBackgroundColor: Colors.orange.shade700.withValues(
            alpha: 0.35,
          ),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 20),
        onPressed: canAdd ? () => _openAddToolForm(forms) : null,
      );
    }
    return _buildActionButton(
      icon: Icons.add_circle_outline,
      label: _s.addTool,
      backgroundColor: Colors.orange.shade700,
      onPressed: canAdd ? () => _openAddToolForm(forms) : null,
    );
  }

  /// Tombol aksi di card komentar: teks + ikon di layar lebar (desktop), ikon saja di mobile.
  Widget _buildCommentCardTrailingAction({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= mobileWidth;
    if (isDesktop) {
      return Tooltip(
        message: tooltip,
        child: SizedBox(
          height: 38,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              disabledBackgroundColor: backgroundColor.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: onPressed != null
            ? backgroundColor
            : backgroundColor.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
    );
  }

  Widget _buildLineItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              _displayValue(value),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _detailSubCardDecoration() {
    return BoxDecoration(
      color: context.detailSubCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.detailSubCardBorder),
    );
  }

  BoxDecoration _detailSubCardIconDecoration() {
    return BoxDecoration(
      color: context.detailSubCardIconBg,
      borderRadius: BorderRadius.circular(12),
    );
  }

  TextStyle? _detailSubCardTitleStyle() {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: context.textPrimary,
    );
  }

  Future<void> _showSupervisorValidationDialog(PostList forms) async {
    final formKey = GlobalKey<FormState>();
    final initialApproval = forms.formSuperiorAprd.trim().toUpperCase();
    String? selectedApproval;
    if (initialApproval == 'APPROVED' ||
        initialApproval == 'APPROVE' ||
        initialApproval == 'Y' ||
        initialApproval == 'YES') {
      selectedApproval = 'APPROVED';
    } else if (initialApproval == 'REJECTED' ||
        initialApproval == 'REJECT' ||
        initialApproval == 'N' ||
        initialApproval == 'NO') {
      selectedApproval = 'REJECTED';
    }
    final commentController = TextEditingController(
      text: forms.formSuperiorComment.trim(),
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (statefulContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: clrOrange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.fact_check_outlined,
                      color: clrOrange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_s.superiorValidation)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedApproval,
                      decoration: InputDecoration(
                        labelText: _s.supervisorApproval,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'APPROVED',
                          child: Text(_s.approved),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text(_s.rejected),
                        ),
                      ],
                      onChanged: (value) {
                        selectedApproval = value;
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _s.approvalRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: _s.supervisorComment,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _s.commentRequired;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(_s.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: _s.confirmSupervisorValidation,
                            message: _s.confirmSupervisorValidationMsg,
                            icon: Icons.fact_check_outlined,
                          );
                          if (confirmed != true) return;
                          setStateDialog(() => isSubmitting = true);
                          try {
                            final responseList = await store.dispatch(
                              getDataTool(
                                param: paramEditDataForm,
                                idForm: forms.idForm.trim(),
                                formNo: forms.formNo.trim(),
                                formServName: forms.formServName.trim(),
                                formCheckBy: forms.formCheckBy.trim(),
                                formDateCheckBy: forms.formDateCheckBy.trim(),
                                formDateServName: forms.formDateServName.trim(),
                                formServComment: forms.formServComment.trim(),
                                formSuperiorAprd: (selectedApproval ?? '')
                                    .trim(),
                                formSuperiorComment: commentController.text
                                    .trim(),
                                formSadminComment: forms.formSadminComment
                                    .trim(),
                                formMilestone: switch ((selectedApproval ?? '')
                                    .trim()) {
                                  'APPROVED' => 'SUPERIOR APPROVED',
                                  'REJECTED' => 'REJECTED BY SUPERIOR',
                                  _ => forms.formMilestone.trim(),
                                },
                                formStatusOrder: forms.formStatusOrder.trim(),
                                formSheadAprd: forms.formSheadAprd.trim(),
                                formSheadComment: forms.formSheadComment.trim(),
                                fromDateUpdate: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                                formUserUpdate: idUsersApp.isNotEmpty
                                    ? idUsersApp
                                    : forms.formUserUpdate.trim(),
                              ),
                            );

                            final apiResponse =
                                responseList is List && responseList.isNotEmpty
                                ? responseList.last
                                : null;
                            final responseValue =
                                apiResponse?.valueResponse.toString() ?? "";
                            final responseMessage =
                                apiResponse?.messageResponse.toString() ?? "";
                            final isSuccess = responseValue == "1";

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                content: Text(
                                  responseMessage.isNotEmpty
                                      ? responseMessage
                                      : (isSuccess
                                            ? _s.supervisorValidationSaved
                                            : _s.failedSavingValidation),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await _refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_s.failedSavingValidation),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setStateDialog(() => isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: clrGreen),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_s.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeptHeadValidationDialog(PostList forms) async {
    final formKey = GlobalKey<FormState>();
    final initialApproval = forms.formSheadAprd.trim().toUpperCase();
    String? selectedApproval;
    if (initialApproval == 'APPROVED' ||
        initialApproval == 'APPROVE' ||
        initialApproval == 'Y' ||
        initialApproval == 'YES') {
      selectedApproval = 'APPROVED';
    } else if (initialApproval == 'REJECTED' ||
        initialApproval == 'REJECT' ||
        initialApproval == 'N' ||
        initialApproval == 'NO') {
      selectedApproval = 'REJECTED';
    }
    final commentController = TextEditingController(
      text: forms.formSheadComment.trim(),
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (statefulContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: clrOrange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      color: clrOrange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_s.deptHeadApprovalDialog)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedApproval,
                      decoration: InputDecoration(
                        labelText: _s.serviceDeptHeadApproval,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'APPROVED',
                          child: Text(_s.approved),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text(_s.rejected),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedApproval = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _s.approvalRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: _s.serviceDeptHeadComment,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _s.commentRequired;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(_s.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: _s.confirmDeptHeadApproval,
                            message: _s.confirmDeptHeadApprovalMsg,
                            icon: Icons.verified_outlined,
                          );
                          if (confirmed != true) return;
                          setStateDialog(() => isSubmitting = true);
                          try {
                            final responseList = await store.dispatch(
                              getDataTool(
                                param: paramEditDataForm,
                                idForm: forms.idForm.trim(),
                                formNo: forms.formNo.trim(),
                                formServName: forms.formServName.trim(),
                                formCheckBy: forms.formCheckBy.trim(),
                                formDateCheckBy: forms.formDateCheckBy.trim(),
                                formDateServName: forms.formDateServName.trim(),
                                formServComment: forms.formServComment.trim(),
                                formSuperiorAprd: forms.formSuperiorAprd.trim(),
                                formSuperiorComment: forms.formSuperiorComment
                                    .trim(),
                                formSadminComment: forms.formSadminComment
                                    .trim(),
                                formMilestone: switch ((selectedApproval ?? '')
                                    .trim()) {
                                  'APPROVED' =>
                                    'APPROVED BY SERVICE DEPT. HEAD',
                                  'REJECTED' =>
                                    'REJECTED BY SERVICE DEPT. HEAD',
                                  _ => forms.formMilestone.trim(),
                                },
                                formStatusOrder: forms.formStatusOrder.trim(),
                                formSheadAprd: (selectedApproval ?? '').trim(),
                                formSheadComment: commentController.text.trim(),
                                fromDateUpdate: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                                formUserUpdate: idUsersApp.isNotEmpty
                                    ? idUsersApp
                                    : forms.formUserUpdate.trim(),
                              ),
                            );

                            final apiResponse =
                                responseList is List && responseList.isNotEmpty
                                ? responseList.last
                                : null;
                            final responseValue =
                                apiResponse?.valueResponse.toString() ?? "";
                            final responseMessage =
                                apiResponse?.messageResponse.toString() ?? "";
                            final isSuccess = responseValue == "1";

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                content: Text(
                                  responseMessage.isNotEmpty
                                      ? responseMessage
                                      : (isSuccess
                                            ? _s.deptHeadApprovalSaved
                                            : _s.failedDeptHeadApproval),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await _refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_s.failedDeptHeadApproval),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setStateDialog(() => isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: clrGreen),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_s.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showServiceAdminReviewDialog(PostList forms) async {
    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController(
      text: forms.formSadminComment.trim(),
    );
    final initialMilestone = forms.formMilestone.trim().toUpperCase();
    String? selectedContinueHold;
    if (initialMilestone == 'CONTINUE' ||
        initialMilestone == 'REVIEWED BY SERVICE ADMIN') {
      selectedContinueHold = 'CONTINUE';
    } else if (initialMilestone == 'HOLD' ||
        initialMilestone == 'HOLD BY SERVICE ADMIN') {
      selectedContinueHold = 'HOLD';
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (statefulContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: clrOrange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.rate_review_outlined,
                      color: clrOrange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_s.serviceAdminReview)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedContinueHold,
                      decoration: InputDecoration(
                        labelText: _s.continueOrHold,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'CONTINUE',
                          child: Text(_s.continueLabel),
                        ),
                        DropdownMenuItem(
                          value: 'HOLD',
                          child: Text(_s.holdLabel),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedContinueHold = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _s.continueOrHoldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: _s.serviceAdminComment,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _s.commentRequired;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(_s.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: _s.confirmServiceAdminReview,
                            message: _s.confirmServiceAdminReviewMsg,
                            icon: Icons.rate_review_outlined,
                          );
                          if (confirmed != true) return;
                          setStateDialog(() => isSubmitting = true);
                          try {
                            final responseList = await store.dispatch(
                              getDataTool(
                                param: paramEditDataForm,
                                idForm: forms.idForm.trim(),
                                formNo: forms.formNo.trim(),
                                formServName: forms.formServName.trim(),
                                formCheckBy: forms.formCheckBy.trim(),
                                formDateCheckBy: forms.formDateCheckBy.trim(),
                                formDateServName: forms.formDateServName.trim(),
                                formServComment: forms.formServComment.trim(),
                                formSuperiorAprd: forms.formSuperiorAprd.trim(),
                                formSuperiorComment: forms.formSuperiorComment
                                    .trim(),
                                formSadminComment: commentController.text
                                    .trim(),
                                formMilestone: switch ((selectedContinueHold ??
                                        '')
                                    .trim()) {
                                  'CONTINUE' => 'REVIEWED BY SERVICE ADMIN',
                                  'HOLD' => 'HOLD BY SERVICE ADMIN',
                                  _ => forms.formMilestone.trim(),
                                },
                                formStatusOrder: forms.formStatusOrder.trim(),
                                formSheadAprd: forms.formSheadAprd.trim(),
                                formSheadComment: forms.formSheadComment.trim(),
                                fromDateUpdate: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                                formUserUpdate: idUsersApp.isNotEmpty
                                    ? idUsersApp
                                    : forms.formUserUpdate.trim(),
                              ),
                            );

                            final apiResponse =
                                responseList is List && responseList.isNotEmpty
                                ? responseList.last
                                : null;
                            final responseValue =
                                apiResponse?.valueResponse.toString() ?? "";
                            final responseMessage =
                                apiResponse?.messageResponse.toString() ?? "";
                            final isSuccess = responseValue == "1";

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                content: Text(
                                  responseMessage.isNotEmpty
                                      ? responseMessage
                                      : (isSuccess
                                            ? "Service admin review saved"
                                            : "Failed saving service admin review"),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await _refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_s.failedServiceAdminReview),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setStateDialog(() => isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: clrGreen),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_s.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showRequestOrderToolDialog(PostList forms) async {
    if (!mounted) return;
    if (!_canRequestOrderByMilestone(forms)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _s.requestOrderOnlyMilestone,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (statefulContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: clrOrange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_mall_outlined,
                      color: clrOrange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_s.requestOrderToolDialog)),
                ],
              ),
              content: Text(
                _s.submitToSuperiorApproval,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(_s.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: _s.confirmRequestOrderTitle,
                            message: _s.confirmRequestOrderMsg,
                            icon: Icons.local_mall_outlined,
                          );
                          if (confirmed != true) return;
                          setStateDialog(() => isSubmitting = true);
                          const milestoneRequestOrder = 'CHECK BY TOOL STORE';
                          final nextCheckBy = name.trim().isNotEmpty
                              ? name.trim()
                              : forms.formCheckBy.trim();
                          final nextDateCheckBy = name.trim().isNotEmpty
                              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
                              : forms.formDateCheckBy.trim();
                          try {
                            final responseList = await store.dispatch(
                              getDataTool(
                                param: paramEditDataForm,
                                idForm: forms.idForm.trim(),
                                formNo: forms.formNo.trim(),
                                formServName: forms.formServName.trim(),
                                formCheckBy: nextCheckBy,
                                formDateCheckBy: nextDateCheckBy,
                                formDateServName: forms.formDateServName.trim(),
                                formServComment: forms.formServComment.trim(),
                                formSuperiorAprd: forms.formSuperiorAprd.trim(),
                                formSuperiorComment: forms.formSuperiorComment
                                    .trim(),
                                formSadminComment: forms.formSadminComment
                                    .trim(),
                                formMilestone: milestoneRequestOrder,
                                formStatusOrder: forms.formStatusOrder.trim(),
                                formSheadAprd: forms.formSheadAprd.trim(),
                                formSheadComment: forms.formSheadComment.trim(),
                                fromDateUpdate: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                                formUserUpdate: idUsersApp.isNotEmpty
                                    ? idUsersApp
                                    : forms.formUserUpdate.trim(),
                              ),
                            );

                            final apiResponse =
                                responseList is List && responseList.isNotEmpty
                                ? responseList.last
                                : null;
                            final responseValue =
                                apiResponse?.valueResponse.toString() ?? "";
                            final responseMessage =
                                apiResponse?.messageResponse.toString() ?? "";
                            final isSuccess = responseValue == "1";

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                content: Text(
                                  responseMessage.isNotEmpty
                                      ? responseMessage
                                      : (isSuccess
                                            ? _s.orderRequestSubmitted
                                            : _s.failedSubmitOrder),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await _refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_s.failedSubmitOrder),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setStateDialog(() => isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: clrOrange),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_s.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdatePurchaseOrderDialog(PostList itemPO) async {
    if (!_canEditDeletePurchaseOrder) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Edit PO hanya untuk SUPERADMIN dan TOOL_KEEPER.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    idPoCont.text = itemPO.idPo.trim();
    poNoCont.text = itemPO.poNo.trim();
    dateUpdatePoCont.text = itemPO.dateUpdatePo.trim();
    userUpdatePoCont.text = itemPO.userUpdatePo.trim();

    final formKey = GlobalKey<FormState>();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_s.updatePurchaseOrder),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form detail: ${itemPO.idFormDetail}',
                    style: Theme.of(dialogContext).textTheme.labelMedium
                        ?.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextFormFields(
                    labelTexts: 'PO number',
                    textColor: clrBlack,
                    controllers: poNoCont,
                    validators: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'PO number is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;
                try {
                  final PoFetchResult editResult =
                      await store.dispatch(
                            getDataPO(
                              param: paramEditDataPO,
                              idPO: idPoCont.text.trim(),
                              idFormDetail: itemPO.idFormDetail.trim(),
                              poNO: poNoCont.text.trim(),
                              dateUpdatePO: DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now()),
                              userUpdatePO: idUsersApp,
                            ),
                          )
                          as PoFetchResult;
                  await store.dispatch(
                    getDataPO(
                      param: paramViewDataPO,
                      idPO: '',
                      idFormDetail: '',
                      poNO: '',
                      dateUpdatePO: '',
                      userUpdatePO: '',
                    ),
                  );
                  if (editResult.statusValue == '1') {
                    await _refreshData();
                    final parent = _parentFormForDetailId(itemPO.idFormDetail);
                    if (parent != null) {
                      final header =
                          _formHeaderFromStore(parent.idForm) ?? parent;
                      _setSearchToFormNumber(header);
                    }
                  }
                  if (!mounted) return;
                  if (editResult.statusValue == '1') {
                    final successText =
                        (editResult.serverMessage != null &&
                            editResult.serverMessage!.isNotEmpty)
                        ? editResult.serverMessage!
                        : 'Purchase order updated';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          successText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    final errText =
                        (editResult.serverMessage != null &&
                            editResult.serverMessage!.isNotEmpty)
                        ? editResult.serverMessage!
                        : _s.requestFailed;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  final errText = e.toString().replaceFirst(
                    RegExp(r'^Exception:\s*'),
                    '',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        errText,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: Text(_s.save, style: TextStyle(color: clrOrange)),
            ),
          ],
        );
      },
    );
  }

  Set<String> _detailIdsForForm(PostList forms) {
    final tools = store.state.formsDetailState.formsDetail
        .where((t) => t.idForm.trim() == forms.idForm.trim())
        .toList();
    if (tools.isEmpty) return const <String>{};
    final ids = tools
        .map((t) => t.idFormDetail.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    if (ids.length != tools.length) return const <String>{};
    return ids;
  }

  /// Parent form header row for a tool line (`id_form_detail`), or null if not found.
  PostList? _parentFormForDetailId(String idFormDetail) {
    final id = idFormDetail.trim();
    if (id.isEmpty) return null;
    String idForm = '';
    for (final t in store.state.formsDetailState.formsDetail) {
      if (t.idFormDetail.trim() == id) {
        idForm = t.idForm.trim();
        break;
      }
    }
    if (idForm.isEmpty) return null;
    for (final f in store.state.formsState.forms) {
      if (f.idForm.trim() == idForm) return f;
    }
    return null;
  }

  PostList? _formHeaderFromStore(String idForm) {
    final id = idForm.trim();
    if (id.isEmpty) return null;
    for (final f in store.state.formsState.forms) {
      if (f.idForm.trim() == id) return f;
    }
    return null;
  }

  Future<void> _dispatchFormMilestoneUpdate(
    PostList forms,
    String newMilestone,
  ) async {
    if (forms.formMilestone.trim().toUpperCase() ==
        newMilestone.trim().toUpperCase()) {
      return;
    }
    try {
      await store.dispatch(
        getDataTool(
          param: paramEditDataForm,
          idForm: forms.idForm.trim(),
          formNo: forms.formNo.trim(),
          formServName: forms.formServName.trim(),
          formCheckBy: forms.formCheckBy.trim(),
          formDateCheckBy: forms.formDateCheckBy.trim(),
          formDateServName: forms.formDateServName.trim(),
          formServComment: forms.formServComment.trim(),
          formSuperiorAprd: forms.formSuperiorAprd.trim(),
          formSuperiorComment: forms.formSuperiorComment.trim(),
          formSadminComment: forms.formSadminComment.trim(),
          formMilestone: newMilestone,
          formStatusOrder: forms.formStatusOrder.trim(),
          formSheadAprd: forms.formSheadAprd.trim(),
          formSheadComment: forms.formSheadComment.trim(),
          fromDateUpdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          formUserUpdate: idUsersApp.isNotEmpty
              ? idUsersApp
              : forms.formUserUpdate.trim(),
        ),
      );
    } catch (_) {}
  }

  /// Sets [forms.formMilestone] from SO coverage across tool lines:
  /// - every detail line has a non-empty SO → `ORDER PROCESSED`;
  /// - at least one line has SO but not all → `PROCESSING ORDER`;
  /// - does not change milestones already past warehouse receipt (step > 5).
  Future<void> _updateFormMilestoneFromSoFillState(PostList forms) async {
    const milestoneOrderProcessed = 'ORDER PROCESSED';
    const milestoneProcessingOrder = 'PROCESSING ORDER';

    final detailIds = _detailIdsForForm(forms);
    if (detailIds.isEmpty) return;

    final currentNorm = _normFormMilestone(forms.formMilestone);
    final filledSteps = _filledStepsFromMilestoneNorm(currentNorm);
    if (filledSteps > 5) return;

    final sosForForm = store.state.sosDetailState.sosDetail
        .where((so) => detailIds.contains(so.idFormDetail.trim()))
        .toList();

    bool detailHasNonEmptySo(String id) {
      return sosForForm.any(
        (so) => so.idFormDetail.trim() == id && so.so.trim().isNotEmpty,
      );
    }

    final allSoFilled = detailIds.every(detailHasNonEmptySo);
    if (allSoFilled) {
      await _dispatchFormMilestoneUpdate(forms, milestoneOrderProcessed);
      return;
    }

    final anySoFilled = detailIds.any(detailHasNonEmptySo);
    if (!anySoFilled) return;

    final currentUpper = forms.formMilestone.trim().toUpperCase();
    if (currentUpper == milestoneOrderProcessed) return;

    await _dispatchFormMilestoneUpdate(forms, milestoneProcessingOrder);
  }

  Future<void> _updateFormMilestoneForRcvWh(PostList forms) async {
    const milestoneFull = 'RECEIVED BY WH/GA';
    const milestonePartial = 'PARTIAL RECEIVED BY WH/GA';

    final detailIds = _detailIdsForForm(forms);
    if (detailIds.isEmpty) return;

    final rcvWhFilledIds = store.state.rcvWhState.rcvWhs
        .map((r) => r.idFormDetail.trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    final filledCount = detailIds.where(rcvWhFilledIds.contains).length;
    if (filledCount == 0) return;

    final targetMilestone = filledCount == detailIds.length
        ? milestoneFull
        : milestonePartial;

    await _dispatchFormMilestoneUpdate(forms, targetMilestone);
  }

  Future<void> _updateFormMilestoneForRcvTool(PostList forms) async {
    const milestoneFull = 'RECEIVED TOOL STORE';
    const milestonePartial = 'PARTIAL RECEIVED TOOL STORE';

    final detailIds = _detailIdsForForm(forms);
    if (detailIds.isEmpty) return;

    final rcvToolFilledDetailIds = store.state.rcvToolState.rcvTools
        .where(
          (r) =>
              r.idFormDetail.trim().isNotEmpty &&
              r.rcvToolDate.trim().isNotEmpty,
        )
        .map((r) => r.idFormDetail.trim())
        .toSet();

    final filledCount = detailIds.where(rcvToolFilledDetailIds.contains).length;
    if (filledCount == 0) return;

    final targetMilestone = filledCount == detailIds.length
        ? milestoneFull
        : milestonePartial;

    await _dispatchFormMilestoneUpdate(forms, targetMilestone);
  }

  Future<void> _showAddPurchaseOrderDialog(
    PostList forms,
    String idFormDetail,
  ) async {
    if (!_canEditDeletePurchaseOrder) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Tambah PO hanya untuk SUPERADMIN dan TOOL_KEEPER.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final addPoNoCont = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_s.addPurchaseOrder),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form detail: $idFormDetail',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'PO number',
                      textColor: clrBlack,
                      controllers: addPoNoCont,
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'PO number is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.bodyMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  try {
                    final PoFetchResult addResult =
                        await store.dispatch(
                              getDataPO(
                                param: paramAddDataPO,
                                idPO: '',
                                idFormDetail: idFormDetail.trim(),
                                poNO: addPoNoCont.text.trim(),
                                dateUpdatePO: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                                userUpdatePO: idUsersApp,
                              ),
                            )
                            as PoFetchResult;
                    await store.dispatch(
                      getDataPO(
                        param: paramViewDataPO,
                        idPO: '',
                        idFormDetail: '',
                        poNO: '',
                        dateUpdatePO: '',
                        userUpdatePO: '',
                      ),
                    );
                    if (addResult.statusValue == '1') {
                      await _refreshData();
                      final header =
                          _formHeaderFromStore(forms.idForm) ?? forms;
                      await _updateFormMilestoneFromSoFillState(header);
                      _setSearchToFormNumber(header);
                    }
                    if (!mounted) return;
                    if (addResult.statusValue == '1') {
                      final successText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : 'Purchase order added';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            successText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final errText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : _s.requestFailed;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    final errText = e.toString().replaceFirst(
                      RegExp(r'^Exception:\s*'),
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(_s.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([addPoNoCont]);
    }
  }

  Future<void> _showDeletePurchaseOrderConfirmDialog(PostList itemPO) async {
    if (!_canEditDeletePurchaseOrder) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Hapus PO hanya untuk SUPERADMIN dan TOOL_KEEPER.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_s.deletePurchaseOrder),
          content: Text(
            'Are you sure you want to delete PO ${_displayValue(itemPO.poNo)}? '
            'This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      final PoFetchResult deleteResult =
          await store.dispatch(
                getDataPO(
                  param: paramDeleteDataPO,
                  idPO: itemPO.idPo.trim(),
                  idFormDetail: itemPO.idFormDetail.trim(),
                  poNO: itemPO.poNo.trim(),
                  dateUpdatePO: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  userUpdatePO: idUsersApp,
                ),
              )
              as PoFetchResult;
      await store.dispatch(
        getDataPO(
          param: paramViewDataPO,
          idPO: '',
          idFormDetail: '',
          poNO: '',
          dateUpdatePO: '',
          userUpdatePO: '',
        ),
      );
      if (deleteResult.statusValue == '1') {
        await _refreshData();
        final parent = _parentFormForDetailId(itemPO.idFormDetail);
        if (parent != null) {
          final header = _formHeaderFromStore(parent.idForm) ?? parent;
          _setSearchToFormNumber(header);
        }
      }
      if (!mounted) return;
      if (deleteResult.statusValue == '1') {
        final successText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : 'Purchase order deleted';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successText,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : _s.deleteFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errText = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errText, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showUpdateSalesOrderDialog(PostList itemSO) async {
    if (!_canManageSalesOrderPr) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. SO/PR hanya untuk SUPERADMIN, COUNTER, dan GA.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    idSoCont.text = itemSO.idSo.trim();
    soCont.text = itemSO.so.trim();
    etaCont.text = itemSO.eta.trim();
    noteSoCont.text = itemSO.noteSo.trim();
    dateUpdateSoCont.text = itemSO.dateUpdateSo.trim();

    final formKey = GlobalKey<FormState>();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_s.updateSalesOrder),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form detail: ${itemSO.idFormDetail}',
                    style: Theme.of(dialogContext).textTheme.labelMedium
                        ?.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextFormFields(
                    labelTexts: 'SO / PR number',
                    textColor: clrBlack,
                    controllers: soCont,
                    validators: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'SO / PR number is required';
                      }
                      return null;
                    },
                  ),
                  TextFormFields(
                    labelTexts: 'ETA',
                    textColor: clrBlack,
                    controllers: etaCont,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.calendar_month_outlined),
                    onTap: () =>
                        _pickDateIntoController(dialogContext, etaCont),
                    validators: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'ETA is required';
                      }
                      return null;
                    },
                  ),
                  TextFormFields(
                    labelTexts: 'Note SO / PR',
                    textColor: clrBlack,
                    controllers: noteSoCont,
                    validators: (_) => null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;
                try {
                  final SoFetchResult editResult =
                      await store.dispatch(
                            getDataSO(
                              param: paramEditDataSO,
                              idSo: idSoCont.text.trim(),
                              idFormDetail: itemSO.idFormDetail.trim(),
                              so: soCont.text.trim(),
                              eta: etaCont.text.trim(),
                              noteSo: noteSoCont.text.trim(),
                              dateUpdateSo: DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now()),
                              idUpdateSo: idUsersApp,
                            ),
                          )
                          as SoFetchResult;
                  await store.dispatch(
                    getDataSO(
                      param: paramViewDataSO,
                      idSo: '',
                      idFormDetail: '',
                      so: '',
                      eta: '',
                      noteSo: '',
                      dateUpdateSo: '',
                      idUpdateSo: '',
                    ),
                  );
                  if (editResult.statusValue == '1') {
                    await _refreshData();
                    final parent = _parentFormForDetailId(itemSO.idFormDetail);
                    if (parent != null) {
                      final header =
                          _formHeaderFromStore(parent.idForm) ?? parent;
                      await _updateFormMilestoneFromSoFillState(header);
                    }
                  }
                  if (!mounted) return;
                  if (editResult.statusValue == '1') {
                    final successText =
                        (editResult.serverMessage != null &&
                            editResult.serverMessage!.isNotEmpty)
                        ? editResult.serverMessage!
                        : 'Sales order updated';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          successText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    final errText =
                        (editResult.serverMessage != null &&
                            editResult.serverMessage!.isNotEmpty)
                        ? editResult.serverMessage!
                        : _s.requestFailed;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  final errText = e.toString().replaceFirst(
                    RegExp(r'^Exception:\s*'),
                    '',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        errText,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: Text(_s.save, style: TextStyle(color: clrOrange)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddSalesOrderDialog(
    PostList forms,
    String idFormDetail,
  ) async {
    if (!_canManageSalesOrderPr) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Tambah SO/PR hanya untuk SUPERADMIN, COUNTER, dan GA.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final addSoCont = TextEditingController();
    final addEtaCont = TextEditingController();
    final addNoteSoCont = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_s.addSalesOrder),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form detail: $idFormDetail',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'SO /PR number',
                      textColor: clrBlack,
                      controllers: addSoCont,
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'SO / PR number is required';
                        }
                        return null;
                      },
                    ),
                    TextFormFields(
                      labelTexts: 'ETA',
                      textColor: clrBlack,
                      controllers: addEtaCont,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                      onTap: () =>
                          _pickDateIntoController(dialogContext, addEtaCont),
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'ETA is required';
                        }
                        return null;
                      },
                    ),
                    TextFormFields(
                      labelTexts: 'Note SO / PR',
                      textColor: clrBlack,
                      controllers: addNoteSoCont,
                      validators: (_) => null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.bodyMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  try {
                    final SoFetchResult addResult =
                        await store.dispatch(
                              getDataSO(
                                param: paramAddDataSO,
                                idSo: '',
                                idFormDetail: idFormDetail.trim(),
                                so: addSoCont.text.trim(),
                                eta: addEtaCont.text.trim(),
                                noteSo: addNoteSoCont.text.trim(),
                                dateUpdateSo: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                                idUpdateSo: idUsersApp,
                              ),
                            )
                            as SoFetchResult;
                    await store.dispatch(
                      getDataSO(
                        param: paramViewDataSO,
                        idSo: '',
                        idFormDetail: '',
                        so: '',
                        eta: '',
                        noteSo: '',
                        dateUpdateSo: '',
                        idUpdateSo: '',
                      ),
                    );
                    if (addResult.statusValue == '1') {
                      await _refreshData();
                      final header =
                          _formHeaderFromStore(forms.idForm) ?? forms;
                      await _updateFormMilestoneFromSoFillState(header);
                    }
                    if (!mounted) return;
                    if (addResult.statusValue == '1') {
                      final successText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : 'Sales order added';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            successText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final errText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : _s.requestFailed;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    final errText = e.toString().replaceFirst(
                      RegExp(r'^Exception:\s*'),
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(_s.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([addSoCont, addEtaCont, addNoteSoCont]);
    }
  }

  Future<void> _showDeleteSalesOrderConfirmDialog(PostList itemSO) async {
    if (!_canManageSalesOrderPr) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Hapus SO/PR hanya untuk SUPERADMIN, COUNTER, dan GA.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_s.deleteSalesOrder),
          content: Text(
            'Are you sure you want to delete SO / PR number ${_displayValue(itemSO.so)}? '
            'This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      final SoFetchResult deleteResult =
          await store.dispatch(
                getDataSO(
                  param: paramDeleteDataSO,
                  idSo: itemSO.idSo.trim(),
                  idFormDetail: itemSO.idFormDetail.trim(),
                  so: itemSO.so.trim(),
                  eta: itemSO.eta.trim(),
                  noteSo: itemSO.noteSo.trim(),
                  dateUpdateSo: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  idUpdateSo: idUsersApp,
                ),
              )
              as SoFetchResult;
      await store.dispatch(
        getDataSO(
          param: paramViewDataSO,
          idSo: '',
          idFormDetail: '',
          so: '',
          eta: '',
          noteSo: '',
          dateUpdateSo: '',
          idUpdateSo: '',
        ),
      );
      if (deleteResult.statusValue == '1') {
        await _refreshData();
        final parent = _parentFormForDetailId(itemSO.idFormDetail);
        if (parent != null) {
          final header = _formHeaderFromStore(parent.idForm) ?? parent;
          _setSearchToFormNumber(header);
        }
      }
      if (!mounted) return;
      if (deleteResult.statusValue == '1') {
        final successText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : 'Sales order / Purchase request (SO/PR) deleted';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successText,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : _s.deleteFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errText = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errText, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showUpdateRcvWhDialog(PostList item) async {
    if (!_canManageRcvWhDate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Mengubah tanggal WH received hanya untuk SUPERADMIN dan WH.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final dateCont = TextEditingController(text: item.rcvWhDate.trim());
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_s.updateDateWhReceived),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form detail: ${item.idFormDetail}',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'Date (yyyy-MM-dd)',
                      textColor: clrBlack,
                      controllers: dateCont,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                      onTap: () =>
                          _pickDateIntoController(dialogContext, dateCont),
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.bodyMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  try {
                    final RcvWhFetchResult editResult =
                        await store.dispatch(
                              getDataRcvWh(
                                param: paramEditDataRcvWh,
                                idRcvWh: item.idRcvWh.trim(),
                                idFormDetail: item.idFormDetail.trim(),
                                rcvWhDate: dateCont.text.trim(),
                                rcvWhIdInput: idUsersApp,
                                rcvWhDateInput: today,
                              ),
                            )
                            as RcvWhFetchResult;
                    await store.dispatch(
                      getDataRcvWh(
                        param: paramViewDataRcvWh,
                        idRcvWh: '',
                        idFormDetail: '',
                        rcvWhDate: '',
                        rcvWhIdInput: '',
                        rcvWhDateInput: '',
                      ),
                    );
                    if (editResult.statusValue == '1') {
                      await _refreshData();
                    }
                    if (!mounted) return;
                    if (editResult.statusValue == '1') {
                      final successText =
                          (editResult.serverMessage != null &&
                              editResult.serverMessage!.isNotEmpty)
                          ? editResult.serverMessage!
                          : 'WH received date updated';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            successText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final errText =
                          (editResult.serverMessage != null &&
                              editResult.serverMessage!.isNotEmpty)
                          ? editResult.serverMessage!
                          : _s.requestFailed;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    final errText = e.toString().replaceFirst(
                      RegExp(r'^Exception:\s*'),
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(_s.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> _showAddRcvWhDialog(PostList forms, String idFormDetail) async {
    if (!_canManageRcvWhDate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Menambah tanggal WH received hanya untuk SUPERADMIN dan WH.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final dateCont = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_s.addDateWhReceived),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form detail: $idFormDetail',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'Date (yyyy-MM-dd)',
                      textColor: clrBlack,
                      controllers: dateCont,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                      onTap: () =>
                          _pickDateIntoController(dialogContext, dateCont),
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.bodyMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  try {
                    final RcvWhFetchResult addResult =
                        await store.dispatch(
                              getDataRcvWh(
                                param: paramAddDataRcvWh,
                                idRcvWh: '',
                                idFormDetail: idFormDetail.trim(),
                                rcvWhDate: dateCont.text.trim(),
                                rcvWhIdInput: idUsersApp,
                                rcvWhDateInput: today,
                              ),
                            )
                            as RcvWhFetchResult;
                    await store.dispatch(
                      getDataRcvWh(
                        param: paramViewDataRcvWh,
                        idRcvWh: '',
                        idFormDetail: '',
                        rcvWhDate: '',
                        rcvWhIdInput: '',
                        rcvWhDateInput: '',
                      ),
                    );
                    if (addResult.statusValue == '1') {
                      await _updateFormMilestoneForRcvWh(forms);
                      await _refreshData();
                    }
                    if (!mounted) return;
                    if (addResult.statusValue == '1') {
                      final successText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : 'WH received date added';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            successText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final errText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : _s.requestFailed;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    final errText = e.toString().replaceFirst(
                      RegExp(r'^Exception:\s*'),
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(_s.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> _showDeleteRcvWhConfirmDialog(PostList item) async {
    if (!_canManageRcvWhDate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Menghapus tanggal WH received hanya untuk SUPERADMIN dan WH.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_s.deleteDateWhReceived),
          content: Text(
            'Are you sure you want to delete the WH received date '
            '${_displayValue(item.rcvWhDate)}? This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      final RcvWhFetchResult deleteResult =
          await store.dispatch(
                getDataRcvWh(
                  param: paramDeleteDataRcvWh,
                  idRcvWh: item.idRcvWh.trim(),
                  idFormDetail: item.idFormDetail.trim(),
                  rcvWhDate: item.rcvWhDate.trim(),
                  rcvWhIdInput: idUsersApp,
                  rcvWhDateInput: today,
                ),
              )
              as RcvWhFetchResult;
      await store.dispatch(
        getDataRcvWh(
          param: paramViewDataRcvWh,
          idRcvWh: '',
          idFormDetail: '',
          rcvWhDate: '',
          rcvWhIdInput: '',
          rcvWhDateInput: '',
        ),
      );
      if (deleteResult.statusValue == '1') {
        await _refreshData();
      }
      if (!mounted) return;
      if (deleteResult.statusValue == '1') {
        final successText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : 'WH received date deleted';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successText,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : _s.deleteFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errText = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errText, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showUpdateRcvToolDialog(PostList item) async {
    if (!_canManageRcvToolDate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Mengubah tanggal Tool Room received hanya untuk SUPERADMIN dan TOOL_KEEPER.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final dateCont = TextEditingController(text: item.rcvToolDate.trim());
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_s.updateDateToolRoomReceived),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form detail: ${item.idFormDetail}',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'Date (yyyy-MM-dd)',
                      textColor: clrBlack,
                      controllers: dateCont,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                      onTap: () =>
                          _pickDateIntoController(dialogContext, dateCont),
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.bodyMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  try {
                    final RcvToolFetchResult editResult =
                        await store.dispatch(
                              getDataRcvTool(
                                param: paramEditDataRcvTool,
                                idRcvTool: item.idRcvTool.trim(),
                                idFormDetail: item.idFormDetail.trim(),
                                rcvToolDate: dateCont.text.trim(),
                                rcvToolIdInput: idUsersApp,
                                rcvToolDateInput: today,
                              ),
                            )
                            as RcvToolFetchResult;
                    await store.dispatch(
                      getDataRcvTool(
                        param: paramViewDataRcvTool,
                        idRcvTool: '',
                        idFormDetail: '',
                        rcvToolDate: '',
                        rcvToolIdInput: '',
                        rcvToolDateInput: '',
                      ),
                    );
                    if (editResult.statusValue == '1') {
                      final parent = _parentFormForDetailId(item.idFormDetail);
                      if (parent != null) {
                        await _updateFormMilestoneForRcvTool(parent);
                      }
                      await _refreshData();
                    }
                    if (!mounted) return;
                    if (editResult.statusValue == '1') {
                      final successText =
                          (editResult.serverMessage != null &&
                              editResult.serverMessage!.isNotEmpty)
                          ? editResult.serverMessage!
                          : 'Tool room received date updated';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            successText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final errText =
                          (editResult.serverMessage != null &&
                              editResult.serverMessage!.isNotEmpty)
                          ? editResult.serverMessage!
                          : _s.requestFailed;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    final errText = e.toString().replaceFirst(
                      RegExp(r'^Exception:\s*'),
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(_s.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> _showAddRcvToolDialog(
    PostList forms,
    String idFormDetail,
  ) async {
    if (!_canManageRcvToolDate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Menambah tanggal Tool Room received hanya untuk SUPERADMIN dan TOOL_KEEPER.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final dateCont = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_s.addDateToolRoomReceived),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form detail: $idFormDetail',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'Date (yyyy-MM-dd)',
                      textColor: clrBlack,
                      controllers: dateCont,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                      onTap: () =>
                          _pickDateIntoController(dialogContext, dateCont),
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.bodyMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  try {
                    final RcvToolFetchResult addResult =
                        await store.dispatch(
                              getDataRcvTool(
                                param: paramAddDataRcvTool,
                                idRcvTool: '',
                                idFormDetail: idFormDetail.trim(),
                                rcvToolDate: dateCont.text.trim(),
                                rcvToolIdInput: idUsersApp,
                                rcvToolDateInput: today,
                              ),
                            )
                            as RcvToolFetchResult;
                    await store.dispatch(
                      getDataRcvTool(
                        param: paramViewDataRcvTool,
                        idRcvTool: '',
                        idFormDetail: '',
                        rcvToolDate: '',
                        rcvToolIdInput: '',
                        rcvToolDateInput: '',
                      ),
                    );
                    if (addResult.statusValue == '1') {
                      await _updateFormMilestoneForRcvTool(forms);
                      await _refreshData();
                    }
                    if (!mounted) return;
                    if (addResult.statusValue == '1') {
                      final successText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : 'Tool room received date added';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            successText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final errText =
                          (addResult.serverMessage != null &&
                              addResult.serverMessage!.isNotEmpty)
                          ? addResult.serverMessage!
                          : _s.requestFailed;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    final errText = e.toString().replaceFirst(
                      RegExp(r'^Exception:\s*'),
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(_s.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> _showDeleteRcvToolConfirmDialog(PostList item) async {
    if (!_canManageRcvToolDate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akses ditolak. Menghapus tanggal Tool Room received hanya untuk SUPERADMIN dan TOOL_KEEPER.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_s.deleteDateToolRoomReceived),
          content: Text(
            'Are you sure you want to delete the tool room received date '
            '${_displayValue(item.rcvToolDate)}? This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _s.cancel,
                style: TextStyle(color: context.bodyMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      final RcvToolFetchResult deleteResult =
          await store.dispatch(
                getDataRcvTool(
                  param: paramDeleteDataRcvTool,
                  idRcvTool: item.idRcvTool.trim(),
                  idFormDetail: item.idFormDetail.trim(),
                  rcvToolDate: item.rcvToolDate.trim(),
                  rcvToolIdInput: idUsersApp,
                  rcvToolDateInput: today,
                ),
              )
              as RcvToolFetchResult;
      await store.dispatch(
        getDataRcvTool(
          param: paramViewDataRcvTool,
          idRcvTool: '',
          idFormDetail: '',
          rcvToolDate: '',
          rcvToolIdInput: '',
          rcvToolDateInput: '',
        ),
      );
      if (deleteResult.statusValue == '1') {
        final parent = _parentFormForDetailId(item.idFormDetail);
        if (parent != null) {
          await _updateFormMilestoneForRcvTool(parent);
        }
        await _refreshData();
      }
      if (!mounted) return;
      if (deleteResult.statusValue == '1') {
        final successText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : 'Tool room received date deleted';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successText,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : _s.deleteFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errText = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errText, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Edit/Delete: icon-only when width is below [mobileWidth], icon + label on desktop.
  Widget _buildEditDeleteActions({
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    String? disabledTooltip,
  }) {
    final editTooltip = onEdit != null
        ? _s.editLabel
        : (disabledTooltip ?? _s.editUnavailable);
    final deleteTooltip = onDelete != null
        ? _s.deleteLabel
        : (disabledTooltip ?? _s.deleteUnavailable);
    final compact = MediaQuery.sizeOf(context).width < mobileWidth;
    if (compact) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.end,
        children: [
          IconButton(
            tooltip: editTooltip,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: deleteTooltip,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(foregroundColor: Colors.red.shade700),
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),
        ],
      );
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(_s.editLabel),
        ),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(_s.deleteLabel),
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
        ),
      ],
    );
  }

  Widget _buildPoCard(PostList itemPO, {required bool canManageActions}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _detailSubCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: _detailSubCardIconDecoration(),
            child: const Icon(Icons.receipt_long, color: Colors.deepOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PO : ${_displayValue(itemPO.poNo)}',
                  style: _detailSubCardTitleStyle(),
                ),
              ],
            ),
          ),
          if (_canEditDeletePurchaseOrder)
            _buildEditDeleteActions(
              onEdit: canManageActions
                  ? () => _showUpdatePurchaseOrderDialog(itemPO)
                  : null,
              onDelete: canManageActions
                  ? () => _showDeletePurchaseOrderConfirmDialog(itemPO)
                  : null,
              disabledTooltip: _poActionsBlockedTooltip,
            ),
        ],
      ),
    );
  }

  Widget _buildSoCard(PostList itemSO, {required bool canManageActions}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _detailSubCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: _detailSubCardIconDecoration(),
                child: Icon(
                  Icons.local_shipping,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SO : ${_displayValue(itemSO.so)}',
                      style: _detailSubCardTitleStyle(),
                    ),
                  ],
                ),
              ),
              if (_canManageSalesOrderPr)
                _buildEditDeleteActions(
                  onEdit: canManageActions
                      ? () => _showUpdateSalesOrderDialog(itemSO)
                      : null,
                  onDelete: canManageActions
                      ? () => _showDeleteSalesOrderConfirmDialog(itemSO)
                      : null,
                  disabledTooltip: _soActionsBlockedTooltip,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLineItem('ETA', itemSO.eta, valueColor: context.textPrimary),
          _buildLineItem(
            'Note SO',
            itemSO.noteSo,
            valueColor: context.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildRcvWhCard(PostList itemRcvWh, {required bool canManageActions}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _detailSubCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: _detailSubCardIconDecoration(),
            child: const Icon(
              Icons.date_range_outlined,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayValue(itemRcvWh.rcvWhDate),
                  style: _detailSubCardTitleStyle(),
                ),
              ],
            ),
          ),
          if (_canManageRcvWhDate)
            _buildEditDeleteActions(
              onEdit: canManageActions
                  ? () => _showUpdateRcvWhDialog(itemRcvWh)
                  : null,
              onDelete: canManageActions
                  ? () => _showDeleteRcvWhConfirmDialog(itemRcvWh)
                  : null,
              disabledTooltip: _whReceivedActionsBlockedTooltip,
            ),
        ],
      ),
    );
  }

  Widget _buildRcvToolCard(PostList itemRcvTool) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _detailSubCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: _detailSubCardIconDecoration(),
            child: const Icon(
              Icons.date_range_outlined,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayValue(itemRcvTool.rcvToolDate),
                  style: _detailSubCardTitleStyle(),
                ),
              ],
            ),
          ),
          if (_canManageRcvToolDate)
            _buildEditDeleteActions(
              onEdit: () => _showUpdateRcvToolDialog(itemRcvTool),
              onDelete: () => _showDeleteRcvToolConfirmDialog(itemRcvTool),
            ),
        ],
      ),
    );
  }

  Widget _buildToolItemCard(PostList itemTool, int index, PostList forms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: clrOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: clrOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _displayValue(itemTool.pnGroup),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: _canAddToolByMilestone(forms)
                    ? 'Edit data tool'
                    : 'Edit data tool Disabled',
                onPressed: _canAddToolByMilestone(forms)
                    ? () => _openEditToolDetail(forms, itemTool, index)
                    : null,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.build_circle_outlined,
                label: 'Type ${_displayValue(itemTool.valType)}',
                color: Colors.deepOrange,
              ),
              _buildMetaChip(
                icon: Icons.inventory_2_outlined,
                label: 'Qty ${_displayValue(itemTool.qty)}',
                color: Colors.orange.shade700,
              ),
              _buildMetaChip(
                icon: Icons.payments_outlined,
                label: NumberFormat.currency(
                  locale: 'id_ID',
                  decimalDigits: 0,
                  symbol: '',
                ).format(double.parse(itemTool.partValue)),
                color: Colors.orange.shade900,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLineItem('Part Desc', itemTool.pnDesc),
          _buildLineItem('Explanation', itemTool.explan),
          _buildLineItem('Action Note', itemTool.actionNote),
          StoreConnector<AppState, DetailSectionVm>(
            converter: (store) {
              final allDataPO = store.state.posDetailState.posDetail;
              final idFormDetail = itemTool.idFormDetail.trim();
              final items = allDataPO
                  .where(
                    (itemPO) => itemPO.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
              final salesOrderExists =
                  idFormDetail.isNotEmpty &&
                  store.state.sosDetailState.sosDetail.any(
                    (itemSO) => itemSO.idFormDetail.trim() == idFormDetail,
                  );
              return DetailSectionVm(
                items: items,
                isLoading: store.state.posDetailState.isLoadingPO,
                salesOrderExists: salesOrderExists,
              );
            },
            builder: (context, vm) {
              final canManagePo =
                  _canEditDeletePurchaseOrder &&
                  _canManagePurchaseOrderWhenSalesOrderBlank(
                    vm.salesOrderExists,
                  );
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Purchase Order',
                      icon: Icons.receipt,
                      trailing: _canEditDeletePurchaseOrder
                          ? Tooltip(
                              message: canManagePo
                                  ? 'Add Purchase Order'
                                  : _poActionsBlockedTooltip,
                              child: TextButton.icon(
                                onPressed: canManagePo
                                    ? () => _showAddPurchaseOrderDialog(
                                        forms,
                                        itemTool.idFormDetail,
                                      )
                                    : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(_s.addButton),
                                style: TextButton.styleFrom(
                                  foregroundColor: clrOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (vm.isLoading && vm.items.isEmpty)
                      const AppShimmer(child: DetailLinesSkeleton())
                    else if (vm.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.textSecondary),
                        ),
                      )
                    else
                      ...vm.items.map(
                        (itemPO) =>
                            _buildPoCard(itemPO, canManageActions: canManagePo),
                      ),
                  ],
                ),
              );
            },
          ),
          StoreConnector<AppState, DetailSectionVm>(
            converter: (store) {
              final allDataSO = store.state.sosDetailState.sosDetail;
              final idFormDetail = itemTool.idFormDetail.trim();
              final items = allDataSO
                  .where(
                    (itemSO) => itemSO.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
              final whReceivedExists =
                  idFormDetail.isNotEmpty &&
                  store.state.rcvWhState.rcvWhs.any(
                    (itemRcvWh) =>
                        itemRcvWh.idFormDetail.trim() == idFormDetail,
                  );
              return DetailSectionVm(
                items: items,
                isLoading: store.state.sosDetailState.isLoadingSO,
                whReceivedExists: whReceivedExists,
              );
            },
            builder: (context, vm) {
              final canManageSo =
                  _canManageSalesOrderPr &&
                  _canManageSalesOrderWhenWhReceivedBlank(vm.whReceivedExists);
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Sales Order / Purchase Request (SO/PR)',
                      icon: Icons.route,
                      trailing: _canManageSalesOrderPr
                          ? Tooltip(
                              message: canManageSo
                                  ? 'Add Sales Order (SO) / Purchase Request (PR)'
                                  : _soActionsBlockedTooltip,
                              child: TextButton.icon(
                                onPressed: canManageSo
                                    ? () => _showAddSalesOrderDialog(
                                        forms,
                                        itemTool.idFormDetail,
                                      )
                                    : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(_s.addButton),
                                style: TextButton.styleFrom(
                                  foregroundColor: clrOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (vm.isLoading && vm.items.isEmpty)
                      const AppShimmer(child: DetailLinesSkeleton())
                    else if (vm.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.textSecondary),
                        ),
                      )
                    else
                      ...vm.items.map(
                        (itemSO) =>
                            _buildSoCard(itemSO, canManageActions: canManageSo),
                      ),
                  ],
                ),
              );
            },
          ),

          StoreConnector<AppState, DetailSectionVm>(
            converter: (store) {
              final allDataRcvWh = store.state.rcvWhState.rcvWhs;
              final idFormDetail = itemTool.idFormDetail.trim();
              final items = allDataRcvWh
                  .where(
                    (itemRcvWh) =>
                        itemRcvWh.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
              final toolRoomReceivedExists =
                  idFormDetail.isNotEmpty &&
                  store.state.rcvToolState.rcvTools.any(
                    (itemRcvTool) =>
                        itemRcvTool.idFormDetail.trim() == idFormDetail,
                  );
              return DetailSectionVm(
                items: items,
                isLoading: store.state.rcvWhState.isLoadingrcvWh,
                toolRoomReceivedExists: toolRoomReceivedExists,
              );
            },
            builder: (context, vm) {
              final canManageWh =
                  _canManageRcvWhDate &&
                  _canManageWhReceivedWhenToolRoomBlank(
                    vm.toolRoomReceivedExists,
                  );
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Date WH Received ',
                      icon: Icons.warehouse,
                      trailing: _canManageRcvWhDate
                          ? Tooltip(
                              message: canManageWh
                                  ? 'Add Date WH Received'
                                  : _whReceivedActionsBlockedTooltip,
                              child: TextButton.icon(
                                onPressed: canManageWh
                                    ? () => _showAddRcvWhDialog(
                                        forms,
                                        itemTool.idFormDetail,
                                      )
                                    : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(_s.addButton),
                                style: TextButton.styleFrom(
                                  foregroundColor: clrOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (vm.isLoading && vm.items.isEmpty)
                      const AppShimmer(child: DetailLinesSkeleton())
                    else if (vm.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.textSecondary),
                        ),
                      )
                    else
                      ...vm.items.map(
                        (itemRcvWh) => _buildRcvWhCard(
                          itemRcvWh,
                          canManageActions: canManageWh,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          StoreConnector<AppState, DetailSectionVm>(
            converter: (store) {
              final allDataRcvTool = store.state.rcvToolState.rcvTools;
              final items = allDataRcvTool
                  .where(
                    (itemRcvTool) =>
                        itemRcvTool.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
              return DetailSectionVm(
                items: items,
                isLoading: store.state.rcvToolState.isLoadingrcvTool,
              );
            },
            builder: (context, vm) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Date Tool Room Received ',
                      icon: Icons.storage,
                      trailing: _canManageRcvToolDate
                          ? TextButton.icon(
                              onPressed: () => _showAddRcvToolDialog(
                                forms,
                                itemTool.idFormDetail,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                              style: TextButton.styleFrom(
                                foregroundColor: clrOrange,
                              ),
                            )
                          : null,
                    ),
                    if (vm.isLoading && vm.items.isEmpty)
                      const AppShimmer(child: DetailLinesSkeleton())
                    else if (vm.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.textSecondary),
                        ),
                      )
                    else
                      ...vm.items.map(_buildRcvToolCard),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(PostList forms, int index) {
    final isExpandedLocal = _expandedForms.contains(forms.idForm);
    final statusColor = _statusColor(forms.formServComment);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.isDarkMode ? Colors.black : null,
        gradient: context.isDarkMode
            ? null
            : LinearGradient(
                colors: [
                  context.cardSurface,
                  statusColor.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            key: ValueKey<String>('form_${forms.idForm}_$isExpandedLocal'),
            tilePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            shape: const Border(),
            collapsedShape: const Border(),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            initiallyExpanded: isExpandedLocal,
            onExpansionChanged: (expanded) {
              setState(() {
                if (expanded) {
                  _rememberExpandedForm(forms.idForm);
                  final formNo = forms.formNo.trim();
                  if (formNo.isNotEmpty) {
                    _searchController.value = TextEditingValue(
                      text: formNo,
                      selection: TextSelection.collapsed(offset: formNo.length),
                    );
                    _searchQuery = formNo;
                    _searchField = 'formNo';
                  }
                } else {
                  _expandedForms.remove(forms.idForm);
                  _clearSearch();
                }
              });
              if (expanded) {
                final formNo = forms.formNo.trim();
                if (formNo.isNotEmpty) {
                  _refreshData();
                } else {
                  _loadToolDetailsOnly();
                }
              }
            },
            leading: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: clrOrange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: clrOrange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  _displayValue(forms.formNo),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetaChip(
                      icon: Icons.dew_point,
                      label: _displayValue(
                        forms.formMilestone != ""
                            ? forms.formMilestone
                            : "DRAFT",
                      ),
                      color: Colors.orange.shade800,
                    ),
                    _buildMetaChip(
                      icon: Icons.flag_outlined,
                      label: _displayValue(forms.formServComment),
                      color: Colors.orange.shade800,
                    ),
                    _buildMetaChip(
                      icon: Icons.person,
                      label: _displayValue(forms.formServName),
                      color: Colors.orange.shade800,
                    ),
                  ],
                ),
              ],
            ),
            subtitle: StoreConnector<AppState, _OrderTimelineViewModel>(
              converter: (store) =>
                  _computeOrderTimelineViewModel(store, forms),
              builder: (context, timelineVm) {
                final nextMilestone = _nextOrderTimelineMilestoneLabel(
                  timelineVm,
                );
                final panelBg = context.isDarkMode
                    ? Colors.black
                    : clrOrange.withValues(alpha: 0.08);
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.isDarkMode
                            ? context.cardBorder
                            : clrOrange.withValues(alpha: 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: _buildSectionHeader(
                            nextMilestone == 'COMPLETED'
                                ? 'COMPLETED'
                                : 'Next: $nextMilestone',
                            icon: Icons.timeline,
                          ),
                        ),
                        _buildOrderStatusTimeline(
                          timelineVm,
                          wrapInPanel: false,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(
                'Request Summary',
                icon: Icons.description_outlined,
                trailing: IconButton(
                  tooltip: 'Edit request',
                  icon: Icon(Icons.edit_document, color: clrOrange),
                  onPressed: () => _openEditRequestForm(forms),
                ),
              ),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width < mobileWidth
                    ? 1
                    : (MediaQuery.sizeOf(context).width >= 1500 ? 3 : 2),
                mainAxisExtent: MediaQuery.sizeOf(context).width < mobileWidth
                    ? 132
                    : (MediaQuery.sizeOf(context).width >= 1500 ? 100 : 104),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildInfoTile(
                    icon: Icons.date_range,
                    label: 'Date Create',
                    value: forms.formDateServName,
                  ),
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    label: 'Check By',
                    value: forms.formCheckBy,
                    trailing: _buildCheckByInfoTileTrailing(forms),
                  ),
                  _buildInfoTile(
                    icon: Icons.comment_bank_outlined,
                    label: 'SUPERIOR',
                    value: forms.formSuperiorComment,
                    statusText: _isApprovedValue(forms.formSuperiorAprd)
                        ? 'APPROVED'
                        : _isRejectedValue(forms.formSuperiorAprd)
                        ? 'REJECTED'
                        : 'WAITING APPROVAL',
                    statusColor: _isApprovedValue(forms.formSuperiorAprd)
                        ? clrGreen
                        : _isRejectedValue(forms.formSuperiorAprd)
                        ? Colors.red
                        : Colors.orange.shade700,
                    statusIcon: _isApprovedValue(forms.formSuperiorAprd)
                        ? Icons.check_circle
                        : _isRejectedValue(forms.formSuperiorAprd)
                        ? Icons.cancel
                        : Icons.pending,
                    trailing: _canAccessSupervisorApproval(forms)
                        ? _buildCommentCardTrailingAction(
                            icon: Icons.task_alt_outlined,
                            label: 'Superior Approval',
                            backgroundColor: clrGreen,
                            tooltip: _canSuperiorApprovalByMilestone(forms)
                                ? 'Superior Approval'
                                : 'Superior Approval Disabled',
                            onPressed: _canSuperiorApprovalByMilestone(forms)
                                ? () => _showSupervisorValidationDialog(forms)
                                : null,
                          )
                        : null,
                  ),
                  _buildServiceSupportCommentInfoTile(forms),
                  _buildInfoTile(
                    icon: Icons.comment_bank_sharp,
                    label: 'SERVICE DEPT. HEAD',
                    value: forms.formSheadComment,
                    statusText: _isApprovedValue(forms.formSheadAprd)
                        ? 'APPROVED'
                        : _isRejectedValue(forms.formSheadAprd)
                        ? 'REJECTED'
                        : 'WAITING APPROVAL',
                    statusColor: _isApprovedValue(forms.formSheadAprd)
                        ? clrGreen
                        : _isRejectedValue(forms.formSheadAprd)
                        ? Colors.red
                        : Colors.orange.shade700,
                    statusIcon: _isApprovedValue(forms.formSheadAprd)
                        ? Icons.check_circle
                        : _isRejectedValue(forms.formSheadAprd)
                        ? Icons.cancel
                        : Icons.pending,
                    trailing: _canAccessDeptHeadApproval
                        ? _buildCommentCardTrailingAction(
                            icon: Icons.verified_user_outlined,
                            label: 'Dept Head Approval',
                            backgroundColor: Colors.teal,
                            tooltip: _canDeptHeadApprovalByMilestone(forms)
                                ? 'Dept Head Approval'
                                : 'Dept Head Approval Disabled',
                            onPressed: _canDeptHeadApprovalByMilestone(forms)
                                ? () => _showDeptHeadValidationDialog(forms)
                                : null,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(
                'Tool List',
                icon: Icons.handyman_outlined,
                trailing: _buildToolListHeaderTrailing(forms),
              ),
              StoreConnector<AppState, DetailSectionVm>(
                converter: (store) {
                  final allTool = store.state.formsDetailState.formsDetail;
                  final items = allTool
                      .where((itemTool) => itemTool.idForm == forms.idForm)
                      .toList();
                  return DetailSectionVm(
                    items: items,
                    isLoading: store.state.formsDetailState.isLoadingToolDetail,
                  );
                },
                builder: (context, vm) {
                  if (vm.isLoading && vm.items.isEmpty) {
                    return const AppShimmer(
                      child: Column(
                        children: [ToolItemSkeleton(), ToolItemSkeleton()],
                      ),
                    );
                  }
                  if (vm.items.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: context.mutedSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 34,
                            color: context.iconMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No tool details for this request yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.items.length,
                    itemBuilder: (context, ii) {
                      final itemTool = vm.items[ii];
                      return _buildToolItemCard(itemTool, ii, forms);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final s = context.s;
    final fieldLabels = s.searchFieldLabels;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchTextEdited(),
              onSubmitted: _canSubmitSearch ? (_) => _submitSearch() : null,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: s.searchFormHint,
                hintStyle: TextStyle(color: context.iconMuted),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _canSubmitSearch ? clrOrange : context.iconMuted,
                  ),
                  tooltip: s.search,
                  onPressed: _canSubmitSearch ? _submitSearch : null,
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
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: context.searchAccentFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.searchAccentBorder),
            ),
            child: DropdownButton<String>(
              value: _searchField,
              underline: const SizedBox.shrink(),
              iconEnabledColor: clrOrange,
              borderRadius: BorderRadius.circular(12),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
              items: kToolFormSearchFieldKeys
                  .map(
                    (key) => DropdownMenuItem<String>(
                      value: key,
                      child: Text(fieldLabels[key] ?? key),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _searchField = value);
                _refreshData();
              },
            ),
          ),
          if (_searchController.text.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: IconButton(
                onPressed: _clearSearch,
                icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
                tooltip: _s.clearSearch,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchNotFoundContent() {
    final message = _searchQuery.isEmpty && _hasMilestoneFilters
        ? _s.noFormsMilestoneFilter
        : _searchQuery.isEmpty
        ? _s.searchNotFoundSuffix
        : _s.searchNotFound(_searchQuery);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 52,
              color: clrOrange.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.orange.shade800),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.pageBackground,
        drawer: DrawerMenu(title: name),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppbars(
                title: _pageTitle,
                onPressTailing: () {
                  postContForm(
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    context,
                  );
                },
                onPressLeading: () => _scaffoldKey.currentState?.openDrawer(),
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, FormsState>(
                converter: (store) => store.state.formsState,
                builder: (context, state) {
                  final filteredForms = state.forms
                      .where(_matchesMilestoneFilter)
                      .toList();
                  final hasMoreForms = state.hasMore;
                  // #region agent log
                  if (!state.isLoadingTool) {
                    String listBranch = 'list';
                    if (state.error != null) {
                      listBranch = 'error';
                    } else if (state.forms.isEmpty && _searchQuery.isNotEmpty) {
                      listBranch = 'searchEmpty';
                    } else if (state.forms.isEmpty) {
                      listBranch = 'apiEmpty';
                    } else if (filteredForms.isEmpty) {
                      listBranch = 'filterEmpty';
                    }
                    agentDebugLog(
                      hypothesisId: listBranch == 'filterEmpty' ? 'B' : 'A',
                      location: 'tool_data.dart:listBuilder',
                      message: 'list render branch',
                      data: {
                        'branch': listBranch,
                        'formsCount': state.forms.length,
                        'filteredCount': filteredForms.length,
                        'searchQuery': _searchQuery,
                        'hasMilestoneFilters': _hasMilestoneFilters,
                        'milestoneFiltersNorms': _milestoneFiltersNorms
                            .toList(),
                        'filterBlank': widget.filterBlankFormMilestone,
                        'excludeFilters': widget.excludeFormMilestoneFilters,
                      },
                    );
                  }
                  // #endregion
                  if (state.isLoadingTool && state.forms.isEmpty) {
                    return ShimmerListSliver(
                      itemCount: 6,
                      itemBuilder: _formCardSkeletonItem,
                    );
                  }
                  if (state.error != null) {
                    return SliverFillRemaiings(
                      errors: state.error ?? '${state.error}',
                      hasScrollBodys: false,
                    );
                  }
                  if (state.forms.isEmpty && _searchQuery.isNotEmpty) {
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedSearchHeaderDelegate(
                            backgroundColor: context.pageBackground,
                            child: _buildSearchBar(),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildSearchNotFoundContent(),
                        ),
                      ],
                    );
                  }
                  if (state.forms.isEmpty) {
                    return SliverFillRemaiings(
                      errors: state.error ?? "No Record Data Found",
                      hasScrollBodys: false,
                    );
                  }
                  if (filteredForms.isEmpty) {
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedSearchHeaderDelegate(
                            backgroundColor: context.pageBackground,
                            child: _buildSearchBar(),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildSearchNotFoundContent(),
                        ),
                      ],
                    );
                  }
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _PinnedSearchHeaderDelegate(
                          backgroundColor: context.pageBackground,
                          child: _buildSearchBar(),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final forms = filteredForms[index];
                          return _buildFormCard(forms, index);
                        }, childCount: filteredForms.length),
                      ),
                      if (state.totalForms != null &&
                          !hasMoreForms &&
                          filteredForms.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            child: Text(
                              _formLoadSummary(state, filteredForms.length),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.textSecondary),
                            ),
                          ),
                        ),
                      if (hasMoreForms)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            child: Column(
                              children: [
                                Text(
                                  _formLoadSummary(state, filteredForms.length),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: context.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: state.isLoadingMore
                                        ? null
                                        : _loadMoreForms,
                                    icon: state.isLoadingMore
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.orange.shade800,
                                            ),
                                          )
                                        : const Icon(Icons.expand_more),
                                    label: Text(
                                      state.isLoadingMore
                                          ? _s.loading
                                          : _s.loadMoreUsers(kToolFormPageSize),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
