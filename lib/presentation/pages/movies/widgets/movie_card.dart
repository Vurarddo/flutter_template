import 'package:flutter/material.dart';
import 'package:flutter_template/domain/movies/entities/movie.dart';
import 'package:flutter_template/presentation/ui_kit/app_network_image.dart';
import 'package:flutter_template/presentation/ui_kit/rating_badge.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  void _onHover(bool hovering) {
    if (_isHovered != hovering) {
      setState(() => _isHovered = hovering);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final movie = widget.movie;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? Matrix4.translationValues(0.0, -3.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withValues(alpha: 0.5)
                : customColors.cardBorder,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    imageUrl: movie.posterUrl,
                    width: 90,
                    height: 130,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            RatingBadge(
                              rating: movie.voteAverage,
                              voteCount: movie.voteCount,
                            ),
                            if (movie.releaseDate != null &&
                                movie.releaseDate!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                movie.releaseDate!.split('-').first,
                                style: textTheme.bodySmall?.copyWith(
                                  color: customColors.secondaryText,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview.isNotEmpty
                              ? movie.overview
                              : 'Опис відсутній.',
                          style: textTheme.bodySmall?.copyWith(
                            color: customColors.secondaryText,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
