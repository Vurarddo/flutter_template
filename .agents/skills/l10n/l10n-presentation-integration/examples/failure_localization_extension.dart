import 'package:flutter/material.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'l10n_context_extension.dart';

extension DomainFailureLocalizationX on DomainFailure {
  String toLocalizedString(BuildContext context) {
    return switch (this) {
      NetworkFailure() => context.localization.errorNoInternet,
      UnauthorizedFailure() => context.localization.errorSessionExpired,
      NotFoundFailure() => context.localization.errorResourceNotFound,
      ServerFailure() => context.localization.errorGenericServer,
      TimeoutFailure() => context.localization.errorConnectionTimeout,
      UnknownFailure() => context.localization.errorUnknown,
    };
  }
}
