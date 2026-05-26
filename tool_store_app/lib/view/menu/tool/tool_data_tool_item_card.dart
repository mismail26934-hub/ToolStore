import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/custom/shimmer/detail_section_vm.dart';
import 'package:tool_store_app/view/custom/shimmer/tool_detail_shimmers.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:intl/intl.dart';
import 'tool_data_state_base.dart';

mixin ToolDataToolItemCardMixin on ToolDataStateBase {
  Widget buildToolDataToolItemCard(
    PostList itemTool,
    int index,
    PostList forms,
  ) {
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
                  displayValue(itemTool.pnGroup),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: canEditToolDetail(forms)
                    ? 'Edit data tool'
                    : 'Edit data tool Disabled',
                onPressed: canEditToolDetail(forms)
                    ? () => openEditToolDetail(forms, itemTool, index)
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
              buildMetaChip(
                icon: Icons.build_circle_outlined,
                label: 'Type ${displayValue(itemTool.valType)}',
                color: Colors.deepOrange,
              ),
              buildMetaChip(
                icon: Icons.inventory_2_outlined,
                label: 'Qty ${displayValue(itemTool.qty)}',
                color: Colors.orange.shade700,
              ),
              buildMetaChip(
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
          buildLineItem('Part Desc', itemTool.pnDesc),
          buildLineItem('Explanation', itemTool.explan),
          buildLineItem('Action Note', itemTool.actionNote),
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
                  canEditDeletePurchaseOrder &&
                  canManagePurchaseOrderWhenSalesOrderBlank(
                    vm.salesOrderExists,
                  );
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionHeader(
                      'Purchase Order',
                      icon: Icons.receipt,
                      trailing: canEditDeletePurchaseOrder
                          ? Tooltip(
                              message: canManagePo
                                  ? 'Add Purchase Order'
                                  : poActionsBlockedTooltip,
                              child: TextButton.icon(
                                onPressed: canManagePo
                                    ? () => showAddPurchaseOrderDialog(
                                        forms,
                                        itemTool.idFormDetail,
                                      )
                                    : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(strings.addButton),
                                style: TextButton.styleFrom(
                                  foregroundColor: clrOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                    DetailSectionBody(
                      viewModel: vm,
                      itemBuilder: (context, itemPO) => buildPoCard(
                        itemPO,
                        canManageActions: canManagePo,
                      ),
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
                  canManageSalesOrderPr &&
                  canManageSalesOrderWhenWhReceivedBlank(vm.whReceivedExists);
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionHeader(
                      'Sales Order / Purchase Request (SO/PR)',
                      icon: Icons.route,
                      trailing: canManageSalesOrderPr
                          ? Tooltip(
                              message: canManageSo
                                  ? 'Add Sales Order (SO) / Purchase Request (PR)'
                                  : soActionsBlockedTooltip,
                              child: TextButton.icon(
                                onPressed: canManageSo
                                    ? () => showAddSalesOrderDialog(
                                        forms,
                                        itemTool.idFormDetail,
                                      )
                                    : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(strings.addButton),
                                style: TextButton.styleFrom(
                                  foregroundColor: clrOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                    DetailSectionBody(
                      viewModel: vm,
                      itemBuilder: (context, itemSO) => buildSoCard(
                        itemSO,
                        canManageActions: canManageSo,
                      ),
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
                  canManageRcvWhDate &&
                  canManageWhReceivedWhenToolRoomBlank(
                    vm.toolRoomReceivedExists,
                  );
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionHeader(
                      'Date WH Received ',
                      icon: Icons.warehouse,
                      trailing: canManageRcvWhDate
                          ? Tooltip(
                              message: canManageWh
                                  ? 'Add Date WH Received'
                                  : whReceivedActionsBlockedTooltip,
                              child: TextButton.icon(
                                onPressed: canManageWh
                                    ? () => showAddRcvWhDialog(
                                        forms,
                                        itemTool.idFormDetail,
                                      )
                                    : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(strings.addButton),
                                style: TextButton.styleFrom(
                                  foregroundColor: clrOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                    DetailSectionBody(
                      viewModel: vm,
                      itemBuilder: (context, itemRcvWh) => buildRcvWhCard(
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
                    buildSectionHeader(
                      'Date Tool Room Received ',
                      icon: Icons.storage,
                      trailing: canManageRcvToolDate
                          ? TextButton.icon(
                              onPressed: () => showAddRcvToolDialog(
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
                    DetailSectionBody(
                      viewModel: vm,
                      itemBuilder: (context, item) => buildRcvToolCard(item),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
