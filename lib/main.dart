import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'features/tasks/controllers/task_controller.dart';
import 'features/tasks/repositories/task_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = TaskController(TaskStorage());
  runApp(ChangeNotifierProvider.value(
    value: controller..load(),
    child: const FlowDeskApp(),
  ));
}
