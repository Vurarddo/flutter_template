import 'package:flutter/material.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/domain_failure_localization_extension.dart';

class ItemErrorView extends StatelessWidget {
  final DomainFailure failure;
  final VoidCallback onRetry;

  const ItemErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              failure.toLocalizedString(context),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
