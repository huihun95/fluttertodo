import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/TaskModel.dart';

// Task Provider
class TaskNotifier extends StateNotifier<List<TaskModel>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    final tasks = tasksJson
        .map((json) => TaskModel.fromJson(jsonDecode(json)))
        .toList();
    state = tasks;
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = state.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void addTask(TaskModel task) {
    state = [...state, task];
    _saveTasks();
  }

  void completeTask(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: 'completed');
      }
      return task;
    }).toList();
    _saveTasks();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    _saveTasks();
  }

  void editTask(TaskModel updatedTask) {
    state = state.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      }
      return task;
    }).toList();
    _saveTasks();
  }

  List<TaskModel> getTodayTasks() {
    final today = DateTime.now();
    return state.where((task) {
      return task.deadline.year == today.year &&
          task.deadline.month == today.month &&
          task.deadline.day == today.day &&
          task.status != 'completed';
    }).toList();
  }

  List<TaskModel> getAllTasks() {
    return state.where((task) => task.status != 'completed').toList();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  return TaskNotifier();
});
