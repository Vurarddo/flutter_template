import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class MoviesSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const MoviesSkeletonLoader({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                height: 154,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: customColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      height: 130,
                      decoration: BoxDecoration(
                        color: customColors.shimmerBase,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 18,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: customColors.shimmerBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 22,
                            width: 80,
                            decoration: BoxDecoration(
                              color: customColors.shimmerBase,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: customColors.shimmerBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 12,
                            width: 140,
                            decoration: BoxDecoration(
                              color: customColors.shimmerBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}
