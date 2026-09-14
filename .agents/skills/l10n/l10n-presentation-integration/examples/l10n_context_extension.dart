import 'package:flutter/material.dart';
import 'package:flutter_template/l10n/generated/l10n.dart';

extension BuildContextLocalizationX on BuildContext {
  /// Shorthand accessor for generated localization strings
  S get localization => S.of(this);
}
