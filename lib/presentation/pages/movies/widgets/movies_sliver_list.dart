import 'package:flutter/material.dart';

import 'package:flutter_template/domain/movies/entities/movie.dart';
import 'package:flutter_template/presentation/pages/movies/widgets/movie_card.dart';
import 'package:flutter_template/presentation/ui_kit/app_loading_indicator.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class MoviesSliverList extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoadingNextPage;

  const MoviesSliverList({
    super.key,
    required this.movies,
    this.isLoadingNextPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: isDesktop || isTablet
          ? _buildGrid(isDesktop ? 3 : 2)
          : _buildList(),
    );
  }

  Widget _buildList() {
    final totalCount = movies.length + (isLoadingNextPage ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= movies.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: AppLoadingIndicator(size: 28),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: MovieCard(movie: movies[index]),
          );
        },
        childCount: totalCount,
      ),
    );
  }

  Widget _buildGrid(int crossAxisCount) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 154,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return MovieCard(movie: movies[index]);
        },
        childCount: movies.length,
      ),
    );
  }
}
