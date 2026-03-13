import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_record.dart';
import '../models/course_item.dart';
import '../services/attendance_storage_service.dart';
import '../widgets/course_card.dart';
import '../widgets/profile_header.dart';
import 'check_in_screen.dart';
import 'finish_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<CourseItem> _courses = <CourseItem>[
    CourseItem(
      code: '1305216',
      title: 'Mobile App Dev',
      time: '09:00 - 12:00',
      location: 'SCB 301',
      isPrimary: true,
    ),
    CourseItem(
      code: '01204221',
      title: 'Data Science',
      time: '13:00 - 16:00',
      location: 'LAB 504',
    ),
    CourseItem(
      code: '01202334',
      title: 'UI/UX Design',
      time: '16:00 - 18:00',
      location: 'HUM 210',
    ),
  ];

  final DateFormat _timeFormat = DateFormat('dd/MM/yyyy HH:mm');
  List<AttendanceRecord> _records = <AttendanceRecord>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final List<AttendanceRecord> rows =
          await AttendanceStorageService.instance.getAllRecords();
      if (!mounted) {
        return;
      }
      setState(() {
        _records = rows;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _records = <AttendanceRecord>[];
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _goToCheckIn(CourseItem course) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CheckInScreen(course: course)),
    );
    await _loadRecords();
  }

  Future<void> _goToFinish(CourseItem course) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => FinishClassScreen(course: course)),
    );
    await _loadRecords();
  }

  (String, Color, double) _statusForCourse(CourseItem course) {
    if (!course.isPrimary) {
      return ('Not Checked-in', const Color(0xFFF59E0B), 0.55);
    }

    if (_records.isEmpty) {
      return ('Not Checked-in', const Color(0xFFF59E0B), 0.25);
    }

    final AttendanceRecord latest = _records.first;
    if (latest.type == RecordType.checkIn) {
      return ('Checked-in', const Color(0xFF22C55E), 0.86);
    }

    return ('Class Completed', const Color(0xFF0EA5E9), 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add course can be implemented later.')),
          );
        },
        backgroundColor: const Color(0xFFFF7A1B),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecords,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const ProfileHeader(),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Check-in',
                      subtitle: 'Before class',
                      icon: Icons.login,
                      colors: const <Color>[Color(0xFF2270E0), Color(0xFF174593)],
                      onTap: () => _goToCheckIn(_courses.first),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Finish Class',
                      subtitle: 'After class',
                      icon: Icons.logout,
                      colors: const <Color>[Color(0xFF33B86A), Color(0xFF1D8E53)],
                      onTap: () => _goToFinish(_courses.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Course List',
                style: TextStyle(fontSize: 25 / 1.4, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (final CourseItem course in _courses)
                Builder(
                  builder: (BuildContext context) {
                    final (String statusText, Color statusColor, double progress) =
                        _statusForCourse(course);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CourseCard(
                        course: course,
                        statusText: statusText,
                        statusColor: statusColor,
                        progress: progress,
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      '${course.code} ${course.title}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${course.time} | ${course.location}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const Divider(height: 20),
                                    FilledButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _goToCheckIn(course);
                                      },
                                      icon: const Icon(Icons.login),
                                      label: const Text('Check-in Before Class'),
                                    ),
                                    const SizedBox(height: 8),
                                    FilledButton.tonalIcon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _goToFinish(course);
                                      },
                                      icon: const Icon(Icons.logout),
                                      label: const Text('Finish Class'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(),
                ))
              else if (_error != null)
                Text('Failed to load records: $_error')
              else if (_records.isNotEmpty) ...<Widget>[
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: _records.take(4).map((AttendanceRecord item) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: item.type == RecordType.checkIn
                                ? const Color(0xFFE8F8EF)
                                : const Color(0xFFE7F3FB),
                            child: Icon(
                              item.type == RecordType.checkIn
                                  ? Icons.login
                                  : Icons.logout,
                              color: item.type == RecordType.checkIn
                                  ? const Color(0xFF22A05A)
                                  : const Color(0xFF177AB2),
                            ),
                          ),
                          title: Text(item.type.label),
                          subtitle: Text(
                            '${_timeFormat.format(item.timestamp)} | ${item.qrCode}',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: colors),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
