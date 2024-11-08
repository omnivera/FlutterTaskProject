import 'package:flutter/material.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final TaskController controller = Get.find();

  TaskCard({required this.task, required this.onEdit, required this.onDelete});

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Slidable(
          key: ValueKey(task.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) => onDelete(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Sil',
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(0), 
              bottomRight: Radius.circular(0), 
            ),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              elevation: 2,
              child: ListTile(
                leading: Checkbox(
                  value: task.status,
                  onChanged: (value) {
                    if (value != null) {
                      final updatedTask = Task(
                        id: task.id,
                        title: task.title,
                        description: task.description,
                        status: value,
                        taskDate: task.taskDate,
                      );
                      controller.updateTask(updatedTask);
                    }
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.status ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.description,
                      style: TextStyle(
                        decoration: task.status ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('Tarih: ${formatDate(task.taskDate)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}