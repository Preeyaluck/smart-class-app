import 'package:flutter/material.dart';
import 'app.dart';
import 'services/attendance_storage_service.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AttendanceStorageService.instance.initialize();
    await AuthService.instance.initialize();
  } catch (e, stackTrace) {
    debugPrint('Database initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
  runApp(const SmartClassApp());
}
