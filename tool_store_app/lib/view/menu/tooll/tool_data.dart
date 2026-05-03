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
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:intl/intl.dart';

class ToolData extends StatefulWidget {
  const ToolData({super.key});
  @override
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> with MixinPref {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _expandedForms = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchField = 'all';

  static const Map<String, String> _searchFieldLabels = {
    'all': 'All',
    'formNo': 'Form No',
    'serviceman': 'Serviceman',
    'status': 'Status',
    'idForm': 'Category',
  };

  @override
  void initState() {
    super.initState();
    refreshPref();
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

  Future<void> _refreshData() async {
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
      ),
    );
  }

  Future<void> _pickDateIntoController(
    BuildContext dialogContext,
    TextEditingController controller,
  ) async {
    final parsed = DateTime.tryParse(controller.text.trim());
    final initialDate = parsed ?? DateTime.now();
    final picked = await showDatePicker(
      context: dialogContext,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchField = 'all';
    });
  }

  bool _matchesSearch(PostList form) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();

    String normalize(String value) => value.toLowerCase();

    switch (_searchField) {
      case 'formNo':
        return normalize(form.formNo).contains(query);
      case 'serviceman':
        return normalize(form.formServName).contains(query);
      case 'status':
        return normalize(form.formServComment).contains(query);
      case 'idForm':
        return normalize(form.idForm).contains(query);
      case 'all':
      default:
        final candidates = <String>[
          form.formNo,
          form.formServName,
          form.formServComment,
          form.idForm,
        ];
        return candidates.any((value) => normalize(value).contains(query));
    }
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: label,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (isDesktop &&
                                  statusText != null &&
                                  statusText.isNotEmpty) ...[
                                TextSpan(
                                  text: ' - ',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
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
                                        color:
                                            statusColor ?? Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                TextSpan(
                                  text: statusText,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color:
                                            statusColor ?? Colors.grey.shade700,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                              if (!isDesktop &&
                                  statusText != null &&
                                  statusText.isNotEmpty) ...[
                                TextSpan(
                                  text: ' - ',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
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
                                        color:
                                            statusColor ?? Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                TextSpan(
                                  text: statusText,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color:
                                            statusColor ?? Colors.grey.shade700,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Expanded(
                  child: SelectableText(
                    _displayValue(value),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing],
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
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
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
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
              child: const Text('Yes'),
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
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToolHeaderAction() {
    final isMobile = MediaQuery.sizeOf(context).width < mobileWidth;
    if (isMobile) {
      return IconButton(
        tooltip: 'Add Tool',
        style: IconButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 20),
        onPressed: () {
          PageRoutes.routeUserFormDetail(context, 'ADD DATA');
        },
      );
    }
    return _buildActionButton(
      icon: Icons.add_circle_outline,
      label: 'Add Tool',
      backgroundColor: Colors.orange.shade700,
      onPressed: () {
        PageRoutes.routeUserFormDetail(context, 'ADD DATA');
      },
    );
  }

  /// Tombol aksi di card komentar: teks + ikon di layar lebar (desktop), ikon saja di mobile.
  Widget _buildCommentCardTrailingAction({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required String tooltip,
    required VoidCallback onPressed,
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
              foregroundColor: Colors.white,
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
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
    );
  }

  Widget _buildLineItem(String label, String value) {
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
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
                  const Expanded(child: Text('Superior Validation')),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedApproval,
                      decoration: const InputDecoration(
                        labelText: 'Supervisor / Foreman Approval',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'APPROVED',
                          child: Text('APPROVED'),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text('REJECTED'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedApproval = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Approval is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Supervisor / Foreman Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Comment is required';
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: 'Confirm Supervisor Validation',
                            message:
                                'This will submit supervisor/foreman approval for this request.',
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
                                formMilestone: forms.formMilestone.trim(),
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

                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                content: Text(
                                  responseMessage.isNotEmpty
                                      ? responseMessage
                                      : (isSuccess
                                            ? "Supervisor validation saved"
                                            : "Failed saving validation"),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await _refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Failed saving validation'),
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
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
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
                  const Expanded(child: Text('Dept Head Approval')),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedApproval,
                      decoration: const InputDecoration(
                        labelText: 'Service Dept. Head Approval',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'APPROVED',
                          child: Text('APPROVED'),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text('REJECTED'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedApproval = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Approval is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Service Dept. Head Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Comment is required';
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: 'Confirm Dept Head Approval',
                            message:
                                'This will submit dept head approval for this request.',
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
                                formMilestone: forms.formMilestone.trim(),
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

                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                content: Text(
                                  responseMessage.isNotEmpty
                                      ? responseMessage
                                      : (isSuccess
                                            ? "Dept head approval saved"
                                            : "Failed saving dept head approval"),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await _refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Failed saving dept head approval',
                                ),
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
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
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
                  const Expanded(child: Text('Service Admin / Support Review')),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Service Admin / Support Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Comment is required';
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await _showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: 'Confirm Service Admin Review',
                            message:
                                'This will submit service admin/support review for this request.',
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
                                formMilestone: forms.formMilestone.trim(),
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

                            if (!mounted) return;
                            Navigator.pop(dialogContext);
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
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Failed saving service admin review',
                                ),
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
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdatePurchaseOrderDialog(PostList itemPO) async {
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
          title: const Text('Update Purchase Order'),
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
                        ?.copyWith(color: Colors.grey.shade700),
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
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
                        : 'Request failed';
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
              child: Text('Save', style: TextStyle(color: clrOrange)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddPurchaseOrderDialog(String idFormDetail) async {
    final addPoNoCont = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add Purchase Order'),
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
                          ?.copyWith(color: Colors.grey.shade700),
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
                  style: TextStyle(color: Colors.grey.shade800),
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
                          : 'Request failed';
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
                child: Text('Save', style: TextStyle(color: clrOrange)),
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
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Purchase Order'),
          content: Text(
            'Are you sure you want to delete PO ${_displayValue(itemPO.poNo)}? '
            'This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
            : 'Delete failed';
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
          title: const Text('Update Sales Order'),
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
                        ?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  TextFormFields(
                    labelTexts: 'SO number',
                    textColor: clrBlack,
                    controllers: soCont,
                    validators: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'SO number is required';
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
                    validators: (_) => null,
                  ),
                  TextFormFields(
                    labelTexts: 'Note SO',
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
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
                        : 'Request failed';
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
              child: Text('Save', style: TextStyle(color: clrOrange)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddSalesOrderDialog(String idFormDetail) async {
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
            title: const Text('Add Sales Order'),
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
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    TextFormFields(
                      labelTexts: 'SO number',
                      textColor: clrBlack,
                      controllers: addSoCont,
                      validators: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'SO number is required';
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
                      validators: (_) => null,
                    ),
                    TextFormFields(
                      labelTexts: 'Note SO',
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
                  style: TextStyle(color: Colors.grey.shade800),
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
                          : 'Request failed';
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
                child: Text('Save', style: TextStyle(color: clrOrange)),
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
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Sales Order'),
          content: Text(
            'Are you sure you want to delete SO ${_displayValue(itemSO.so)}? '
            'This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
      }
      if (!mounted) return;
      if (deleteResult.statusValue == '1') {
        final successText =
            (deleteResult.serverMessage != null &&
                deleteResult.serverMessage!.isNotEmpty)
            ? deleteResult.serverMessage!
            : 'Sales order deleted';
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
            : 'Delete failed';
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
    final dateCont = TextEditingController(text: item.rcvWhDate.trim());
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Update Date WH Received'),
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
                          ?.copyWith(color: Colors.grey.shade700),
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
                  style: TextStyle(color: Colors.grey.shade800),
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
                          : 'Request failed';
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
                child: Text('Save', style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> _showAddRcvWhDialog(String idFormDetail) async {
    final dateCont = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add Date WH Received'),
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
                          ?.copyWith(color: Colors.grey.shade700),
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
                  style: TextStyle(color: Colors.grey.shade800),
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
                          : 'Request failed';
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
                child: Text('Save', style: TextStyle(color: clrOrange)),
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
    if (!mounted) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Date WH Received'),
          content: Text(
            'Are you sure you want to delete the WH received date '
            '${_displayValue(item.rcvWhDate)}? This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
            : 'Delete failed';
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
    final dateCont = TextEditingController(text: item.rcvToolDate.trim());
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Update Date Tool Room Received'),
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
                          ?.copyWith(color: Colors.grey.shade700),
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
                  style: TextStyle(color: Colors.grey.shade800),
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
                          : 'Request failed';
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
                child: Text('Save', style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      _disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> _showAddRcvToolDialog(String idFormDetail) async {
    final dateCont = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add Date Tool Room Received'),
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
                          ?.copyWith(color: Colors.grey.shade700),
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
                  style: TextStyle(color: Colors.grey.shade800),
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
                          : 'Request failed';
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
                child: Text('Save', style: TextStyle(color: clrOrange)),
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
    if (!mounted) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Date Tool Room Received'),
          content: Text(
            'Are you sure you want to delete the tool room received date '
            '${_displayValue(item.rcvToolDate)}? This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade800),
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
            : 'Delete failed';
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
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final compact = MediaQuery.sizeOf(context).width < mobileWidth;
    if (compact) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.end,
        children: [
          IconButton(
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Delete',
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
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
        ),
      ],
    );
  }

  Widget _buildPoCard(PostList itemPO) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.deepOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PO : ${_displayValue(itemPO.poNo)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _buildEditDeleteActions(
            onEdit: () => _showUpdatePurchaseOrderDialog(itemPO),
            onDelete: () => _showDeletePurchaseOrderConfirmDialog(itemPO),
          ),
        ],
      ),
    );
  }

  Widget _buildSoCard(PostList itemSO) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildEditDeleteActions(
                onEdit: () => _showUpdateSalesOrderDialog(itemSO),
                onDelete: () => _showDeleteSalesOrderConfirmDialog(itemSO),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLineItem('ETA', itemSO.eta),
          _buildLineItem('Note SO', itemSO.noteSo),
        ],
      ),
    );
  }

  Widget _buildRcvWhCard(PostList itemRcvWh) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _buildEditDeleteActions(
            onEdit: () => _showUpdateRcvWhDialog(itemRcvWh),
            onDelete: () => _showDeleteRcvWhConfirmDialog(itemRcvWh),
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
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _buildEditDeleteActions(
            onEdit: () => _showUpdateRcvToolDialog(itemRcvTool),
            onDelete: () => _showDeleteRcvToolConfirmDialog(itemRcvTool),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItemCard(PostList itemTool, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                tooltip: 'Edit data tool',
                onPressed: () {
                  postMultipleToolCont(
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
                },
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
          StoreConnector<AppState, List<PostList>>(
            converter: (store) {
              final allDataPO = store.state.posDetailState.posDetail;
              return allDataPO
                  .where(
                    (itemPO) => itemPO.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
            },
            builder: (context, filteredListPO) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Purchase Order',
                      icon: Icons.receipt,
                      trailing: TextButton.icon(
                        onPressed: () =>
                            _showAddPurchaseOrderDialog(itemTool.idFormDetail),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(foregroundColor: clrOrange),
                      ),
                    ),
                    if (filteredListPO.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      )
                    else
                      ...filteredListPO.map(_buildPoCard),
                  ],
                ),
              );
            },
          ),
          StoreConnector<AppState, List<PostList>>(
            converter: (store) {
              final allDataSO = store.state.sosDetailState.sosDetail;
              return allDataSO
                  .where(
                    (itemSO) => itemSO.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
            },
            builder: (context, filteredListSO) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Sales Order',
                      icon: Icons.route,
                      trailing: TextButton.icon(
                        onPressed: () =>
                            _showAddSalesOrderDialog(itemTool.idFormDetail),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(foregroundColor: clrOrange),
                      ),
                    ),
                    if (filteredListSO.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      )
                    else
                      ...filteredListSO.map(_buildSoCard),
                  ],
                ),
              );
            },
          ),

          StoreConnector<AppState, List<PostList>>(
            converter: (store) {
              final allDataRcvWh = store.state.rcvWhState.rcvWhs;
              return allDataRcvWh
                  .where(
                    (itemRcvWh) =>
                        itemRcvWh.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
            },
            builder: (context, filteredListRcvWh) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Date WH Received ',
                      icon: Icons.warehouse,
                      trailing: TextButton.icon(
                        onPressed: () =>
                            _showAddRcvWhDialog(itemTool.idFormDetail),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(foregroundColor: clrOrange),
                      ),
                    ),
                    if (filteredListRcvWh.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      )
                    else
                      ...filteredListRcvWh.map(_buildRcvWhCard),
                  ],
                ),
              );
            },
          ),
          StoreConnector<AppState, List<PostList>>(
            converter: (store) {
              final allDataRcvTool = store.state.rcvToolState.rcvTools;
              return allDataRcvTool
                  .where(
                    (itemRcvTool) =>
                        itemRcvTool.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
            },
            builder: (context, filteredListRcvTool) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Date Tool Room Received ',
                      icon: Icons.storage,
                      trailing: TextButton.icon(
                        onPressed: () =>
                            _showAddRcvToolDialog(itemTool.idFormDetail),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(foregroundColor: clrOrange),
                      ),
                    ),
                    if (filteredListRcvTool.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      )
                    else
                      ...filteredListRcvTool.map(_buildRcvToolCard),
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
        gradient: LinearGradient(
          colors: [Colors.white, statusColor.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            key: ValueKey<String>('form_${forms.idForm}'),
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
                  _expandedForms.add(forms.idForm);
                } else {
                  _expandedForms.remove(forms.idForm);
                }
              });
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
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              ),
            ),
            children: [
              const SizedBox(height: 10),
              _buildSectionHeader(
                'Request Summary',
                icon: Icons.description_outlined,
                trailing: IconButton(
                  tooltip: 'Edit request',
                  icon: Icon(Icons.edit_document, color: clrOrange),
                  onPressed: () {
                    postContForm(
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
                  },
                ),
              ),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width < mobileWidth
                    ? 1
                    : 2,
                childAspectRatio: MediaQuery.sizeOf(context).width < mobileWidth
                    ? 3.8
                    : 4.4,
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
                    trailing: _buildCommentCardTrailingAction(
                      icon: Icons.task_alt_outlined,
                      label: 'Superior Approval',
                      backgroundColor: clrGreen,
                      tooltip: 'Superior Approval',
                      onPressed: () => _showSupervisorValidationDialog(forms),
                    ),
                  ),
                  _buildInfoTile(
                    icon: Icons.comment_bank_outlined,
                    label: 'SERVICE SUPPORT COMMENT',
                    value: forms.formSadminComment,
                    trailing: _buildCommentCardTrailingAction(
                      icon: Icons.rate_review_outlined,
                      label: 'Service Support Review',
                      backgroundColor: Colors.indigo,
                      tooltip: 'Service Support Review',
                      onPressed: () => _showServiceAdminReviewDialog(forms),
                    ),
                  ),
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
                    trailing: _buildCommentCardTrailingAction(
                      icon: Icons.verified_user_outlined,
                      label: 'Dept Head Approval',
                      backgroundColor: Colors.teal,
                      tooltip: 'Dept Head Approval',
                      onPressed: () => _showDeptHeadValidationDialog(forms),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(
                'Tool List',
                icon: Icons.handyman_outlined,
                trailing: _buildAddToolHeaderAction(),
              ),
              StoreConnector<AppState, List<PostList>>(
                converter: (store) {
                  final allTool = store.state.formsDetailState.formsDetail;
                  return allTool
                      .where((itemTool) => itemTool.idForm == forms.idForm)
                      .toList();
                },
                builder: (context, filteredList) {
                  if (filteredList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 34,
                            color: Colors.grey.shade500,
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
                    itemCount: filteredList.length,
                    itemBuilder: (context, ii) {
                      final itemTool = filteredList[ii];
                      return _buildToolItemCard(itemTool, ii);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: clrOrange.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: clrOrange.withValues(alpha: 0.22)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.orange.shade700),
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade700),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.orange.shade700,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: clrOrange.withValues(alpha: 0.22)),
            ),
            child: DropdownButton<String>(
              value: _searchField,
              underline: const SizedBox.shrink(),
              iconEnabledColor: Colors.orange.shade800,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
              items: _searchFieldLabels.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _searchField = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: clrOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _clearSearch,
                icon: Icon(Icons.clear, color: Colors.orange.shade900),
                tooltip: 'Clear search',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchNotFoundContent() {
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
              '$_searchQuery '
              'Not Found ',
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
        backgroundColor: clrWhite,
        drawer: DrawerMenu(title: name),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppbars(
                title: titleDataTool,
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
                textColor: Colors.black,
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, FormsState>(
                converter: (store) => store.state.formsState,
                builder: (context, state) {
                  final filteredForms = state.forms
                      .where(_matchesSearch)
                      .toList();
                  if (state.isLoadingTool) {
                    return SliverFillRemaiings(
                      errors: "Loading",
                      hasScrollBodys: false,
                    );
                  }
                  if (state.error != null) {
                    return SliverFillRemaiings(
                      errors: state.error ?? '${state.error}',
                      hasScrollBodys: false,
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
                            backgroundColor: clrWhite,
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
                          backgroundColor: clrWhite,
                          child: _buildSearchBar(),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final forms = filteredForms[index];
                          return _buildFormCard(forms, index);
                        }, childCount: filteredForms.length),
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
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

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
