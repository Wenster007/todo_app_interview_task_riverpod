import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_job_test/model/todo.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provider for TodoRepository
final todoRepositoryProvider = Provider<ITodoRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TodoRepository(prefs);
});


// Abstract class following Interface Segregation Principle
abstract class ITodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(Todo todo);
  Future<Todo> updateTodo(Todo todo);
  Future<bool> deleteTodo(String id);
}

// Concrete implementation of the repository
class TodoRepository implements ITodoRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'todos';

  TodoRepository(this._prefs);

  @override
  Future<List<Todo>> getTodos() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Todo> addTodo(Todo todo) async {
    final todos = await getTodos();
    todos.add(todo);
    await _saveTodos(todos);
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo updatedTodo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);

    if (index >= 0) {
      todos[index] = updatedTodo;
      await _saveTodos(todos);
      return updatedTodo;
    } else {
      throw Exception('Todo not found');
    }
  }

  @override
  Future<bool> deleteTodo(String id) async {
    final todos = await getTodos();
    final initialLength = todos.length;
    todos.removeWhere((todo) => todo.id == id);

    if (initialLength != todos.length) {
      await _saveTodos(todos);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    final jsonList = todos.map((todo) => todo.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_storageKey, jsonString);
  }
}

