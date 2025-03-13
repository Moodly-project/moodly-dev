class MoodEntry {
  final DateTime date;
  final String mood;
  final int moodScore; // 1-5, sendo 1 muito negativo e 5 muito positivo
  final String note;
  final List<String> activities;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.moodScore,
    required this.note,
    this.activities = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'moodScore': moodScore,
      'note': note,
      'activities': activities,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      moodScore: json['moodScore'],
      note: json['note'],
      activities: List<String>.from(json['activities']),
    );
  }
} 