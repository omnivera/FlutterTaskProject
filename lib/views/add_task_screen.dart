import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskController controller = Get.find();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime taskDate = DateTime.now(); // Başlangıç tarihi

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: taskDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != taskDate) {
      setState(() {
        taskDate = pickedDate;
      });
    }
  }

  Future<void> _sendNotificationToFirebase(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('https://flutterminiproject-cccfe.cloudfunctions.net/scheduleNotification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task.title,
          'body': 'Görev zamanı geldi: ${task.title}',
          'scheduledTime': task.taskDate.toIso8601String(),
          'token': await FirebaseMessaging.instance.getToken(), // Cihaz token'ı
        }),
      );

      if (response.statusCode == 200) {
        print('Bildirim başarıyla planlandı.');
      } else {
        print('Sunucu hatası: ${response.body}');
      }
    } catch (e) {
      print('Sunucuya bildirim talebi gönderilemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Görev Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Görev Başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Görev Açıklaması',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Görev Tarihi: ",
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(DateFormat('dd/MM/yyyy').format(taskDate)),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                  Get.snackbar(
                    "Uyarı",
                    "Başlık ve açıklama doldurulmalıdır.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                final task = Task(
                  id: '', 
                  title: titleController.text,
                  description: descriptionController.text,
                  status: false,
                  taskDate: taskDate, // Eklenen tarih
                );

                controller.addTask(task);
                await _sendNotificationToFirebase(task); // Bildirimi planla
                Get.back();
              },
              child: Text(
                'Ekle',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green, // Yeşil buton rengi
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}