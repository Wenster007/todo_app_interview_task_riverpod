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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: const _TodoBody(),
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


class _TodoBody extends ConsumerWidget {
  const _TodoBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final todos = ref.watch(todoProvider.select((state) => state.todos));
    final isLoading = ref.watch(todoProvider.select((state) => state.isLoading));

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todos.isEmpty) {
      return const Center(child: Text('No todos yet. Add one!'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
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
    );
  }
}