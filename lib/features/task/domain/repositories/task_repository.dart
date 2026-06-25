import 'package:gtcrm/features/task/data/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> fetchAll({String? leadId, int? page, int? limit});

  Future<TaskModel> create({
    required String title,
    String? description,
    String? priority,
    String? dueDate,
    String? leadId,
    String? dealId,
    String? customerId,
    String? assignedTo,
    String? status,
  });

  Future<TaskModel> updateTask(String id, Map<String, dynamic> body);

  Future<void> deleteTask(String id);

  Future<TaskModel> updateStatus({
    required String taskId,
    required String status,
  });
}
