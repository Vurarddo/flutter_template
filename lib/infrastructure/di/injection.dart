import 'package:flutter_template/infrastructure/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies({String? environment}) async {
  const defaultEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: Environment.dev,
  );
  await getIt.init(environment: environment ?? defaultEnv);
}
