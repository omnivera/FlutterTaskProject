import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'dart:io';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  final ApiService apiService = ApiService();
  late Box<Task> taskBox;
  late Timer _syncTimer;
  
  final unsyncedTasks = <Map<String, dynamic>>[];

  var filteredTasks = <Task>[].obs;
  var filterStatus = Rxn<bool>();
  var isSortedByTitle = false.obs;

  @override
  void onInit() async {
    await _initHive();
    await updateOldTasks(); // Eski görevlerin taskDate alanını güncelle
    await fetchTasks();
    _startSyncTimer();
    super.onInit();
    filteredTasks.assignAll(tasks);
    ever(tasks, (_) => applyFiltersAndSorting());
  }

  Future<void> _initHive() async {
    taskBox = await Hive.openBox<Task>('tasks');
    tasks.addAll(taskBox.values);
  }

  Future<void> updateOldTasks() async {
    for (var key in taskBox.keys) {
      var task = taskBox.get(key);
      if (task != null && task.taskDate == null) {
        task.taskDate = DateTime.now(); // Null olanları güncelle
        await taskBox.put(key, task);
      }
    }
  }

  Future<void> fetchTasks() async {
    try {
      if (await _isOnline()) {
        tasks.value = await apiService.fetchTasks();
        tasks.forEach((task) {
          if (task.taskDate == null) {
            task.taskDate = DateTime.now(); // Null kontrolü
          }
        });
        _syncLocalDatabase();
      } else {
        tasks.value = taskBox.values.toList();
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  void addTask(Task task) async {
    tasks.add(task); 
    int taskIndex = tasks.length - 1;

    if (await _isOnline()) {
      try {
        final createdTask = await apiService.addTask(task); // Sunucudan dönen yeni Task nesnesi
        tasks[taskIndex] = createdTask; // Listeyi günceller
        taskBox.put(createdTask.id, createdTask); // Hive'da günceller
      } catch (e) {
        unsyncedTasks.add({"task": task, "action": "add"});
      }
    } else {
      unsyncedTasks.add({"task": task, "action": "add"});
      taskBox.add(task); // Geçici olarak Hive'a kaydeder
    }
  }

  void updateTask(Task updatedTask) async {
    int index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await taskBox.put(updatedTask.id, updatedTask);

      if (await _isOnline()) {
        try {
          await apiService.updateTask(updatedTask);
        } catch (e) {
          unsyncedTasks.add({"task": updatedTask, "action": "update"});
        }
      } else {
        unsyncedTasks.add({"task": updatedTask, "action": "update"});
      }
    }
  }

  void deleteTask(String id) async {
    int index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      Task taskToDelete = tasks.removeAt(index);

      await taskBox.delete(taskToDelete.id); // Hive'dan siler

      if (await _isOnline()) {
        try {
          await apiService.deleteTask(id); // API'den siler
        } catch (e) {
          print("Sunucuda silme hatası: $e");
          unsyncedTasks.add({"task": taskToDelete, "action": "delete"});
        }
      } else {
        unsyncedTasks.add({"task": taskToDelete, "action": "delete"});
      }
    } else {
      print("Silinmek istenen görev bulunamadı.");
    }
  }

  Future<void> _syncLocalDatabase() async {
    taskBox.clear();
    for (var task in tasks) {
      taskBox.put(task.id, task);
    }
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (await _isOnline() && unsyncedTasks.isNotEmpty) {
        _syncUnsyncedTasks();
      }
    });
  }

  Future<void> _syncUnsyncedTasks() async {
    List<Map<String, dynamic>> syncedTasks = [];
    
    for (var taskData in List.from(unsyncedTasks)) {
      Task task = taskData["task"];
      String action = taskData["action"];

      try {
        if (action == "add") {
          final createdTask = await apiService.addTask(task);
          int index = tasks.indexWhere((t) => t == task);
          if (index != -1) {
            tasks[index] = createdTask;
            await taskBox.put(createdTask.id, createdTask);
          }
        } else if (action == "update") {
          await apiService.updateTask(task);
        } else if (action == "delete") {
          await apiService.deleteTask(task.id);
        }
        syncedTasks.add(taskData);
      } catch (e) {
        print("Sync error for task ${task.id} with action $action: $e");
      }
    }

    unsyncedTasks.removeWhere((taskData) => syncedTasks.contains(taskData));
  }

  @override
  void onClose() {
    _syncTimer.cancel();
    super.onClose();
  }

  var sortOrder = 0.obs; // 0: sıralama yok, 1: A-Z sıralama, 2: Z-A sıralama

  void applyFiltersAndSorting() {
    List<Task> tempTasks = List.from(tasks);

    // Filtreleme
    if (filterStatus.value != null) {
      tempTasks = tempTasks.where((task) => task.status == filterStatus.value).toList();
    }

    // Sıralama
    if (sortOrder.value == 1) {
      tempTasks.sort((a, b) => a.title.compareTo(b.title)); // A-Z sıralama
    } else if (sortOrder.value == 2) {
      tempTasks.sort((a, b) => b.title.compareTo(a.title)); // Z-A sıralama
    }

    // Filtrelenmiş ve sıralanmış listeyi güncelle
    filteredTasks.assignAll(tempTasks);
  }

  void toggleSortByTitle() {
    sortOrder.value = (sortOrder.value + 1) % 3;
    applyFiltersAndSorting();
  }

  void setFilterStatus(bool? status) {
    filterStatus.value = status;
    applyFiltersAndSorting();
  }
}