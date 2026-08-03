import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies({String? environment}) async {
  const defaultEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: Environment.dev,
  );
  await getIt.init(environment: environment ?? defaultEnv);
}

