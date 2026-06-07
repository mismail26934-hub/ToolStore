import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/menu/tool/tool_order_timeline.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:intl/intl.dart';
import 'tool_data_state_base.dart';

mixin ToolDataDialogsMixin on ToolDataStateBase {
  @override
  Future<void> showSupervisorValidationDialog(PostList forms) async {
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
                  Expanded(child: Text(strings.superiorValidation)),
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
                        labelText: strings.supervisorApproval,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'APPROVED',
                          child: Text(strings.approved),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text(strings.rejected),
                        ),
                      ],
                      onChanged: (value) {
                        selectedApproval = value;
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.approvalRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: strings.supervisorComment,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.commentRequired;
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
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: strings.confirmSupervisorValidation,
                            message: strings.confirmSupervisorValidationMsg,
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
                                            ? strings.supervisorValidationSaved
                                            : strings.failedSavingValidation),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(strings.failedSavingValidation),
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
                      : Text(strings.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Future<void> showDeptHeadValidationDialog(PostList forms) async {
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
                  Expanded(child: Text(strings.deptHeadApprovalDialog)),
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
                        labelText: strings.serviceDeptHeadApproval,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'APPROVED',
                          child: Text(strings.approved),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text(strings.rejected),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedApproval = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.approvalRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: strings.serviceDeptHeadComment,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.commentRequired;
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
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: strings.confirmDeptHeadApproval,
                            message: strings.confirmDeptHeadApprovalMsg,
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
                                            ? strings.deptHeadApprovalSaved
                                            : strings.failedDeptHeadApproval),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(strings.failedDeptHeadApproval),
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
                      : Text(strings.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Future<void> showServiceAdminReviewDialog(PostList forms) async {
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
                  Expanded(child: Text(strings.serviceAdminReview)),
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
                        labelText: strings.continueOrHold,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'CONTINUE',
                          child: Text(strings.continueLabel),
                        ),
                        DropdownMenuItem(
                          value: 'HOLD',
                          child: Text(strings.holdLabel),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedContinueHold = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.continueOrHoldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: strings.serviceAdminComment,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.commentRequired;
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
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          final confirmed = await showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: strings.confirmServiceAdminReview,
                            message: strings.confirmServiceAdminReviewMsg,
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
                              await refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(strings.failedServiceAdminReview),
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
                      : Text(strings.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Future<void> showRequestOrderToolDialog(PostList forms) async {
    if (!mounted) return;
    if (!canRequestOrderByMilestone(forms)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.requestOrderOnlyMilestone,
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
                  Expanded(child: Text(strings.requestOrderToolDialog)),
                ],
              ),
              content: Text(
                strings.submitToSuperiorApproval,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final confirmed = await showSubmitConfirmationDialog(
                            dialogContext: dialogContext,
                            title: strings.confirmRequestOrderTitle,
                            message: strings.confirmRequestOrderMsg,
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
                                            ? strings.orderRequestSubmitted
                                            : strings.failedSubmitOrder),
                                ),
                              ),
                            );
                            if (isSuccess) {
                              await refreshData();
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(strings.failedSubmitOrder),
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
                      : Text(strings.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showUpdatePurchaseOrderDialog(PostList itemPO) async {
    if (!canEditDeletePurchaseOrder) {
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
          title: Text(strings.updatePurchaseOrder),
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
                strings.cancel,
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
                  if (editResult.statusValue == '1') {
                    await refreshData();
                    final parent = parentFormForDetailId(itemPO.idFormDetail);
                    if (parent != null) {
                      final header =
                          _formHeaderFromStore(parent.idForm) ?? parent;
                      setSearchToFormNumber(header);
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
                        : strings.requestFailed;
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
              child: Text(strings.save, style: TextStyle(color: clrOrange)),
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
  PostList? parentFormForDetailId(String idFormDetail) {
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

  Future<void> dispatchFormMilestoneUpdate(
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
  Future<void> updateFormMilestoneFromSoFillState(PostList forms) async {
    const milestoneOrderProcessed = 'ORDER PROCESSED';
    const milestoneProcessingOrder = 'PROCESSING ORDER';

    final detailIds = _detailIdsForForm(forms);
    if (detailIds.isEmpty) return;

    final currentNorm = OrderTimelineLogic.normFormMilestone(forms.formMilestone);
    final filledSteps = OrderTimelineLogic.filledStepsFromMilestoneNorm(currentNorm);
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
      await dispatchFormMilestoneUpdate(forms, milestoneOrderProcessed);
      return;
    }

    final anySoFilled = detailIds.any(detailHasNonEmptySo);
    if (!anySoFilled) return;

    final currentUpper = forms.formMilestone.trim().toUpperCase();
    if (currentUpper == milestoneOrderProcessed) return;

    await dispatchFormMilestoneUpdate(forms, milestoneProcessingOrder);
  }

  Future<void> updateFormMilestoneForRcvWh(PostList forms) async {
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

    await dispatchFormMilestoneUpdate(forms, targetMilestone);
  }

  Future<void> updateFormMilestoneForRcvTool(PostList forms) async {
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

    await dispatchFormMilestoneUpdate(forms, targetMilestone);
  }

  @override
  Future<void> showAddPurchaseOrderDialog(
    PostList forms,
    String idFormDetail,
  ) async {
    if (!canEditDeletePurchaseOrder) {
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
            title: Text(strings.addPurchaseOrder),
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
                    if (addResult.statusValue == '1') {
                      await refreshData();
                      final header =
                          _formHeaderFromStore(forms.idForm) ?? forms;
                      await updateFormMilestoneFromSoFillState(header);
                      setSearchToFormNumber(header);
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
                          : strings.requestFailed;
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
                child: Text(strings.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      disposeTextControllersAfterFrame([addPoNoCont]);
    }
  }

  Future<void> showDeletePurchaseOrderConfirmDialog(PostList itemPO) async {
    if (!canEditDeletePurchaseOrder) {
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
          title: Text(strings.deletePurchaseOrder),
          content: Text(
            'Are you sure you want to delete PO ${displayValue(itemPO.poNo)}? '
            'This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                strings.cancel,
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
      if (deleteResult.statusValue == '1') {
        await refreshData();
        final parent = parentFormForDetailId(itemPO.idFormDetail);
        if (parent != null) {
          final header = _formHeaderFromStore(parent.idForm) ?? parent;
          setSearchToFormNumber(header);
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
            : strings.deleteFailed;
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

  Future<void> showUpdateSalesOrderDialog(PostList itemSO) async {
    if (!canManageSalesOrderPr) {
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
          title: Text(strings.updateSalesOrder),
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
                        pickDateIntoController(dialogContext, etaCont),
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
                strings.cancel,
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
                  if (editResult.statusValue == '1') {
                    await refreshData();
                    final parent = parentFormForDetailId(itemSO.idFormDetail);
                    if (parent != null) {
                      final header =
                          _formHeaderFromStore(parent.idForm) ?? parent;
                      await updateFormMilestoneFromSoFillState(header);
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
                        : strings.requestFailed;
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
              child: Text(strings.save, style: TextStyle(color: clrOrange)),
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> showAddSalesOrderDialog(
    PostList forms,
    String idFormDetail,
  ) async {
    if (!canManageSalesOrderPr) {
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
            title: Text(strings.addSalesOrder),
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
                          pickDateIntoController(dialogContext, addEtaCont),
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
                    if (addResult.statusValue == '1') {
                      await refreshData();
                      final header =
                          _formHeaderFromStore(forms.idForm) ?? forms;
                      await updateFormMilestoneFromSoFillState(header);
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
                          : strings.requestFailed;
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
                child: Text(strings.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      disposeTextControllersAfterFrame([addSoCont, addEtaCont, addNoteSoCont]);
    }
  }

  Future<void> showDeleteSalesOrderConfirmDialog(PostList itemSO) async {
    if (!canManageSalesOrderPr) {
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
          title: Text(strings.deleteSalesOrder),
          content: Text(
            'Are you sure you want to delete SO / PR number ${displayValue(itemSO.so)}? '
            'This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                strings.cancel,
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
      if (deleteResult.statusValue == '1') {
        await refreshData();
        final parent = parentFormForDetailId(itemSO.idFormDetail);
        if (parent != null) {
          final header = _formHeaderFromStore(parent.idForm) ?? parent;
          setSearchToFormNumber(header);
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
            : strings.deleteFailed;
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

  Future<void> showUpdateRcvWhDialog(PostList item) async {
    if (!canManageRcvWhDate) {
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
            title: Text(strings.updateDateWhReceived),
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
                          pickDateIntoController(dialogContext, dateCont),
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
                    if (editResult.statusValue == '1') {
                      await refreshData();
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
                          : strings.requestFailed;
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
                child: Text(strings.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      disposeTextControllersAfterFrame([dateCont]);
    }
  }

  @override
  Future<void> showAddRcvWhDialog(PostList forms, String idFormDetail) async {
    if (!canManageRcvWhDate) {
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
            title: Text(strings.addDateWhReceived),
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
                          pickDateIntoController(dialogContext, dateCont),
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
                    if (addResult.statusValue == '1') {
                      await updateFormMilestoneForRcvWh(forms);
                      await refreshData();
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
                          : strings.requestFailed;
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
                child: Text(strings.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> showDeleteRcvWhConfirmDialog(PostList item) async {
    if (!canManageRcvWhDate) {
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
          title: Text(strings.deleteDateWhReceived),
          content: Text(
            'Are you sure you want to delete the WH received date '
            '${displayValue(item.rcvWhDate)}? This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                strings.cancel,
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
      if (deleteResult.statusValue == '1') {
        await refreshData();
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
            : strings.deleteFailed;
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

  Future<void> showUpdateRcvToolDialog(PostList item) async {
    if (!canManageRcvToolDate) {
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
            title: Text(strings.updateDateToolRoomReceived),
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
                          pickDateIntoController(dialogContext, dateCont),
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
                    if (editResult.statusValue == '1') {
                      final parent = parentFormForDetailId(item.idFormDetail);
                      if (parent != null) {
                        await updateFormMilestoneForRcvTool(parent);
                      }
                      await refreshData();
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
                          : strings.requestFailed;
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
                child: Text(strings.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      disposeTextControllersAfterFrame([dateCont]);
    }
  }

  @override
  Future<void> showAddRcvToolDialog(
    PostList forms,
    String idFormDetail,
  ) async {
    if (!canManageRcvToolDate) {
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
            title: Text(strings.addDateToolRoomReceived),
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
                          pickDateIntoController(dialogContext, dateCont),
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
                    if (addResult.statusValue == '1') {
                      await updateFormMilestoneForRcvTool(forms);
                      await refreshData();
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
                          : strings.requestFailed;
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
                child: Text(strings.save, style: TextStyle(color: clrOrange)),
              ),
            ],
          );
        },
      );
    } finally {
      disposeTextControllersAfterFrame([dateCont]);
    }
  }

  Future<void> showDeleteRcvToolConfirmDialog(PostList item) async {
    if (!canManageRcvToolDate) {
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
          title: Text(strings.deleteDateToolRoomReceived),
          content: Text(
            'Are you sure you want to delete the tool room received date '
            '${displayValue(item.rcvToolDate)}? This will be removed from the server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                strings.cancel,
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
      if (deleteResult.statusValue == '1') {
        final parent = parentFormForDetailId(item.idFormDetail);
        if (parent != null) {
          await updateFormMilestoneForRcvTool(parent);
        }
        await refreshData();
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
            : strings.deleteFailed;
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
}
