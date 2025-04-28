import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_job_test/model/todo.dart';
import 'package:todo_list_job_test/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

// Todo state
class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? errorMessage;

  TodoState({
    required this.todos,
    required this.isLoading,
    this.errorMessage,
  });

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Todo notifier
class TodoNotifier extends StateNotifier<TodoState> {
  final ITodoRepository _repository;
  final Uuid _uuid = const Uuid();

  TodoNotifier(this._repository) : super(TodoState(todos: [], isLoading: false));

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final todos = await _repository.getTodos();
      state = state.copyWith(
        todos: todos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createTodo({required String title, required String description}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final newTodo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    try {
      final todo = await _repository.addTodo(newTodo);
      final updatedTodos = [...state.todos, todo];
      state = state.copyWith(
        todos: updatedTodos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);

    try {
      final updated = await _repository.updateTodo(updatedTodo);
      final updatedTodos = state.todos.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      state = state.copyWith(todos: updatedTodos);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateTodoItem(Todo todo) async {
    try {
      final updated = await _repository.updateTodo(todo);
      final updatedTodos = state.todos.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      state = state.copyWith(todos: updatedTodos);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteTodoItem(String id) async {
    try {
      final success = await _repository.deleteTodo(id);
      if (success) {
        final updatedTodos = state.todos.where((todo) => todo.id != id).toList();
        state = state.copyWith(todos: updatedTodos);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

//provider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoNotifier(repository);
});