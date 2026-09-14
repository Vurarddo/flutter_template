import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:flutter_template/presentation/ui_kit/preview_wrapper.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size = 32.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Loading Indicator - Light',
  size: Size(100, 100),
)
Widget previewAppLoadingIndicatorLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: AppLoadingIndicator(),
  );
}

@Preview(
  name: 'Loading Indicator - Dark',
  size: Size(100, 100),
)
Widget previewAppLoadingIndicatorDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: AppLoadingIndicator(),
  );
}
