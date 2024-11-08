import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'controllers/task_controller.dart';
import 'models/task.dart';
import 'views/home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Arka planda gelen mesajları işle
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp();

  // Firebase Messaging için arka plan mesaj işleyicisini ayarla
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Hive başlatma işlemleri
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());  // Task modelini kaydediyoruz
  await Hive.openBox<Task>('tasks');    // Görevler için bir Hive kutusu açıyoruz

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Görev Yönetim Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}