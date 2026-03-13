import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyStudentId = 'auth_student_id';
  static const String _keyStudentName = 'auth_student_name';
  static const String _keyDepartment = 'auth_department';
  static const String _keyFaculty = 'auth_faculty';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  String get studentId => _prefs?.getString(_keyStudentId) ?? '';
  String get studentName => _prefs?.getString(_keyStudentName) ?? '';
  String get department => _prefs?.getString(_keyDepartment) ?? '';
  String get faculty => _prefs?.getString(_keyFaculty) ?? '';

  /// Demo login: any non-empty student ID + password "1234"
  Future<String?> login({
    required String studentId,
    required String password,
  }) async {
    try {
      await initialize();

      final String trimmedId = studentId.trim();
      if (trimmedId.isEmpty) return 'กรุณากรอกรหัสนักศึกษา';
      if (password != '1234') return 'รหัสผ่านไม่ถูกต้อง (Demo: 1234)';

      await _prefs!.setString(_keyStudentName, _resolveStudentName(trimmedId));
      await _prefs!.setString(_keyStudentId, trimmedId);
      await _prefs!.setString(_keyDepartment, 'วิศวกรรมคอมพิวเตอร์');
      await _prefs!.setString(_keyFaculty, 'คณะวิทยาศาสตร์และวิศวกรรมศาสตร์');
      await _prefs!.setBool(_keyIsLoggedIn, true);
      return null;
    } catch (_) {
      return 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้ กรุณาลองใหม่อีกครั้ง';
    }
  }

  String _resolveStudentName(String studentId) {
    final String existingId = _prefs?.getString(_keyStudentId) ?? '';
    final String existingName = _prefs?.getString(_keyStudentName) ?? '';
    if (existingId == studentId && existingName.isNotEmpty) {
      return existingName;
    }

    if (studentId == '6731503021') {
      return 'Preeyaluk Moolpom';
    }

    return 'Student $studentId';
  }

  Future<void> logout() async {
    await initialize();
    await _prefs!.setBool(_keyIsLoggedIn, false);
  }
}
