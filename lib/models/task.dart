import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool status;

  @HiveField(4)
  DateTime taskDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.taskDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '', // Null kontrolü
      title: json['title'] ?? 'No Title', // Null kontrolü
      description: json['description'] ?? 'No Description', // Null kontrolü
      status: json['status'] == 'true' || json['status'] == true, // Hem String hem de bool kontrolü
      taskDate: json['taskDate'] != null ? DateTime.parse(json['taskDate']) : DateTime.now(), // Null kontrolü
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'taskDate': taskDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, status: $status, taskDate: $taskDate)';
  }
}