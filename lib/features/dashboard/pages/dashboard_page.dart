import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tasks/controllers/task_controller.dart';
import '../../tasks/models/task.dart';
import '../../tasks/widgets/task_card.dart';
import '../../tasks/widgets/task_form_dialog.dart';
import '../../tasks/widgets/task_list_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _section = 0;

  Future<void> _openForm(TaskController controller, [Task? task]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => TaskFormDialog(controller: controller, task: task),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(task == null ? 'Tarefa criada.' : 'Tarefa atualizada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _delete(TaskController controller, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Excluir tarefa?'),
        content: Text('“${task.title}” será removida permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteTask(task);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa excluída.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              if (wide)
                _DesktopSidebar(
                  section: _section,
                  onSelect: (value) => setState(() => _section = value),
                  darkMode: controller.isDarkMode,
                  onTheme: controller.toggleTheme,
                ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      wide: wide,
                      section: _section,
                      darkMode: controller.isDarkMode,
                      onTheme: controller.toggleTheme,
                      onAdd: () => _openForm(controller),
                    ),
                    Expanded(
                      child: _section == 0
                          ? _DashboardContent(
                              controller: controller,
                              onTasks: () => setState(() => _section = 1),
                              onAdd: () => _openForm(controller),
                              onEdit: (task) => _openForm(controller, task),
                              onDelete: (task) => _delete(controller, task),
                            )
                          : TaskListView(
                              controller: controller,
                              onAdd: () => _openForm(controller),
                              onEdit: (task) => _openForm(controller, task),
                              onDelete: (task) => _delete(controller, task),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _section,
                  onDestinationSelected: (value) =>
                      setState(() => _section = value),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.space_dashboard_outlined),
                      selectedIcon: Icon(Icons.space_dashboard),
                      label: 'Visão geral',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.checklist_outlined),
                      selectedIcon: Icon(Icons.checklist),
                      label: 'Tarefas',
                    ),
                  ],
                ),
          floatingActionButton: wide
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova tarefa'),
                ),
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.section,
    required this.onSelect,
    required this.darkMode,
    required this.onTheme,
  });

  final int section;
  final ValueChanged<int> onSelect;
  final bool darkMode;
  final VoidCallback onTheme;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(20, 28, 16, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.done_all_rounded, color: Colors.white),
              ),
              const SizedBox(width: 11),
              Text(
                'FlowDesk',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 42),
          _NavItem(
            icon: Icons.space_dashboard_outlined,
            label: 'Visão geral',
            selected: section == 0,
            onTap: () => onSelect(0),
          ),
          const SizedBox(height: 6),
          _NavItem(
            icon: Icons.checklist_rounded,
            label: 'Tarefas',
            selected: section == 1,
            onTap: () => onSelect(1),
          ),
          const Spacer(),
          ListTile(
            leading: Icon(
              darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            title: Text(darkMode ? 'Tema claro' : 'Tema escuro'),
            onTap: onTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? colors.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedTileColor: colors.primary.withValues(alpha: .09),
      selectedColor: colors.primary,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.wide,
    required this.section,
    required this.darkMode,
    required this.onTheme,
    required this.onAdd,
  });
  final bool wide;
  final int section;
  final bool darkMode;
  final VoidCallback onTheme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final title = section == 0 ? 'Visão geral' : 'Tarefas';
    return Container(
      height: 82,
      padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!wide) ...[
            const Icon(Icons.done_all_rounded, color: Color(0xFF356AE6)),
            const SizedBox(width: 9),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            tooltip: darkMode ? 'Usar tema claro' : 'Usar tema escuro',
            onPressed: onTheme,
            icon: Icon(
              darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.controller,
    required this.onTasks,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final TaskController controller;
  final VoidCallback onTasks;
  final VoidCallback onAdd;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acompanhe seu trabalho',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Uma visão clara do que precisa ser feito.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 850
                      ? 5
                      : constraints.maxWidth > 560
                      ? 3
                      : 2;
                  final items = [
                    _SummaryData(
                      'Total',
                      controller.tasks.length,
                      Icons.list_alt_rounded,
                      const Color(0xFF356AE6),
                    ),
                    _SummaryData(
                      'A fazer',
                      controller.countFor(TaskStatus.todo),
                      Icons.radio_button_unchecked,
                      const Color(0xFF6B7280),
                    ),
                    _SummaryData(
                      'Em andamento',
                      controller.countFor(TaskStatus.inProgress),
                      Icons.timelapse_rounded,
                      const Color(0xFFE39B22),
                    ),
                    _SummaryData(
                      'Concluídas',
                      controller.countFor(TaskStatus.completed),
                      Icons.check_circle_outline,
                      const Color(0xFF31956B),
                    ),
                    _SummaryData(
                      'Atrasadas',
                      controller.overdueCount,
                      Icons.schedule_rounded,
                      const Color(0xFFC65D5D),
                    ),
                  ];
                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: constraints.maxWidth < 560 ? 1.55 : 1.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: items
                        .map((item) => _SummaryCard(data: item))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tarefas recentes',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: onTasks,
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.tasks.isEmpty)
                TaskEmptyState(onAdd: onAdd)
              else
                ...controller.tasks.reversed
                    .take(4)
                    .map(
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

class _SummaryData {
  const _SummaryData(this.label, this.value, this.icon, this.color);
  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});
  final _SummaryData data;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = Color.lerp(data.color, Colors.white, dark ? 0.38 : 0)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 18, color: iconColor),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${data.value}',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
