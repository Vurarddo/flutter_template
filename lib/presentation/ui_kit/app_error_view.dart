import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_template/presentation/ui_kit/preview_wrapper.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Щось пішло не так',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: context.customColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Спробувати знову'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Error View - Light',
  size: Size(360, 300),
)
Widget previewAppErrorViewLight() {
  return PreviewWrapper(
    brightness: Brightness.light,
    child: AppErrorView(
      message: 'Не вдалося завантажити список фільмів. Перевірте зʼєднання.',
      onRetry: () {},
    ),
  );
}

@Preview(
  name: 'Error View - Dark',
  size: Size(360, 300),
)
Widget previewAppErrorViewDark() {
  return PreviewWrapper(
    brightness: Brightness.dark,
    child: AppErrorView(
      message: 'Не вдалося завантажити список фільмів. Перевірте зʼєднання.',
      onRetry: () {},
    ),
  );
}
