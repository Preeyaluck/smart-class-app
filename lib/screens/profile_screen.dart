import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../services/attendance_storage_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _checkInCount = 0;
  int _finishCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final records = await AttendanceStorageService.instance.getAllRecords();
    if (!mounted) return;
    setState(() {
      _checkInCount =
          records.where((r) => r.type == RecordType.checkIn).length;
      _finishCount =
          records.where((r) => r.type == RecordType.finishClass).length;
      _isLoading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('ออกจากระบบ'),
        content: const Text('ต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.instance.logout();
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final joinYear = auth.studentId.isNotEmpty
        ? '25${auth.studentId.substring(0, 2)}'
        : '2567';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0F3367),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F3367), Color(0xFF1D73D7)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFF0F3367),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        auth.studentName.isNotEmpty
                            ? auth.studentName
                            : 'ชื่อนักศึกษา',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        auth.studentId.isNotEmpty
                            ? auth.studentId
                            : 'รหัสนักศึกษา',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats row
                  if (!_isLoading)
                    Row(
                      children: [
                        _StatCard(
                          label: 'Check-in',
                          value: '$_checkInCount',
                          icon: Icons.login,
                          color: const Color(0xFF1D73D7),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Finish Class',
                          value: '$_finishCount',
                          icon: Icons.logout,
                          color: const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'ปีการศึกษา',
                          value: joinYear,
                          icon: Icons.calendar_today,
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Profile details card
                  _InfoCard(children: [
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'รหัสนักศึกษา',
                      value: auth.studentId.isNotEmpty
                          ? auth.studentId
                          : '-',
                    ),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'ชื่อ-นามสกุล',
                      value: auth.studentName.isNotEmpty
                          ? auth.studentName
                          : '-',
                    ),
                    _InfoRow(
                      icon: Icons.school_outlined,
                      label: 'สาขา',
                      value: auth.department.isNotEmpty
                          ? auth.department
                          : '-',
                    ),
                    _InfoRow(
                      icon: Icons.account_balance_outlined,
                      label: 'คณะ',
                      value: auth.faculty.isNotEmpty ? auth.faculty : '-',
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1D73D7), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1, indent: 16, endIndent: 16,
              color: Colors.grey.shade100),
      ],
    );
  }
}
