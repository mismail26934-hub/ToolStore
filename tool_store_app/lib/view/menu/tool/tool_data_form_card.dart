import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/custom/shimmer/detail_section_vm.dart';
import 'package:tool_store_app/view/custom/shimmer/tool_detail_shimmers.dart';
import 'package:tool_store_app/view/menu/tool/tool_order_timeline.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'tool_data_state_base.dart';

mixin ToolDataFormCardMixin on ToolDataStateBase {
  Widget buildToolDataFormCard(PostList forms, int index) {
    final isExpandedLocal = expandedForms.contains(forms.idForm);
    final cardStatusColor = statusColor(forms.formServComment);

    final leading = Container(
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
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          displayValue(forms.formNo),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            buildMetaChip(
              icon: Icons.dew_point,
              label: displayValue(
                forms.formMilestone != "" ? forms.formMilestone : "DRAFT",
              ),
              color: Colors.orange.shade800,
            ),
            buildMetaChip(
              icon: Icons.flag_outlined,
              label: displayValue(forms.formServComment),
              color: Colors.orange.shade800,
            ),
            buildMetaChip(
              icon: Icons.person,
              label: displayValue(forms.formServName),
              color: Colors.orange.shade800,
            ),
          ],
        ),
      ],
    );

    final subtitle = StoreConnector<AppState, OrderTimelineViewModel>(
      converter: (store) => OrderTimelineLogic.compute(store, forms),
      builder: (context, timelineVm) {
        final nextMilestone = OrderTimelineLogic.nextMilestoneLabel(
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
                  child: buildSectionHeader(
                    nextMilestone == 'COMPLETED'
                        ? 'COMPLETED'
                        : 'Next: $nextMilestone',
                    icon: Icons.timeline,
                  ),
                ),
                OrderStatusTimeline(
                  viewModel: timelineVm,
                  wrapInPanel: false,
                ),
              ],
            ),
          ),
        );
      },
    );

    final detailWidgets = <Widget>[
      const SizedBox(height: 16),
      buildSectionHeader(
        'Request Summary',
        icon: Icons.description_outlined,
        trailing: canAddOrEditDataToolForm
            ? IconButton(
                tooltip: 'Edit request',
                icon: Icon(Icons.edit_document, color: clrOrange),
                onPressed: () => openEditRequestForm(forms),
              )
            : null,
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
          buildInfoTile(
            icon: Icons.date_range,
            label: 'Date Create',
            value: forms.formDateServName,
          ),
          buildInfoTile(
            icon: Icons.person_outline,
            label: 'Check By',
            value: forms.formCheckBy,
            trailing: buildCheckByInfoTileTrailing(forms),
          ),
          buildInfoTile(
            icon: Icons.comment_bank_outlined,
            label: 'SUPERIOR',
            value: forms.formSuperiorComment,
            statusText: isApprovedValue(forms.formSuperiorAprd)
                ? 'APPROVED'
                : isRejectedValue(forms.formSuperiorAprd)
                ? 'REJECTED'
                : 'WAITING APPROVAL',
            statusColor: isApprovedValue(forms.formSuperiorAprd)
                ? clrGreen
                : isRejectedValue(forms.formSuperiorAprd)
                ? Colors.red
                : Colors.orange.shade700,
            statusIcon: isApprovedValue(forms.formSuperiorAprd)
                ? Icons.check_circle
                : isRejectedValue(forms.formSuperiorAprd)
                ? Icons.cancel
                : Icons.pending,
            trailing: canAccessSupervisorApproval(forms)
                ? buildCommentCardTrailingAction(
                    icon: Icons.task_alt_outlined,
                    label: 'Superior Approval',
                    backgroundColor: clrGreen,
                    tooltip: canSuperiorApprovalByMilestone(forms)
                        ? 'Superior Approval'
                        : 'Superior Approval Disabled',
                    onPressed: canSuperiorApprovalByMilestone(forms)
                        ? () => showSupervisorValidationDialog(forms)
                        : null,
                  )
                : null,
          ),
          buildServiceSupportCommentInfoTile(forms),
          buildInfoTile(
            icon: Icons.comment_bank_sharp,
            label: 'SERVICE DEPT. HEAD',
            value: forms.formSheadComment,
            statusText: isApprovedValue(forms.formSheadAprd)
                ? 'APPROVED'
                : isRejectedValue(forms.formSheadAprd)
                ? 'REJECTED'
                : 'WAITING APPROVAL',
            statusColor: isApprovedValue(forms.formSheadAprd)
                ? clrGreen
                : isRejectedValue(forms.formSheadAprd)
                ? Colors.red
                : Colors.orange.shade700,
            statusIcon: isApprovedValue(forms.formSheadAprd)
                ? Icons.check_circle
                : isRejectedValue(forms.formSheadAprd)
                ? Icons.cancel
                : Icons.pending,
            trailing: canAccessDeptHeadApproval
                ? buildCommentCardTrailingAction(
                    icon: Icons.verified_user_outlined,
                    label: 'Dept Head Approval',
                    backgroundColor: Colors.teal,
                    tooltip: canDeptHeadApprovalByMilestone(forms)
                        ? 'Dept Head Approval'
                        : 'Dept Head Approval Disabled',
                    onPressed: canDeptHeadApprovalByMilestone(forms)
                        ? () => showDeptHeadValidationDialog(forms)
                        : null,
                  )
                : null,
          ),
        ],
      ),
      const SizedBox(height: 20),
      buildSectionHeader(
        'Tool List',
        icon: Icons.handyman_outlined,
        trailing: buildToolListHeaderTrailing(forms),
      ),
      StoreConnector<AppState, DetailSectionVm>(
        converter: (store) {
          final formId = forms.idForm.trim();
          final allTool = store.state.formsDetailState.formsDetail;
          final items = allTool
              .where((itemTool) => itemTool.idForm.trim() == formId)
              .toList();
          final isLoading =
              isLoadingFormDetails(forms.idForm) && items.isEmpty;
          final error = store.state.formsDetailState.error?.trim();
          return DetailSectionVm(
            items: items,
            isLoading: isLoading,
            errorMessage: !isLoading && items.isEmpty ? error : null,
          );
        },
        builder: (context, vm) {
          return ToolListSectionBody(
            viewModel: vm,
            itemBuilder: (context, index, itemTool) {
              try {
                return buildToolItemCard(itemTool, index, forms);
              } catch (e) {
                return ToolListErrorPlaceholder(
                  message: 'Gagal menampilkan tool #${index + 1}: $e',
                );
              }
            },
          );
        },
      ),
    ];

    final Widget body = ExpansionTile(
      key: ValueKey<String>('form_${forms.idForm}_$isExpandedLocal'),
      tilePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      shape: const Border(),
      collapsedShape: const Border(),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      initiallyExpanded: isExpandedLocal,
      onExpansionChanged: (expanded) =>
          onFormCardExpansionChanged(forms, expanded),
      leading: leading,
      title: title,
      subtitle: subtitle,
      children: detailWidgets,
    );

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
                  cardStatusColor.withValues(alpha: 0.04),
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
          child: body,
        ),
      ),
    );
  }
}
