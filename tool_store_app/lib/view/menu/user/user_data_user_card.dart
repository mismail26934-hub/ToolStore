import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:tool_store_app/view/menu/user/user_data_card_helpers.dart';

Widget buildUserDataUserCard({
  required BuildContext context,
  required PostList users,
  required int index,
  required String Function(String?) displayValue,
  required Color Function(String status) statusColorForStatus,
  required VoidCallback onEdit,
}) {
  final statusColor = statusColorForStatus(users.status);
  final isDark = context.isDarkMode;
  final surface = context.cardSurface;
  final LinearGradient? orangeCardGradient = isDark
      ? null
      : LinearGradient(
          colors: [
            Color.alphaBlend(
              clrOrange.withValues(alpha: 0.14),
              surface,
            ),
            Color.alphaBlend(
              clrOrange.withValues(alpha: 0.22),
              surface,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: isDark ? Colors.black : null,
      gradient: orangeCardGradient,
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
              width: 40,
              height: 40,
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
              child: SelectableText(
                displayValue(users.username),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: context.s.editUserTooltip,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_document),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            buildUserDataMetaChip(
              context: context,
              icon: Icons.verified_user_outlined,
              label: context.s.levelChip(displayValue(users.level)),
              color: Colors.orange.shade800,
            ),
            buildUserDataMetaChip(
              context: context,
              icon: Icons.flag_outlined,
              label: displayValue(users.status),
              color: statusColor,
            ),
          ],
        ),
        const SizedBox(height: 14),
        buildUserDataLineItem(
          context: context,
          label: context.s.fieldName,
          displayValue: displayValue(users.namaUser),
        ),
        buildUserDataLineItem(
          context: context,
          label: context.s.fieldPhone,
          displayValue: displayValue(users.noTelp),
        ),
        buildUserDataLineItem(
          context: context,
          label: context.s.fieldSuperior,
          displayValue: displayValue(users.namaSuperior),
        ),
      ],
    ),
  );
}
