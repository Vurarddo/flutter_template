import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:flutter_template/presentation/ui_kit/preview_wrapper.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

// Sample component for preview demo
class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: context.textTheme.bodyMedium),
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
  name: 'Custom Card - Light Mode',
  size: Size(320, 150),
)
Widget previewCustomCardLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: CustomCard(
      title: 'Subscription Active',
      subtitle: 'Your plan renews on Oct 1st.',
    ),
  );
}

@Preview(
  name: 'Custom Card - Dark Mode',
  size: Size(320, 150),
)
Widget previewCustomCardDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: CustomCard(
      title: 'Subscription Active',
      subtitle: 'Your plan renews on Oct 1st.',
    ),
  );
}
