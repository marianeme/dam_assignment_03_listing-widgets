import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/dependencies.dart';

Future<void> main() async {
  await AppDependencies.initialize();
  runApp(const App());
}
