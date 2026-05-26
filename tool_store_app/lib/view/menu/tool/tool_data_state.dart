import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/controller/function/navigation_helpers.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'tool_data_state_base.dart';
import 'tool_data_dialogs.dart';
import 'tool_data_form_card.dart';
import 'tool_data_tool_item_card.dart';
import 'tool_data_list.dart';
import 'tool_data_search.dart';
import 'tool_data_detail_cards.dart';

class ToolDataState extends ToolDataStateBase
    with
        ToolDataDialogsMixin,
        ToolDataFormCardMixin,
        ToolDataToolItemCardMixin,
        ToolDataListMixin {
  @override
  Widget buildServiceSupportCommentInfoTile(PostList forms) {
    final milestoneUi = serviceSupportMilestoneStatusVisual(
      forms.formMilestone,
    );
    return buildInfoTile(
      icon: Icons.comment_bank_outlined,
      label: strings.serviceSupportComment,
      value: forms.formSadminComment,
      statusText: milestoneUi.text,
      statusColor: milestoneUi.color,
      statusIcon: milestoneUi.icon,
      trailing: canAccessRequestOrderTool
          ? buildCommentCardTrailingAction(
              icon: Icons.rate_review_outlined,
              label: strings.serviceSupportReview,
              backgroundColor: Colors.indigo,
              tooltip: canServiceSupportReviewByMilestone(forms)
                  ? strings.serviceSupportReview
                  : strings.serviceSupportReviewDisabled,
              onPressed: canServiceSupportReviewByMilestone(forms)
                  ? () => showServiceAdminReviewDialog(forms)
                  : null,
            )
          : null,
    );
  }

  @override
  Widget buildPoCard(PostList itemPO, {required bool canManageActions}) {
    return buildToolDataPoCard(
      context: context,
      itemPO: itemPO,
      canManageActions: canManageActions,
      canEditDeletePurchaseOrder: canEditDeletePurchaseOrder,
      displayValue: displayValue,
      detailSubCardTitleStyle: detailSubCardTitleStyle(),
      detailSubCardDecoration: detailSubCardDecoration(),
      detailSubCardIconDecoration: detailSubCardIconDecoration(),
      poActionsBlockedTooltip: poActionsBlockedTooltip,
      buildEditDeleteActions: buildEditDeleteActions,
      onUpdatePurchaseOrder: () => showUpdatePurchaseOrderDialog(itemPO),
      onDeletePurchaseOrder: () => showDeletePurchaseOrderConfirmDialog(itemPO),
    );
  }

  @override
  Widget buildSoCard(PostList itemSO, {required bool canManageActions}) {
    return buildToolDataSoCard(
      context: context,
      itemSO: itemSO,
      canManageActions: canManageActions,
      canManageSalesOrderPr: canManageSalesOrderPr,
      displayValue: displayValue,
      buildLineItem: buildLineItem,
      detailSubCardTitleStyle: detailSubCardTitleStyle(),
      detailSubCardDecoration: detailSubCardDecoration(),
      detailSubCardIconDecoration: detailSubCardIconDecoration(),
      soActionsBlockedTooltip: soActionsBlockedTooltip,
      buildEditDeleteActions: buildEditDeleteActions,
      onUpdateSalesOrder: () => showUpdateSalesOrderDialog(itemSO),
      onDeleteSalesOrder: () => showDeleteSalesOrderConfirmDialog(itemSO),
    );
  }

  @override
  Widget buildRcvWhCard(PostList itemRcvWh, {required bool canManageActions}) {
    return buildToolDataRcvWhCard(
      itemRcvWh: itemRcvWh,
      canManageActions: canManageActions,
      canManageRcvWhDate: canManageRcvWhDate,
      displayValue: displayValue,
      detailSubCardTitleStyle: detailSubCardTitleStyle(),
      detailSubCardDecoration: detailSubCardDecoration(),
      detailSubCardIconDecoration: detailSubCardIconDecoration(),
      whReceivedActionsBlockedTooltip: whReceivedActionsBlockedTooltip,
      buildEditDeleteActions: buildEditDeleteActions,
      onUpdateRcvWh: () => showUpdateRcvWhDialog(itemRcvWh),
      onDeleteRcvWh: () => showDeleteRcvWhConfirmDialog(itemRcvWh),
    );
  }

  @override
  Widget buildRcvToolCard(PostList itemRcvTool) {
    return buildToolDataRcvToolCard(
      itemRcvTool: itemRcvTool,
      canManageRcvToolDate: canManageRcvToolDate,
      displayValue: displayValue,
      detailSubCardTitleStyle: detailSubCardTitleStyle(),
      detailSubCardDecoration: detailSubCardDecoration(),
      detailSubCardIconDecoration: detailSubCardIconDecoration(),
      buildEditDeleteActions: buildEditDeleteActions,
      onUpdateRcvTool: () => showUpdateRcvToolDialog(itemRcvTool),
      onDeleteRcvTool: () => showDeleteRcvToolConfirmDialog(itemRcvTool),
    );
  }

  @override
  Widget buildToolItemCard(PostList itemTool, int index, PostList forms) =>
      buildToolDataToolItemCard(itemTool, index, forms);

  @override
  Widget buildFormCard(PostList forms, int index) =>
      buildToolDataFormCard(forms, index);

  @override
  Widget buildSearchBar() {
    return buildToolDataSearchBar(
      context: context,
      searchController: searchController,
      searchField: searchField,
      canSubmitSearch: canSubmitSearch,
      onSubmitSearch: submitSearch,
      onSearchTextEdited: onSearchTextEdited,
      onSearchFieldChanged: (value) {
        setState(() => searchField = value);
        refreshData();
      },
      onClearSearch: clearSearch,
      clearSearchTooltip: strings.clearSearch,
    );
  }

  @override
  Widget buildSearchNotFoundContent() {
    return buildToolDataSearchNotFoundContent(
      context: context,
      searchQuery: searchQuery,
      hasMilestoneFilters: hasMilestoneFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: context.pageBackground,
        drawer: DrawerMenu(title: name),
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppbars(
                title: pageTitle,
                onPressTailing: canAddOrEditDataToolForm
                    ? () {
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
                      }
                    : null,
                onPressLeading: () => scaffoldKey.currentState?.openDrawer(),
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, FormsState>(
                converter: (store) => store.state.formsState,
                builder: (context, state) => buildToolDataFormsListSliver(state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
