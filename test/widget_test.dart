import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowdesk/features/tasks/controllers/task_controller.dart';
import 'package:flowdesk/features/tasks/repositories/task_storage.dart';
import 'package:flowdesk/features/tasks/widgets/task_form_dialog.dart';

void main() {
  testWidgets('formulário da tarefa exige título', (tester) async {
    final controller = TaskController(TaskStorage());
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) => TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => TaskFormDialog(controller: controller),
          ),
          child: const Text('Abrir'),
        )),
      ),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar tarefa'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um título.'), findsOneWidget);
    controller.dispose();
  });
}
