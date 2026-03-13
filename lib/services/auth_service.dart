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

  // In-memory fallback for browsers that block localStorage (Guest/InPrivate mode)
  bool _memLoggedIn = false;
  String _memStudentId = '';
  String _memStudentName = '';
  String _memDepartment = '';
  String _memFaculty = '';

  Future<void> initialize() async {
    if (_prefs != null) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // localStorage unavailable — will use in-memory state only
    }
  }

  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? _memLoggedIn;
  String get studentId => _prefs?.getString(_keyStudentId) ?? _memStudentId;
  String get studentName => _prefs?.getString(_keyStudentName) ?? _memStudentName;
  String get department => _prefs?.getString(_keyDepartment) ?? _memDepartment;
  String get faculty => _prefs?.getString(_keyFaculty) ?? _memFaculty;

  /// Demo login: any non-empty student ID + password "1234"
  Future<String?> login({
    required String studentId,
    required String password,
  }) async {
    await initialize();

    final String trimmedId = studentId.trim();
    if (trimmedId.isEmpty) return 'กรุณากรอกรหัสนักศึกษา';
    if (password != '1234') return 'รหัสผ่านไม่ถูกต้อง (Demo: 1234)';

    const dept = 'วิศวกรรมคอมพิวเตอร์';
    const fac = 'คณะวิทยาศาสตร์และวิศวกรรมศาสตร์';
    final name = _resolveStudentName(trimmedId);

    // Always update in-memory state first (works even if prefs unavailable)
    _memLoggedIn = true;
    _memStudentId = trimmedId;
    _memStudentName = name;
    _memDepartment = dept;
    _memFaculty = fac;

    // Try to persist — ignore errors (Guest/InPrivate mode may block writes)
    try {
      if (_prefs != null) {
        await _prefs!.setString(_keyStudentName, name);
        await _prefs!.setString(_keyStudentId, trimmedId);
        await _prefs!.setString(_keyDepartment, dept);
        await _prefs!.setString(_keyFaculty, fac);
        await _prefs!.setBool(_keyIsLoggedIn, true);
      }
    } catch (_) {}

    return null;
  }

  String _resolveStudentName(String studentId) {
    if (studentId == '6731503021') return 'Preeyaluk Moolpom';
    return 'Student $studentId';
  }

  Future<void> logout() async {
    _memLoggedIn = false;
    _memStudentId = '';
    _memStudentName = '';
    _memDepartment = '';
    _memFaculty = '';

    try {
      await initialize();
      await _prefs?.setBool(_keyIsLoggedIn, false);
    } catch (_) {}
  }
}
