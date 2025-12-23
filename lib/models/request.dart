class RequestModel {
  final String id;
  final String userId;
  final String userName;
  final String type; // 'pindah_sel', 'kebutuhan_khusus', 'kesehatan', 'keluarga', 'lainnya'
  final String title;
  final String description;
  final String status; // 'pending', 'disetujui', 'ditolak', 'diproses'
  final DateTime date;
  final DateTime? processedDate;
  final String? processedBy;
  final String? adminNote;

  RequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    this.status = 'pending',
    required this.date,
    this.processedDate,
    this.processedBy,
    this.adminNote,
  });

  // Firestore-specific factory removed; use `RequestModel.fromMap` instead

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type,
      'title': title,
      'description': description,
      'status': status,
      'date': date.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'processedBy': processedBy,
      'adminNote': adminNote,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> data, String id) {
    return RequestModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      type: data['type'] ?? 'lainnya',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      processedDate: data['processedDate'] != null
          ? DateTime.parse(data['processedDate'])
          : null,
      processedBy: data['processedBy'],
      adminNote: data['adminNote'],
    );
  }
}