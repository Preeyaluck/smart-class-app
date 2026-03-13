import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/attendance_record.dart';

class AttendanceStorageService {
  AttendanceStorageService._();

  static final AttendanceStorageService instance = AttendanceStorageService._();

  static const String _webStorageKey = 'attendance_records';
  Database? _database;
  SharedPreferences? _sharedPreferences;

  Future<void> initialize() async {
    if (kIsWeb) {
      _sharedPreferences ??= await SharedPreferences.getInstance();
      return;
    }
    _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final String dbPath = p.join(await getDatabasesPath(), 'smart_class.db');
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE attendance_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            qr_code TEXT NOT NULL,
            course_code TEXT,
            course_title TEXT,
            previous_topic TEXT,
            expected_topic TEXT,
            mood INTEGER,
            learned_today TEXT,
            feedback TEXT
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE attendance_records ADD COLUMN course_code TEXT');
          await db.execute('ALTER TABLE attendance_records ADD COLUMN course_title TEXT');
        }
      },
    );
  }

  Future<int> insertRecord(AttendanceRecord record) async {
    if (kIsWeb) {
      final SharedPreferences prefs =
          _sharedPreferences ??= await SharedPreferences.getInstance();
      final List<String> current =
          prefs.getStringList(_webStorageKey) ?? <String>[];
      current.add(jsonEncode(record.toMap()));
      await prefs.setStringList(_webStorageKey, current);
      return current.length;
    }

    final Database db = _database ??= await _openDatabase();
    return db.insert('attendance_records', record.toMap());
  }

  Future<List<AttendanceRecord>> getAllRecords() async {
    if (kIsWeb) {
      final SharedPreferences prefs =
          _sharedPreferences ??= await SharedPreferences.getInstance();
      final List<String> raw =
          prefs.getStringList(_webStorageKey) ?? const <String>[];

      final List<AttendanceRecord> records = <AttendanceRecord>[];
      for (final String item in raw) {
        try {
          final Map<String, dynamic> decoded =
              jsonDecode(item) as Map<String, dynamic>;
          records.add(AttendanceRecord.fromMap(decoded));
        } catch (_) {
          // Skip malformed records in local storage.
        }
      }

      records.sort((AttendanceRecord a, AttendanceRecord b) {
        return b.timestamp.compareTo(a.timestamp);
      });
      return records;
    }

    final Database db = _database ??= await _openDatabase();
    final List<Map<String, Object?>> maps = await db.query(
      'attendance_records',
      orderBy: 'timestamp DESC',
    );

    final List<AttendanceRecord> records = <AttendanceRecord>[];
    for (final Map<String, Object?> row in maps) {
      try {
        records.add(AttendanceRecord.fromMap(row));
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return records;
  }
}
