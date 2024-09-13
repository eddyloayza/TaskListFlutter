import 'package:flutter/material.dart';
import 'package:lista_tareas/app/model/task.dart';
import 'package:lista_tareas/app/repository/task_repository.dart';
import 'package:lista_tareas/view/components/h1.dart';
import 'package:lista_tareas/view/components/shape.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskRepository taskRepository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: taskRepository.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay tareas'),
                  );
                }
                return _TaskList(
                  snapshot.data!,
                  onTaskDoneChange: (task) {
                    task.done = !task.done;
                    taskRepository.saveTasks(snapshot.data!);
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTaskModal(context),
        child: const Icon(Icons.add, size: 50),
      ),
    );
  }

  void _showNewTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NewTaskModal(
        onTaskCreated: (Task task) {
          taskRepository.addTask(task);
          setState(() {});
        },
      ),
    );
  }
}

class _NewTaskModal extends StatelessWidget {
  _NewTaskModal({required this.onTaskCreated});
  final _controller = TextEditingController();
  final void Function(Task task) onTaskCreated;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
            horizontal: 33,
            vertical: 23,
          ) +
          MediaQuery.of(context).viewInsets,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const H1('Nueva Tarea'),
          const SizedBox(
            height: 26,
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hintText: 'Descripción de la tarea',
            ),
          ),
          const SizedBox(
            height: 26,
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                final task = Task(_controller.text);
                onTaskCreated(task);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList(this.taskList, {required this.onTaskDoneChange});

  final List<Task> taskList;
  final void Function(Task task) onTaskDoneChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const H1('Tareas'),
          Expanded(
            child: ListView.separated(
              itemCount: taskList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) => _TaskItem(
                taskList[index],
                onTap: () => onTaskDoneChange(taskList[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Row(
            children: [Shape()],
          ),
          Column(
            children: [
              const SizedBox(
                height: 107,
              ),
              Image.asset(
                'assets/images/tasks-list-image.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              const H1('Completa tus tareas', color: Colors.white),
              const SizedBox(height: 24),
            ],
          )
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem(this.task, {this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 21,
            vertical: 18,
          ),
          child: Row(
            children: [
              Icon(
                task.done
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(task.title),
            ],
          ),
        ),
      ),
    );
  }
}
