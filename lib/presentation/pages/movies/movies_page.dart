import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/infrastructure/di/injection.dart';
import 'package:flutter_template/presentation/pages/movies/widgets/movies_skeleton_loader.dart';
import 'package:flutter_template/presentation/pages/movies/widgets/movies_sliver_app_bar.dart';
import 'package:flutter_template/presentation/pages/movies/widgets/movies_sliver_list.dart';
import 'package:flutter_template/presentation/state_management/movies/movies_bloc.dart';
import 'package:flutter_template/presentation/ui_kit/adaptive_container.dart';
import 'package:flutter_template/presentation/ui_kit/app_error_view.dart';

@RoutePage()
class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MoviesBloc>()..add(const MoviesStarted()),
      child: const _MoviesPageView(),
    );
  }
}

class _MoviesPageView extends StatelessWidget {
  const _MoviesPageView();

  bool _onScrollNotification(
    BuildContext context,
    ScrollNotification notification,
  ) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.maxScrollExtent - metrics.pixels <= 300) {
        context.read<MoviesBloc>().add(const MoviesNextPageLoaded());
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) =>
            _onScrollNotification(context, notification),
        child: RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<MoviesBloc>();
            bloc.add(const MoviesRefreshed());
            await bloc.stream.firstWhere((s) => s is! MoviesLoading);
          },
          child: AdaptiveContainer(
            maxWidth: 1200,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const MoviesSliverAppBar(),
                BlocBuilder<MoviesBloc, MoviesState>(
                  builder: (context, state) {
                    return switch (state) {
                      MoviesInitial() ||
                      MoviesLoading() =>
                        const MoviesSkeletonLoader(),
                      MoviesError(:final message) => SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppErrorView(
                            message: message,
                            onRetry: () => context
                                .read<MoviesBloc>()
                                .add(const MoviesStarted()),
                          ),
                        ),
                      MoviesLoaded(
                        :final movies,
                        :final isLoadingNextPage,
                      ) =>
                        MoviesSliverList(
                          movies: movies,
                          isLoadingNextPage: isLoadingNextPage,
                        ),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
