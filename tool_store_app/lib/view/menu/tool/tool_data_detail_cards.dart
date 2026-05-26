import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/theme/app_theme.dart';

Widget buildToolDataPoCard({
  required BuildContext context,
  required PostList itemPO,
  required bool canManageActions,
  required bool canEditDeletePurchaseOrder,
  required String Function(String?) displayValue,
  required TextStyle? detailSubCardTitleStyle,
  required BoxDecoration detailSubCardDecoration,
  required BoxDecoration detailSubCardIconDecoration,
  required String poActionsBlockedTooltip,
  required Widget Function({
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    String? disabledTooltip,
  })
  buildEditDeleteActions,
  required VoidCallback onUpdatePurchaseOrder,
  required VoidCallback onDeletePurchaseOrder,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: detailSubCardDecoration,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: detailSubCardIconDecoration,
          child: const Icon(Icons.receipt_long, color: Colors.deepOrange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PO : ${displayValue(itemPO.poNo)}',
                style: detailSubCardTitleStyle,
              ),
            ],
          ),
        ),
        if (canEditDeletePurchaseOrder)
          buildEditDeleteActions(
            onEdit: canManageActions ? onUpdatePurchaseOrder : null,
            onDelete: canManageActions ? onDeletePurchaseOrder : null,
            disabledTooltip: poActionsBlockedTooltip,
          ),
      ],
    ),
  );
}

Widget buildToolDataSoCard({
  required BuildContext context,
  required PostList itemSO,
  required bool canManageActions,
  required bool canManageSalesOrderPr,
  required String Function(String?) displayValue,
  required Widget Function(String label, String value, {Color? valueColor})
  buildLineItem,
  required TextStyle? detailSubCardTitleStyle,
  required BoxDecoration detailSubCardDecoration,
  required BoxDecoration detailSubCardIconDecoration,
  required String soActionsBlockedTooltip,
  required Widget Function({
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    String? disabledTooltip,
  })
  buildEditDeleteActions,
  required VoidCallback onUpdateSalesOrder,
  required VoidCallback onDeleteSalesOrder,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: detailSubCardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: detailSubCardIconDecoration,
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
                    'SO : ${displayValue(itemSO.so)}',
                    style: detailSubCardTitleStyle,
                  ),
                ],
              ),
            ),
            if (canManageSalesOrderPr)
              buildEditDeleteActions(
                onEdit: canManageActions ? onUpdateSalesOrder : null,
                onDelete: canManageActions ? onDeleteSalesOrder : null,
                disabledTooltip: soActionsBlockedTooltip,
              ),
          ],
        ),
        const SizedBox(height: 12),
        buildLineItem('ETA', itemSO.eta, valueColor: context.textPrimary),
        buildLineItem('Note SO', itemSO.noteSo, valueColor: context.textPrimary),
      ],
    ),
  );
}

Widget buildToolDataRcvWhCard({
  required PostList itemRcvWh,
  required bool canManageActions,
  required bool canManageRcvWhDate,
  required String Function(String?) displayValue,
  required TextStyle? detailSubCardTitleStyle,
  required BoxDecoration detailSubCardDecoration,
  required BoxDecoration detailSubCardIconDecoration,
  required String whReceivedActionsBlockedTooltip,
  required Widget Function({
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    String? disabledTooltip,
  })
  buildEditDeleteActions,
  required VoidCallback onUpdateRcvWh,
  required VoidCallback onDeleteRcvWh,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: detailSubCardDecoration,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: detailSubCardIconDecoration,
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
                displayValue(itemRcvWh.rcvWhDate),
                style: detailSubCardTitleStyle,
              ),
            ],
          ),
        ),
        if (canManageRcvWhDate)
          buildEditDeleteActions(
            onEdit: canManageActions ? onUpdateRcvWh : null,
            onDelete: canManageActions ? onDeleteRcvWh : null,
            disabledTooltip: whReceivedActionsBlockedTooltip,
          ),
      ],
    ),
  );
}

Widget buildToolDataRcvToolCard({
  required PostList itemRcvTool,
  required bool canManageRcvToolDate,
  required String Function(String?) displayValue,
  required TextStyle? detailSubCardTitleStyle,
  required BoxDecoration detailSubCardDecoration,
  required BoxDecoration detailSubCardIconDecoration,
  required Widget Function({
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    String? disabledTooltip,
  })
  buildEditDeleteActions,
  required VoidCallback onUpdateRcvTool,
  required VoidCallback onDeleteRcvTool,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: detailSubCardDecoration,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: detailSubCardIconDecoration,
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
                displayValue(itemRcvTool.rcvToolDate),
                style: detailSubCardTitleStyle,
              ),
            ],
          ),
        ),
        if (canManageRcvToolDate)
          buildEditDeleteActions(
            onEdit: onUpdateRcvTool,
            onDelete: onDeleteRcvTool,
          ),
      ],
    ),
  );
}

