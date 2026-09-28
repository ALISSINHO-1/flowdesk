enum TaskStatus { todo, inProgress, completed }

enum TaskPriority { low, medium, high }

enum DueDateFilter { all, overdue, withDate, withoutDate }

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'A fazer',
        TaskStatus.inProgress => 'Em andamento',
        TaskStatus.completed => 'Concluído',
      };
}

extension TaskPriorityLabel on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Baixa',
        TaskPriority.medium => 'Média',
        TaskPriority.high => 'Alta',
      };
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isOverdue([DateTime? now]) {
    if (dueDate == null || status == TaskStatus.completed) return false;
    final today = now ?? DateTime.now();
    return DateTime(dueDate!.year, dueDate!.month, dueDate!.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? updatedAt,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, Object?> json) => Task(
        id: json['id']! as String,
        title: json['title']! as String,
        description: json['description'] as String? ?? '',
        status: TaskStatus.values.byName(json['status']! as String),
        priority: TaskPriority.values.byName(json['priority']! as String),
        dueDate: json['dueDate'] == null
            ? null
            : DateTime.parse(json['dueDate']! as String),
        createdAt: DateTime.parse(json['createdAt']! as String),
        updatedAt: DateTime.parse(json['updatedAt']! as String),
      );
}
