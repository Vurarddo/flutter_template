import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:flutter_template/presentation/ui_kit/preview_wrapper.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final int? voteCount;

  const RatingBadge({
    super.key,
    required this.rating,
    this.voteCount,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final formattedRating = rating > 0 ? rating.toStringAsFixed(1) : 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: customColors.ratingBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: customColors.ratingGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: customColors.ratingGold,
          ),
          const SizedBox(width: 4),
          Text(
            formattedRating,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: customColors.ratingGold,
            ),
          ),
          if (voteCount != null && voteCount! > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($voteCount)',
              style: context.textTheme.labelSmall?.copyWith(
                color: customColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Rating Badge - Light',
  size: Size(200, 100),
)
Widget previewRatingBadgeLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: RatingBadge(
      rating: 8.4,
      voteCount: 1240,
    ),
  );
}

@Preview(
  name: 'Rating Badge - Dark',
  size: Size(200, 100),
)
Widget previewRatingBadgeDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: RatingBadge(
      rating: 8.4,
      voteCount: 1240,
    ),
  );
}
