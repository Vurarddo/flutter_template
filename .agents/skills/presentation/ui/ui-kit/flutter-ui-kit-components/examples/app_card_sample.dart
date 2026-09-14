import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final borderSide = isSelected
        ? BorderSide(color: colorScheme.primary, width: 2)
        : BorderSide(color: colorScheme.outlineVariant);

    return Card(
      elevation: 0,
      color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.15) : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderSide,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
