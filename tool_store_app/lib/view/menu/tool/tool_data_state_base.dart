import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/navigation_helpers.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/debug/agent_log.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/menu/tool/tool_data_logic.dart';
import 'package:tool_store_app/view/menu/tool/tool_order_timeline.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:tool_store_app/view/custom/tool_form_search_popup.dart'
    show kToolFormSearchFieldKeys;
import 'package:intl/intl.dart';
import 'package:tool_store_app/view/menu/tool/tool_data.dart' show ToolData;
import 'tool_data_cards_helpers.dart';
import 'tool_data_date_filter_sheet.dart';
import 'tool_data_excel_filter_sheet.dart';
import 'tool_data_export.dart';

abstract class ToolDataStateBase extends State<ToolData> with MixinPref {
  /// Implemented by [ToolDataDialogsMixin] on [ToolDataState].
  Future<void> showRequestOrderToolDialog(PostList forms);
  Future<void> showSupervisorValidationDialog(PostList forms);
  Future<void> showDeptHeadValidationDialog(PostList forms);
  Future<void> showServiceAdminReviewDialog(PostList forms);
  Future<void> showAddPurchaseOrderDialog(PostList forms, String idFormDetail);
  Future<void> showAddSalesOrderDialog(PostList forms, String idFormDetail);
  Future<void> showAddRcvWhDialog(PostList forms, String idFormDetail);
  Future<void> showAddRcvToolDialog(PostList forms, String idFormDetail);

  Widget buildServiceSupportCommentInfoTile(PostList forms);
  Widget buildPoCard(PostList itemPO, {required bool canManageActions});
  Widget buildSoCard(PostList itemSO, {required bool canManageActions});
  Widget buildRcvWhCard(PostList itemRcvWh, {required bool canManageActions});
  Widget buildRcvToolCard(PostList itemRcvTool);
  Widget buildToolItemCard(PostList itemTool, int index, PostList forms);
  Widget buildFormCard(PostList forms, int index);

  Widget buildSearchBar();
  Widget buildSearchNotFoundContent();

  AppStrings get strings => AppStrings.current;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> expandedForms = <String>{};
  final Set<String> loadingDetailFormIds = <String>{};
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String searchField = 'all';
  DateTime? dateFilterFrom;
  DateTime? dateFilterTo;
  DateTime? excelFilterDateFrom;
  DateTime? excelFilterDateTo;
  String? excelFilterFormNo;
  int currentPage = 1;

  bool get hasDateFilter => dateFilterFrom != null && dateFilterTo != null;

  bool get hasExcelDateFilter =>
      excelFilterDateFrom != null && excelFilterDateTo != null;

  bool get hasExcelFilter =>
      hasExcelDateFilter || (excelFilterFormNo?.trim().isNotEmpty ?? false);

  String get dateFilterFromApi => dateFilterFrom != null
      ? DateFormat('yyyy-MM-dd').format(dateFilterFrom!)
      : '';

  String get dateFilterToApi =>
      dateFilterTo != null ? DateFormat('yyyy-MM-dd').format(dateFilterTo!) : '';

  (String from, String to) get effectiveDateFilterApi {
    DateTime? from;
    DateTime? to;

    if (hasDateFilter) {
      from = dateFilterFrom;
      to = dateFilterTo;
    }

    if (hasExcelDateFilter) {
      final excelFrom = excelFilterDateFrom!;
      final excelTo = excelFilterDateTo!;
      if (from != null && to != null) {
        final intersectFrom = excelFrom.isAfter(from) ? excelFrom : from;
        final intersectTo = excelTo.isBefore(to) ? excelTo : to;
        if (intersectFrom.isAfter(intersectTo)) {
          return ('2099-12-31', '2099-12-30');
        }
        from = intersectFrom;
        to = intersectTo;
      } else {
        from = excelFrom;
        to = excelTo;
      }
    }

    if (from == null || to == null) return ('', '');
    return (
      DateFormat('yyyy-MM-dd').format(from),
      DateFormat('yyyy-MM-dd').format(to),
    );
  }

  String get effectiveSearchKeyword {
    final formNo = excelFilterFormNo?.trim() ?? '';
    if (formNo.isNotEmpty) return formNo;
    return searchQuery;
  }

  String get effectiveSearchField {
    final formNo = excelFilterFormNo?.trim() ?? '';
    if (formNo.isNotEmpty) return 'formNo';
    return searchField;
  }

  String get pageTitle {
    final customTitle = widget.title?.trim();
    return customTitle != null && customTitle.isNotEmpty
        ? customTitle
        : titleDataTool;
  }

  String get milestoneFilterNorm =>
      OrderTimelineLogic.normFormMilestone(widget.formMilestoneFilter ?? '');

  bool get hasMilestoneFilter => milestoneFilterNorm.isNotEmpty;

  Set<String> get milestoneFiltersNorms => ToolDataLogic.milestoneFiltersNorms(
    formMilestoneFilter: widget.formMilestoneFilter,
    formMilestoneFilters: widget.formMilestoneFilters,
  );

  bool get hasMilestoneFilters =>
      ToolDataLogic.hasMilestoneFilters(milestoneFiltersNorms);

  /// Dashboard counts use [kToolFormDashboardFetchLimit]; list must load enough rows
  /// before client-side milestone filter or matches show "Not Found" incorrectly.
  int get formsFetchLimit =>
      ToolDataLogic.formsFetchLimit(hasMilestoneFilters: hasMilestoneFilters);

  Set<String> get excludeMilestoneFilterNorms =>
      ToolDataLogic.excludeMilestoneFilterNorms(
        excludeFormMilestoneFilters: widget.excludeFormMilestoneFilters,
      );

  @override
  void initState() {
    super.initState();
    refreshPref();
    final initialQuery = widget.initialSearchQuery?.trim() ?? '';
    if (initialQuery.isNotEmpty) {
      searchController.text = initialQuery;
      searchQuery = initialQuery;
      searchField = kToolFormSearchFieldKeys.contains(widget.initialSearchField)
          ? widget.initialSearchField
          : 'all';
    }
    final expandedId = widget.initialExpandedFormId?.trim() ?? '';
    if (expandedId.isNotEmpty) {
      expandedForms.add(expandedId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) refreshData();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Dialog routes may still detach [TextFormField]s one frame after [showDialog]
  /// completes; disposing controllers immediately causes "used after disposed".
  void disposeTextControllersAfterFrame(
    List<TextEditingController> controllers,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  Future<void> fetchFormsPage({required int page, required bool append}) async {
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
        fromDateUpdate: effectiveDateFilterApi.$1,
        toDateUpdate: effectiveDateFilterApi.$2,
        formUserUpdate: '',
        page: page,
        limit: formsFetchLimit,
        append: append,
        viewKeyword: effectiveSearchKeyword,
        viewSearchField: effectiveSearchField,
      ),
    );
  }

  bool get canSubmitSearch => searchController.text.trim().isNotEmpty;

  /// Memanggil API dengan keyword dari field (saat ikon search diklik).
  void submitSearch() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      searchQuery = query;
    });
    refreshData();
  }

  void onSearchTextEdited() => setState(() {});

  Future<void> refreshData() async {
    if (!mounted) return;
    setState(() => currentPage = 1);
    await fetchFormsPage(page: 1, append: false);
    // #region agent log
    final fs = store.state.formsState;
    agentDebugLog(
      hypothesisId: 'A',
      location: 'tool_data.dart:refreshData',
      message: 'after fetch page 1',
      data: {
        'formsLoaded': fs.forms.length,
        'totalForms': fs.totalForms,
        'hasMore': fs.hasMore,
        'error': fs.error,
        'fetchLimit': formsFetchLimit,
        'searchQuery': searchQuery,
        'searchField': searchField,
        'pageTitle': pageTitle,
        'milestoneFilters': widget.formMilestoneFilters,
        'milestoneFilter': widget.formMilestoneFilter,
        'milestoneFiltersNorms': milestoneFiltersNorms.toList(),
        'sampleMilestones': fs.forms
            .take(5)
            .map((f) => f.formMilestone.trim())
            .toList(),
      },
    );
    // #endregion
    await _reloadExpandedFormsDetails();
  }

  bool isLoadingFormDetails(String idForm) =>
      loadingDetailFormIds.contains(idForm.trim());

  bool hasLoadedFormDetails(String idForm) {
    final id = idForm.trim();
    if (id.isEmpty) return false;
    return store.state.formsDetailState.formsDetail.any(
      (item) => item.idForm.trim() == id,
    );
  }

  Future<void> _loadFormRelatedDetails(String idForm) async {
    final id = idForm.trim();
    if (id.isEmpty || loadingDetailFormIds.contains(id)) return;
    setState(() => loadingDetailFormIds.add(id));
    try {
      await store.dispatch(loadFormRelatedDetails(idForm: id));
    } finally {
      if (mounted) {
        setState(() => loadingDetailFormIds.remove(id));
      } else {
        loadingDetailFormIds.remove(id);
      }
    }
  }

  Future<void> _reloadExpandedFormsDetails() async {
    if (expandedForms.isEmpty) return;
    for (final id in expandedForms) {
      await _loadFormRelatedDetails(id);
    }
  }

  void rememberExpandedForm(String idForm) {
    final id = idForm.trim();
    if (id.isEmpty) return;
    expandedForms.add(id);
  }

  void onFormCardExpansionChanged(PostList forms, bool expanded) {
    setState(() {
      if (expanded) {
        rememberExpandedForm(forms.idForm);
        final formNo = forms.formNo.trim();
        if (formNo.isNotEmpty) {
          searchController.value = TextEditingValue(
            text: formNo,
            selection: TextSelection.collapsed(offset: formNo.length),
          );
          searchQuery = formNo;
          searchField = 'formNo';
        }
      } else {
        expandedForms.remove(forms.idForm);
        clearSearch();
      }
    });
    if (expanded) {
      // Load tool lines immediately; do not wait for form list refresh.
      unawaited(_loadFormRelatedDetails(forms.idForm));
      final formNo = forms.formNo.trim();
      if (formNo.isNotEmpty) {
        unawaited(refreshData());
      }
    }
  }

  Future<void> pickDateIntoController(
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

  void clearSearch() {
    searchController.clear();
    setState(() {
      searchQuery = '';
      searchField = 'all';
    });
    refreshData();
  }

  Future<void> showDateRangeFilter() async {
    final result = await showToolDataDateFilterSheet(
      context: context,
      initialFrom: dateFilterFrom,
      initialTo: dateFilterTo,
      showClearAction: hasDateFilter,
    );
    if (!mounted || result == null) return;

    switch (result) {
      case ToolDataDateFilterCleared():
        await clearDateFilter();
      case ToolDataDateFilterApplied(:final from, :final to):
        setState(() {
          dateFilterFrom = from;
          dateFilterTo = to;
        });
        await refreshData();
    }
  }

  Future<void> clearDateFilter() async {
    if (!hasDateFilter) return;
    setState(() {
      dateFilterFrom = null;
      dateFilterTo = null;
    });
    await refreshData();
  }

  ToolDataExcelFilterMode get excelFilterInitialMode =>
      excelFilterFormNo?.trim().isNotEmpty == true
      ? ToolDataExcelFilterMode.formNo
      : ToolDataExcelFilterMode.dateUpdate;

  Future<void> showExcelFilter() async {
    final result = await showToolDataExcelFilterSheet(
      context: context,
      initialMode: excelFilterInitialMode,
      initialFrom: excelFilterDateFrom,
      initialTo: excelFilterDateTo,
      initialFormNo: excelFilterFormNo ?? '',
      showClearAction: hasExcelFilter,
    );
    if (!mounted || result == null) return;

    switch (result) {
      case ToolDataExcelFilterCleared():
        await clearExcelFilter();
      case ToolDataExcelFilterDateApplied():
      case ToolDataExcelFilterFormNoApplied():
        await _exportAndApplyExcelFilter(result);
    }
  }

  Future<void> _exportAndApplyExcelFilter(
    ToolDataExcelFilterSheetResult filter,
  ) async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final outcome = await exportFormDetailWithFilter(
        filter: filter,
        headerDateFrom: dateFilterFrom,
        headerDateTo: dateFilterTo,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (!outcome.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(outcome.message),
            backgroundColor: outcome.success ? clrGreen : Colors.red.shade700,
          ),
        );
      }

      if (!outcome.success) return;

      switch (filter) {
        case ToolDataExcelFilterDateApplied(:final from, :final to):
          setState(() {
            excelFilterDateFrom = from;
            excelFilterDateTo = to;
            excelFilterFormNo = null;
          });
        case ToolDataExcelFilterFormNoApplied(:final formNo):
          setState(() {
            excelFilterFormNo = formNo;
            excelFilterDateFrom = null;
            excelFilterDateTo = null;
            searchController.text = formNo;
            searchQuery = formNo;
            searchField = 'formNo';
          });
        case ToolDataExcelFilterCleared():
          break;
      }
      await refreshData();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.exportFailed(e.toString())),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> clearExcelFilter() async {
    if (!hasExcelFilter) return;
    final hadFormNo = excelFilterFormNo?.trim().isNotEmpty ?? false;
    setState(() {
      excelFilterDateFrom = null;
      excelFilterDateTo = null;
      excelFilterFormNo = null;
      if (hadFormNo) {
        searchController.clear();
        searchQuery = '';
        searchField = 'all';
      }
    });
    await refreshData();
  }

  /// After a successful save on a form, focus the list search on that form's number.
  Future<void> setSearchToFormNumber(PostList formHeader) async {
    if (!mounted) return;
    final no = formHeader.formNo.trim();
    if (no.isEmpty) return;
    rememberExpandedForm(formHeader.idForm);
    searchController.text = no;
    setState(() {
      searchQuery = no;
      searchField = 'formNo';
    });
    await refreshData();
  }

  String formLoadSummary(FormsState state, int visibleCount) {
    final n = visibleCount;
    final loaded = state.forms.length;
    final t = state.totalForms;
    if (t != null) {
      return strings.formsShownSummary(n, loaded, t);
    }
    return strings.formsShownCount(n, loaded);
  }

  Future<void> loadMoreForms() async {
    if (store.state.formsState.isLoadingMore ||
        !store.state.formsState.hasMore) {
      return;
    }
    final nextPage = currentPage + 1;
    try {
      await fetchFormsPage(page: nextPage, append: true);
      if (mounted) setState(() => currentPage = nextPage);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
  }

  bool matchesMilestoneFilter(PostList form) =>
      ToolDataLogic.matchesFormMilestoneFilter(
        formMilestone: form.formMilestone,
        filterBlankFormMilestone: widget.filterBlankFormMilestone,
        excludeFormMilestoneFilter: widget.excludeFormMilestoneFilter,
        milestoneFiltersNorms: milestoneFiltersNorms,
        excludeMilestoneFilterNorms: excludeMilestoneFilterNorms,
      );

  Color statusColor(String value) {
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

  String displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  bool isApprovedValue(String value) =>
      OrderTimelineLogic.isApprovedValue(value);

  bool isRejectedValue(String value) =>
      ToolDataLogic.isRejectedApprovalValue(value);

  /// Service admin milestone → CONTINUE / HOLD for the Service Support tile.
  ({String? text, Color? color, IconData? icon})
  serviceSupportMilestoneStatusVisual(String formMilestone) {
    switch (ToolDataLogic.serviceSupportMilestoneKind(formMilestone)) {
      case ToolDataServiceSupportMilestoneKind.continueFlow:
        return (
          text: strings.continueLabel,
          color: clrGreen,
          icon: Icons.play_circle_outline,
        );
      case ToolDataServiceSupportMilestoneKind.hold:
        return (
          text: strings.holdLabel,
          color: Colors.orange.shade800,
          icon: Icons.pause_circle_outline,
        );
      case ToolDataServiceSupportMilestoneKind.none:
        return (text: null, color: null, icon: null);
    }
  }

  bool get canAccessRequestOrderTool {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SERVICE_ADMIN' || currentLevel == 'SUPERADMIN';
  }

  bool get canAccessDeptHeadApproval {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'HEAD_SERVICE' || currentLevel == 'SUPERADMIN';
  }

  bool canAccessSupervisorApproval(PostList forms) {
    final currentLevel = level.trim().toUpperCase();
    if (currentLevel == 'SUPERADMIN') return true;
    final currentUserId = superiorId.trim();
    final formSuperiorId = forms.superiorId.trim();
    if (currentUserId.isEmpty || formSuperiorId.isEmpty) return false;
    return currentUserId == formSuperiorId;
  }

  /// Superior Approval hanya saat milestone CHECK BY TOOL STORE.
  bool canSuperiorApprovalByMilestone(PostList forms) =>
      ToolDataLogic.canSuperiorApprovalByMilestone(forms.formMilestone);

  /// Service Support Review hanya saat milestone SUPERIOR APPROVED atau HOLD BY SERVICE ADMIN.
  bool canServiceSupportReviewByMilestone(PostList forms) =>
      ToolDataLogic.canServiceSupportReviewByMilestone(forms.formMilestone);

  /// Dept Head Approval hanya saat milestone REVIEWED BY SERVICE ADMIN atau REJECTED BY SERVICE DEPT. HEAD.
  bool canDeptHeadApprovalByMilestone(PostList forms) =>
      ToolDataLogic.canDeptHeadApprovalByMilestone(forms.formMilestone);

  bool get canEditDeletePurchaseOrder {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'TOOL_KEEPER';
  }

  /// PO Add/Edit/Delete hanya saat belum ada data Sales Order untuk baris tool ini.
  bool canManagePurchaseOrderWhenSalesOrderBlank(bool salesOrderExists) {
    return !salesOrderExists;
  }

  String get poActionsBlockedTooltip => AppStrings.current.poLockedBeforeSo;

  /// SO Add/Edit/Delete hanya saat belum ada Date WH Received untuk baris tool ini.
  bool canManageSalesOrderWhenWhReceivedBlank(bool whReceivedExists) {
    return !whReceivedExists;
  }

  String get soActionsBlockedTooltip => AppStrings.current.soLockedBeforeWh;

  /// Date WH Received Add/Edit/Delete hanya saat belum ada Date Tool Room Received.
  bool canManageWhReceivedWhenToolRoomBlank(bool toolRoomReceivedExists) {
    return !toolRoomReceivedExists;
  }

  String get whReceivedActionsBlockedTooltip =>
      AppStrings.current.whLockedBeforeToolRoom;

  bool get canManageSalesOrderPr {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' ||
        currentLevel == 'COUNTER' ||
        currentLevel == 'GA';
  }

  bool get canManageRcvWhDate {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'WH';
  }

  bool get canManageRcvToolDate {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'TOOL_KEEPER';
  }

  bool get canAddToolToForm {
    final currentLevel = level.trim().toUpperCase();
    return currentLevel == 'SUPERADMIN' || currentLevel == 'TOOL_KEEPER';
  }

  bool formHasTools(AppState state, PostList forms) {
    final formId = forms.idForm.trim();
    return state.formsDetailState.formsDetail.any(
      (itemTool) => itemTool.idForm.trim() == formId,
    );
  }

  /// Request Order hanya saat milestone kosong, DRAFT, atau CHECK BY TOOL STORE.
  bool canRequestOrderByMilestone(PostList forms) =>
      ToolDataLogic.canRequestOrderByMilestone(forms.formMilestone);

  bool get isSuperAdmin => isSuperAdminLevel(level);

  /// Add / edit tool item: SUPERADMIN atau TOOL_KEEPER; milestone kosong/DRAFT
  /// (SUPERADMIN boleh di milestone mana pun).
  bool canAddToolByMilestone(PostList forms) {
    if (!canAddToolToForm) return false;
    return ToolDataLogic.canAddToolByMilestone(
      formMilestone: forms.formMilestone,
      allowAnyMilestone: isSuperAdmin,
    );
  }

  bool canEditToolDetail(PostList forms) => canAddToolByMilestone(forms);

  /// Tambah form request (+) dan edit Request Summary.
  bool get canAddOrEditDataToolForm => canAddToolToForm;

  Future<void> openAddToolForm(PostList forms) async {
    rememberExpandedForm(forms.idForm);
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
    await _loadFormRelatedDetails(forms.idForm);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> openEditRequestForm(PostList forms) async {
    rememberExpandedForm(forms.idForm);
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
    rememberExpandedForm(returnedId);
    await refreshData();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> openEditToolDetail(
    PostList forms,
    PostList itemTool,
    int index,
  ) async {
    rememberExpandedForm(forms.idForm);
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
    await _loadFormRelatedDetails(forms.idForm);
    if (!mounted) return;
    setState(() {});
  }

  Widget buildCheckByInfoTileTrailing(PostList forms) {
    return StoreConnector<AppState, bool>(
      converter: (store) => formHasTools(store.state, forms),
      builder: (context, hasTools) {
        final s = context.s;
        if (!hasTools && canAddToolToForm) {
          final canAdd = canAddToolByMilestone(forms);
          return buildCommentCardTrailingAction(
            icon: Icons.add_circle_outline,
            label: s.addTool,
            backgroundColor: Colors.orange.shade700,
            tooltip: canAdd ? s.addTool : s.addToolDisabled,
            onPressed: canAdd ? () => openAddToolForm(forms) : null,
          );
        }
        if (hasTools && canAccessRequestOrderTool) {
          final canRequest = canRequestOrderByMilestone(forms);
          return buildCommentCardTrailingAction(
            icon: Icons.local_mall_outlined,
            label: s.requestOrder,
            backgroundColor: Colors.deepOrange.shade600,
            tooltip: canRequest ? s.requestOrderTool : s.requestOrderDisabled,
            onPressed: canRequest
                ? () => showRequestOrderToolDialog(forms)
                : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildToolListHeaderTrailing(PostList forms) {
    return StoreConnector<AppState, bool>(
      converter: (store) => formHasTools(store.state, forms),
      builder: (context, hasTools) {
        if (hasTools && canAddToolToForm) {
          return buildAddToolHeaderAction(forms);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
    String? statusText,
    Color? statusColor,
    IconData? statusIcon,
  }) {
    return buildToolDataInfoTile(
      context: context,
      icon: icon,
      label: label,
      displayValue: displayValue(value),
      trailing: trailing,
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
    );
  }

  Widget buildSectionHeader(
    String title, {
    IconData icon = Icons.label_outline,
    Widget? trailing,
  }) {
    return buildToolDataSectionHeader(
      context,
      title,
      icon: icon,
      trailing: trailing,
    );
  }

  Future<bool> showSubmitConfirmationDialog({
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
                strings.cancel,
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
              child: Text(strings.yes),
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

  Widget buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return buildToolDataMetaChip(
      context: context,
      icon: icon,
      label: label,
      color: color,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return buildToolDataActionButton(
      context: context,
      icon: icon,
      label: label,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
    );
  }

  Widget buildAddToolHeaderAction(PostList forms) {
    final canAdd = canAddToolByMilestone(forms);
    final tooltip = canAdd ? strings.addTool : strings.addToolDisabled;
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
        onPressed: canAdd ? () => openAddToolForm(forms) : null,
      );
    }
    return _buildActionButton(
      icon: Icons.add_circle_outline,
      label: strings.addTool,
      backgroundColor: Colors.orange.shade700,
      onPressed: canAdd ? () => openAddToolForm(forms) : null,
    );
  }

  /// Tombol aksi di card komentar: teks + ikon di layar lebar (desktop), ikon saja di mobile.
  Widget buildCommentCardTrailingAction({
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

  Widget buildLineItem(String label, String value, {Color? valueColor}) {
    return buildToolDataLineItem(
      context,
      label,
      displayValue(value),
      valueColor: valueColor,
    );
  }

  BoxDecoration detailSubCardDecoration() {
    return buildToolDataDetailSubCardDecoration(context);
  }

  BoxDecoration detailSubCardIconDecoration() {
    return buildToolDataDetailSubCardIconDecoration(context);
  }

  TextStyle? detailSubCardTitleStyle() {
    return buildToolDataDetailSubCardTitleStyle(context);
  }

  /// Edit/Delete: icon-only when width is below [mobileWidth], icon + label on desktop.
  Widget buildEditDeleteActions({
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    String? disabledTooltip,
  }) {
    final editTooltip = onEdit != null
        ? strings.editLabel
        : (disabledTooltip ?? strings.editUnavailable);
    final deleteTooltip = onDelete != null
        ? strings.deleteLabel
        : (disabledTooltip ?? strings.deleteUnavailable);
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
          label: Text(strings.editLabel),
        ),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(strings.deleteLabel),
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
        ),
      ],
    );
  }
}
