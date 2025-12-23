class Schedule {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final String type; // 'kerja', 'olahraga', 'pendidikan', 'ibadah', 'makan', 'istirahat'
  final List<String> participants;
  final String instructor;
  final bool isMandatory;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.participants = const [],
    required this.instructor,
    this.isMandatory = true,
  });

  // Firestore-specific factory removed; use `Schedule.fromMap` instead

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'type': type,
      'participants': participants,
      'instructor': instructor,
      'isMandatory': isMandatory,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> data, String id) {
    return Schedule(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? 'kerja',
      participants: List<String>.from(data['participants'] ?? []),
      instructor: data['instructor'] ?? '',
      isMandatory: data['isMandatory'] ?? true,
    );
  }
}