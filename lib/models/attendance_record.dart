class AttendanceRecord {
  AttendanceRecord({
    this.id,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.qrCode,
    this.courseCode,
    this.courseTitle,
    this.previousTopic,
    this.expectedTopic,
    this.mood,
    this.learnedToday,
    this.feedback,
  });

  final int? id;
  final RecordType type;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String qrCode;
  final String? courseCode;
  final String? courseTitle;
  final String? previousTopic;
  final String? expectedTopic;
  final int? mood;
  final String? learnedToday;
  final String? feedback;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'qr_code': qrCode,
      'course_code': courseCode,
      'course_title': courseTitle,
      'previous_topic': previousTopic,
      'expected_topic': expectedTopic,
      'mood': mood,
      'learned_today': learnedToday,
      'feedback': feedback,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, Object?> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      type: RecordType.values.byName(map['type'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      qrCode: map['qr_code'] as String,
      courseCode: map['course_code'] as String?,
      courseTitle: map['course_title'] as String?,
      previousTopic: map['previous_topic'] as String?,
      expectedTopic: map['expected_topic'] as String?,
      mood: map['mood'] as int?,
      learnedToday: map['learned_today'] as String?,
      feedback: map['feedback'] as String?,
    );
  }
}

enum RecordType {
  checkIn,
  finishClass;

  String get label {
    switch (this) {
      case RecordType.checkIn:
        return 'Check-in';
      case RecordType.finishClass:
        return 'Finish Class';
    }
  }
}
