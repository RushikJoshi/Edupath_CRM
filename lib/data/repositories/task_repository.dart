import '../api/task_api.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository(this._api);

  final TaskApi _api;

  Future<List<TaskModel>> fetchAll({
    String? leadId,
    int page = 1,
    int limit = 10,
  }) => _api.getTasks(leadId: leadId, page: page, limit: limit);

  Future<TaskModel> create({
    required String title,
    required String description,
    required String priority,
    required String dueDate,
    String? leadId,
    String? dealId,
    String? customerId,
    String? assignedTo,
    String status = 'Pending',
  }) => _api.createTask(
    title: title,
    description: description,
    priority: priority,
    dueDate: dueDate,
    leadId: leadId,
    dealId: dealId,
    customerId: customerId,
    assignedTo: assignedTo,
    status: status,
  );

  Future<TaskModel> updateStatus({
    required String taskId,
    required String status,
  }) => _api.updateTask(taskId: taskId, status: status);
}
