import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../controllers/task_controller.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  final TaskController controller = Get.put(TaskController());
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() async {
    await controller.fetchTasks();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Yönetim Uygulaması'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: () => controller.toggleSortByTitle(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearch<String>(
              items: ["Tüm Görevler", "Tamamlanmış Görevler", "Tamamlanmamış Görevler"],
              selectedItem: "Tüm Görevler",
              onChanged: (value) {
                if (value == "Tüm Görevler") {
                  controller.setFilterStatus(null);
                } else if (value == "Tamamlanmış Görevler") {
                  controller.setFilterStatus(true);
                } else if (value == "Tamamlanmamış Görevler") {
                  controller.setFilterStatus(false);
                }
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Görev Durumu Filtrele",
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Ara...",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[250],
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none, // Çerçeveyi kaldır
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() => SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    itemCount: controller.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onEdit: () {
                          Get.to(() => EditTaskScreen(task: task));
                        },
                        onDelete: () {
                          controller.deleteTask(task.id);
                        },
                      );
                    },
                  ),
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddTaskScreen()),
        child: Icon(Icons.add),
      ),
    );
  }
}