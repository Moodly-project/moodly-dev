class MoodEntry {
  final int? id; // ID do banco de dados
  final DateTime date;
  final String mood;
  final int moodScore; // 1-5, sendo 1 muito negativo e 5 muito positivo
  final String note;
  final List<String> activities;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.moodScore,
    required this.note,
    this.activities = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'moodScore': moodScore,
      'note': note,
      'activities': activities,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      moodScore: json['moodScore'],
      note: json['note'],
      activities: json['activities'] is List 
          ? List<String>.from(json['activities']) 
          : [],
    );
  }
} 