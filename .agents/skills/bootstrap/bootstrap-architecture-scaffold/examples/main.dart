import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_template/application.dart';
import 'package:flutter_template/infrastructure/di/injectable.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Hydrated Bloc storage
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
      );

      // Initialize Dependency Injection
      await configureDependencies();

      runApp(const Application());
    },
    (error, stackTrace) {
      // Global error reporting / logging
      debugPrint('Unhandled error: $error\n$stackTrace');
    },
  );
}
