import 'package:gtcrm/features/task/data/models/task_model.dart';

abstract class TaskRepositoryInterface {
  Future<List<TaskModel>> getTasks({String? search});
  Future<TaskModel> createTask(Map<String, dynamic> body);
  Future<TaskModel> updateTask(String id, Map<String, dynamic> body);
  Future<void> deleteTask(String id);
}
