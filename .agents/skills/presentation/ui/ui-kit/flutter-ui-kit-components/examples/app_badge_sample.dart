import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

enum AppBadgeVariant { neutral, success, warning, error, primary }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final (backgroundColor, foregroundColor) = switch (variant) {
      AppBadgeVariant.primary => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      AppBadgeVariant.success => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      AppBadgeVariant.warning => (colorScheme.errorContainer.withValues(alpha: 0.3), colorScheme.onErrorContainer),
      AppBadgeVariant.error   => (colorScheme.errorContainer, colorScheme.onErrorContainer),
      AppBadgeVariant.neutral => (colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 14, color: foregroundColor),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
