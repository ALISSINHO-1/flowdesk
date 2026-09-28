import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatus,
  });
  final Task task;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onDelete;
  final Future<void> Function(Task, TaskStatus) onStatus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overdue = task.isOverdue();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(task.title),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty) Text(task.description),
                  const SizedBox(height: 16),
                  Text('Status: ${task.status.label}'),
                  Text('Prioridade: ${task.priority.label}'),
                  Text(
                    'Prazo: ${task.dueDate == null ? 'Sem prazo' : _dateLabel(task.dueDate!)}',
                  ),
                  Text('Criada em: ${_dateLabel(task.createdAt)}'),
                  Text('Atualizada em: ${_dateLabel(task.updatedAt)}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  task.status == TaskStatus.completed
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 19,
                  color: task.status == TaskStatus.completed
                      ? _tone(context, const Color(0xFF31956B))
                      : colors.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        TaskTag(
                          label: task.status.label,
                          color: _statusColor(context, task.status),
                        ),
                        TaskTag(
                          label: task.priority.label,
                          color: _priorityColor(context, task.priority),
                        ),
                        if (overdue)
                          TaskTag(
                            label: 'Atrasada',
                            color: _tone(context, const Color(0xFFC65D5D)),
                          ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: overdue
                                ? _tone(context, const Color(0xFFC65D5D))
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Prazo ${_dateLabel(task.dueDate!)}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: overdue
                                      ? _tone(context, const Color(0xFFC65D5D))
                                      : colors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ações da tarefa',
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit(task);
                      break;
                    case 'delete':
                      onDelete(task);
                      break;
                    case 'status':
                      final next = switch (task.status) {
                        TaskStatus.todo => TaskStatus.inProgress,
                        TaskStatus.inProgress => TaskStatus.completed,
                        TaskStatus.completed => TaskStatus.todo,
                      };
                      onStatus(task, next);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'status',
                    child: Text('Avançar status'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskTag extends StatelessWidget {
  const TaskTag({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: color, fontWeight: FontWeight.w700),
    ),
  );
}

Color _statusColor(BuildContext context, TaskStatus status) =>
    _tone(context, switch (status) {
      TaskStatus.todo => const Color(0xFF687386),
      TaskStatus.inProgress => const Color(0xFFC38316),
      TaskStatus.completed => const Color(0xFF31956B),
    });

Color _priorityColor(BuildContext context, TaskPriority priority) =>
    _tone(context, switch (priority) {
      TaskPriority.low => const Color(0xFF4F8C72),
      TaskPriority.medium => const Color(0xFF6676A0),
      TaskPriority.high => const Color(0xFFB15D5D),
    });

Color _tone(BuildContext context, Color color) => Color.lerp(
  color,
  Colors.white,
  Theme.of(context).brightness == Brightness.dark ? 0.48 : 0,
)!;

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
