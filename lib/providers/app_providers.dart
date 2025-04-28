import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_job_test/providers/todo_provider.dart';
import 'package:todo_list_job_test/repositories/todo_repository.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provider for TodoRepository
final todoRepositoryProvider = Provider<ITodoRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TodoRepository(prefs);
});

//provider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoNotifier(repository);
});