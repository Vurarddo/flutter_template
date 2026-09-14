import 'package:flutter/material.dart';

import 'package:flutter_template/application.dart';
import 'package:flutter_template/infrastructure/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const Application());
}
