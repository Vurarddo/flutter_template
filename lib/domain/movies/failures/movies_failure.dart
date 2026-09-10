sealed class MoviesFailure {
  final String message;

  const MoviesFailure([this.message = 'An unexpected error occurred.']);
}

final class NetworkMoviesFailure extends MoviesFailure {
  const NetworkMoviesFailure([
    super.message = 'No internet connection or network request timed out.',
  ]);
}

final class UnauthorizedMoviesFailure extends MoviesFailure {
  const UnauthorizedMoviesFailure([
    super.message = 'Unauthorized. Please check your API Read Access Token.',
  ]);
}

final class ServerMoviesFailure extends MoviesFailure {
  final int? statusCode;

  const ServerMoviesFailure({
    String message = 'A server error occurred while processing the request.',
    this.statusCode,
  }) : super(message);
}

final class NotFoundMoviesFailure extends MoviesFailure {
  const NotFoundMoviesFailure([
    super.message = 'Requested movies resource was not found.',
  ]);
}

final class UnknownMoviesFailure extends MoviesFailure {
  final Object? error;
  final StackTrace? stackTrace;

  const UnknownMoviesFailure({
    String message = 'An unexpected error occurred.',
    this.error,
    this.stackTrace,
  }) : super(message);
}
