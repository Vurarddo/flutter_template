import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_template/presentation/ui_kit/preview_wrapper.dart';

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Adaptive Container - Light',
  size: Size(800, 200),
)
Widget previewAdaptiveContainerLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: AdaptiveContainer(
      maxWidth: 600,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Responsive Max Width Container'),
        ),
      ),
    ),
  );
}

@Preview(
  name: 'Adaptive Container - Dark',
  size: Size(800, 200),
)
Widget previewAdaptiveContainerDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: AdaptiveContainer(
      maxWidth: 600,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Responsive Max Width Container'),
        ),
      ),
    ),
  );
}
