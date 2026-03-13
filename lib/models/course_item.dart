class CourseItem {
  const CourseItem({
    required this.code,
    required this.title,
    required this.time,
    required this.location,
    this.isPrimary = false,
  });

  final String code;
  final String title;
  final String time;
  final String location;
  final bool isPrimary;
}
