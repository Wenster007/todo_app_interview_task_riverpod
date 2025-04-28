import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_item.dart';
import 'todo_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(todoProvider.notifier).loadTodos());
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: todoState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : todoState.todos.isEmpty
          ? const Center(child: Text('No todos yet. Add one!'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todoState.todos.length,
        itemBuilder: (context, index) {
          final todo = todoState.todos[index];
          return TodoListItem(
            todo: todo,
            onToggle: () {
              ref.read(todoProvider.notifier).toggleTodoCompletion(todo);
            },
            onDelete: () {
              ref.read(todoProvider.notifier).deleteTodoItem(todo.id);
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoFormScreen(todo: todo),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TodoFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}