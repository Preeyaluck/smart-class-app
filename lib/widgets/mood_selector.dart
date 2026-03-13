import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const List<_MoodItem> _moods = <_MoodItem>[
    _MoodItem(score: 1, emoji: '😡', label: 'Very Bad'),
    _MoodItem(score: 2, emoji: '🙁', label: 'Bad'),
    _MoodItem(score: 3, emoji: '😐', label: 'Neutral'),
    _MoodItem(score: 4, emoji: '🙂', label: 'Good'),
    _MoodItem(score: 5, emoji: '😄', label: 'Great'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _moods.map((_MoodItem mood) {
        final bool selected = mood.score == value;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(mood.score),
          child: Container(
            width: 62,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF2E6) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFFFF7A1B) : const Color(0xFFDCE3EE),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? const Color(0xFFAF4A05) : const Color(0xFF475467),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodItem {
  const _MoodItem({
    required this.score,
    required this.emoji,
    required this.label,
  });

  final int score;
  final String emoji;
  final String label;
}
