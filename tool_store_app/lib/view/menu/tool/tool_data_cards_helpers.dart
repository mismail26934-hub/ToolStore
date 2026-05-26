import 'package:flutter/material.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';


Widget buildToolDataInfoTile({
  required BuildContext context,
  required IconData icon,
  required String label,
  required String displayValue,
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
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (statusText != null && statusText.isNotEmpty) ...[
                      TextSpan(
                        text: ' - ',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                displayValue,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 4), trailing],
      ],
    ),
  );
}

Widget buildToolDataSectionHeader(
  BuildContext context,
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    ),
  );
}

Widget buildToolDataMetaChip({
  required BuildContext context,
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

Widget buildToolDataActionButton({
  required BuildContext context,
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

Widget buildToolDataLineItem(
  BuildContext context,
  String label,
  String displayValue, {
  Color? valueColor,
}) {
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
            displayValue,
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

BoxDecoration buildToolDataDetailSubCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.detailSubCardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: context.detailSubCardBorder),
  );
}

BoxDecoration buildToolDataDetailSubCardIconDecoration(
  BuildContext context,
) {
  return BoxDecoration(
    color: context.detailSubCardIconBg,
    borderRadius: BorderRadius.circular(12),
  );
}

TextStyle? buildToolDataDetailSubCardTitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: context.textPrimary,
      );
}

