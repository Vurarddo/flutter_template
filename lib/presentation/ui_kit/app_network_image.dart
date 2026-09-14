import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:flutter_template/presentation/ui_kit/preview_wrapper.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry borderRadius;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _buildPlaceholder(context, customColors);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: customColors.shimmerBase,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context, customColors);
        },
      ),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context,
    dynamic customColors,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.customColors.surfaceElevated,
        borderRadius: borderRadius,
        border: Border.all(color: context.customColors.cardBorder),
      ),
      child: Icon(
        Icons.movie_creation_outlined,
        size: 32,
        color: context.customColors.secondaryText,
      ),
    );
  }
}

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Network Image Placeholder - Light',
  size: Size(150, 200),
)
Widget previewNetworkImagePlaceholderLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: AppNetworkImage(
      imageUrl: null,
      width: 120,
      height: 180,
    ),
  );
}

@Preview(
  name: 'Network Image Placeholder - Dark',
  size: Size(150, 200),
)
Widget previewNetworkImagePlaceholderDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: AppNetworkImage(
      imageUrl: null,
      width: 120,
      height: 180,
    ),
  );
}
