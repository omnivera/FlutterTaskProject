import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TaskController controller = Get.find();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late bool status;
  late DateTime taskDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    status = widget.task.status;
    taskDate = widget.task.taskDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Görev Güncelle')),
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
                Text("Görev Durumu: ", style: TextStyle(fontSize: 16)),
                Spacer(),
                Switch(
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                Text(status ? "Yapıldı" : "Yapılmadı"),
              ],
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
              onPressed: () {
                final updatedTask = Task(
                  id: widget.task.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  status: status,
                  taskDate: taskDate, // Güncellenen tarih
                );
                controller.updateTask(updatedTask);
                Get.back();
              },
              child: Text(
                'Güncelle',
                style: TextStyle(color: Colors.white), // Yazı rengi beyaz
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green, // Buton rengi yeşil
              ),
            ),
          ],
        ),
      ),
    );
  }
}