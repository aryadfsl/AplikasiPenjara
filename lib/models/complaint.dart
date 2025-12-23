class Complaint {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final String category; // 'air', 'listrik', 'sanitasi', 'makanan', 'kamar', 'lainnya'
  final String priority; // 'rendah', 'sedang', 'tinggi', 'darurat'
  final String status; // 'pending', 'diproses', 'selesai', 'ditolak'
  final List<String>? photos;
  final DateTime date;
  final DateTime? processedDate;
  final String? processedBy;
  final String? resolutionNote;
  final String? actionTaken;

  Complaint({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 'sedang',
    this.status = 'pending',
    this.photos,
    required this.date,
    this.processedDate,
    this.processedBy,
    this.resolutionNote,
    this.actionTaken,
  });

  // Firestore-specific factory removed; use `Complaint.fromMap` instead

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'photos': photos ?? [],
      'date': date.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'processedBy': processedBy,
      'resolutionNote': resolutionNote,
      'actionTaken': actionTaken,
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> data, String id) {
    return Complaint(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'lainnya',
      priority: data['priority'] ?? 'sedang',
      status: data['status'] ?? 'pending',
      photos: List<String>.from(data['photos'] ?? []),
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      processedDate: data['processedDate'] != null
          ? DateTime.parse(data['processedDate'])
          : null,
      processedBy: data['processedBy'],
      resolutionNote: data['resolutionNote'],
      actionTaken: data['actionTaken'],
    );
  }
}