import 'package:flutter/material.dart';

import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class MoviesSliverAppBar extends StatelessWidget {
  const MoviesSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_movies_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Зараз у кіно',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'TMDB Now Playing',
                style: textTheme.labelSmall?.copyWith(
                  color: context.customColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
