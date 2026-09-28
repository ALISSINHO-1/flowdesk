import 'package:flutter_test/flutter_test.dart';
import 'package:flowdesk/features/tasks/controllers/task_controller.dart';
import 'package:flowdesk/features/tasks/models/task.dart';
import 'package:flowdesk/features/tasks/repositories/task_storage.dart';

class _MemoryStorage extends TaskStorage {
  List<Task> saved = [];

  @override
  Future<List<Task>> loadTasks() async => List.of(saved);

  @override
  Future<void> saveTasks(List<Task> tasks) async => saved = List.of(tasks);

  @override
  Future<bool> loadDarkMode() async => false;

  @override
  Future<void> saveDarkMode(bool value) async {}
}

void main() {
  final createdAt = DateTime(2026, 5, 10, 12);
  final sample = Task(
    id: 'task-1',
    title: 'Preparar apresentação',
    description: 'Revisar os slides',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    dueDate: DateTime(2026, 5, 15),
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  test('Task serializa e restaura todos os campos', () {
    expect(Task.fromJson(sample.toJson()).toJson(), sample.toJson());
  });

  test('copyWith preserva identidade e permite remover prazo', () {
    final updated = sample.copyWith(
      title: 'Apresentação revisada',
      clearDueDate: true,
    );
    expect(updated.id, sample.id);
    expect(updated.createdAt, sample.createdAt);
    expect(updated.title, 'Apresentação revisada');
    expect(updated.dueDate, isNull);
  });

  test('tarefa atrasada ignora horário e tarefas concluídas', () {
    final yesterday = DateTime(2026, 5, 9, 23, 59);
    expect(sample.copyWith(dueDate: yesterday).isOverdue(DateTime(2026, 5, 10)), isTrue);
    expect(
      sample.copyWith(status: TaskStatus.completed, dueDate: yesterday)
          .isOverdue(DateTime(2026, 5, 10)),
      isFalse,
    );
  });

  test('controller cria, edita, exclui e combina busca e filtros', () async {
    final storage = _MemoryStorage();
    final controller = TaskController(storage);
    await controller.load();
    await controller.addTask(
      title: '  Escrever relatório  ',
      description: 'Projeto FlowDesk',
      priority: TaskPriority.high,
      dueDate: null,
    );
    await controller.addTask(
      title: 'Planejar reunião',
      description: '',
      priority: TaskPriority.low,
      dueDate: null,
    );
    expect(controller.tasks.first.title, 'Escrever relatório');
    final task = controller.tasks.first;
    await controller.updateTask(
      task,
      title: 'Revisar relatório',
      description: 'Projeto FlowDesk',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: null,
    );
    controller.setSearch('FLOWdesk');
    controller.setStatusFilter(TaskStatus.inProgress);
    controller.setPriorityFilter(TaskPriority.high);
    expect(controller.filteredTasks.map((item) => item.title), ['Revisar relatório']);
    expect(controller.countFor(TaskStatus.inProgress), 1);
    await controller.deleteTask(controller.tasks.first);
    expect(controller.tasks, hasLength(1));
    expect(storage.saved, hasLength(1));
    controller.dispose();
  });
}
