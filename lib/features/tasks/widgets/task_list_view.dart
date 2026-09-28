import 'package:flutter/material.dart';

import '../models/task.dart';
import '../controllers/task_controller.dart';
import 'task_card.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.controller,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final TaskController controller;
  final VoidCallback onAdd;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.filteredTasks;
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Organize suas tarefas em um só lugar.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: controller.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar por título ou descrição',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              _FilterControls(controller: controller),
              const SizedBox(height: 20),
              if (tasks.isEmpty)
                controller.tasks.isEmpty
                    ? TaskEmptyState(onAdd: onAdd)
                    : const _NoResults()
              else
                ...tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskCard(
                      task: task,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onStatus: controller.setStatus,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterControls extends StatelessWidget {
  const _FilterControls({required this.controller});
  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _FilterDropdown<TaskStatus?>(
          label: 'Status',
          value: controller.statusFilter,
          options: [null, ...TaskStatus.values],
          labelFor: (value) => value?.label ?? 'Todos',
          onChanged: controller.setStatusFilter,
        ),
        _FilterDropdown<TaskPriority?>(
          label: 'Prioridade',
          value: controller.priorityFilter,
          options: [null, ...TaskPriority.values],
          labelFor: (value) => value?.label ?? 'Todas',
          onChanged: controller.setPriorityFilter,
        ),
        _FilterDropdown<DueDateFilter>(
          label: 'Prazo',
          value: controller.dueDateFilter,
          options: DueDateFilter.values,
          labelFor: (value) => switch (value) {
            DueDateFilter.all => 'Todos',
            DueDateFilter.overdue => 'Vencidos',
            DueDateFilter.withDate => 'Com prazo',
            DueDateFilter.withoutDate => 'Sem prazo',
          },
          onChanged: controller.setDueDateFilter,
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.labelFor,
    required this.onChanged,
  });
  final String label;
  final T value;
  final List<T> options;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<T>(
    value: value,
    underline: const SizedBox.shrink(),
    borderRadius: BorderRadius.circular(12),
    items: options
        .map(
          (item) => DropdownMenuItem(
            value: item,
            child: Text('$label: ${labelFor(item)}'),
          ),
        )
        .toList(),
    onChanged: (item) {
      if (item != null) onChanged(item);
    },
  );
}

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({super.key, required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Card(
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
        child: Column(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Você ainda não possui tarefas.',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              'Crie a primeira para começar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Criar primeira tarefa'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NoResults extends StatelessWidget {
  const _NoResults();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Text('Nenhuma tarefa encontrada. Ajuste a busca ou os filtros.'),
      ),
    ),
  );
}
