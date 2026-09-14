import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

// --- State Layer (Pure Dart, Zero Flutter SDK imports) ---

enum AppThemeMode {
  system,
  light,
  dark,
}

final class ThemeState extends Equatable {
  final AppThemeMode themeMode;

  const ThemeState({this.themeMode = AppThemeMode.system});

  ThemeState copyWith({AppThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}

// --- Mixin Layer (Serialization Separation) ---

mixin HydratedThemeCubitMixin on HydratedMixin<ThemeState> {
  @override
  String get storagePrefix => 'ThemeCubit';

  @override
  ThemeState fromJson(Map<String, dynamic> json) {
    try {
      final index = json['themeModeIndex'] as int?;
      return ThemeState(
        themeMode: index != null ? AppThemeMode.values[index] : AppThemeMode.system,
      );
    } catch (_) {
      return const ThemeState(themeMode: AppThemeMode.system);
    }
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return {'themeModeIndex': state.themeMode.index};
  }
}

// --- Cubit Layer ---

@lazySingleton
class ThemeCubit extends HydratedCubit<ThemeState> with HydratedThemeCubitMixin {
  ThemeCubit() : super(const ThemeState());

  void setThemeMode(AppThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void toggleTheme() {
    final next = switch (state.themeMode) {
      AppThemeMode.system || AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.light,
    };
    emit(state.copyWith(themeMode: next));
  }
}

// --- Presentation Mapping Extension ---

extension AppThemeModeX on AppThemeMode {
  ThemeMode toFlutter() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
