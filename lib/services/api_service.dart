import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  final String baseUrl = 'https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Görevler yüklenemedi');
    }
  }

  Future<Task> addTask(Task task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 201) {
      // Sunucudan dönen yanıtı kullanarak `Task` nesnesini oluşturuyoruz
      final data = json.decode(response.body);
      return Task.fromJson(data); // Dönen `Task` nesnesi
    } else {
      throw Exception('Görev eklenemedi');
    }
  }

  Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${task.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": task.title,
        "description": task.description,
        "status": task.status.toString(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Görev güncellenemedi');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Görev silinemedi');
    }
  }
}