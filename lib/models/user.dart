class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin' atau 'user'
  final String block;
  final String cell;
  final String inmateId;
  final String crime;
  final DateTime sentenceStart;
  final DateTime sentenceEnd;
  final String status; // 'aktif', 'transfer', 'bebas'
  final DateTime registrationDate;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.block,
    required this.cell,
    required this.inmateId,
    required this.crime,
    required this.sentenceStart,
    required this.sentenceEnd,
    this.status = 'aktif',
    required this.registrationDate,
  });



  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'block': block,
      'cell': cell,
      'inmateId': inmateId,
      'crime': crime,
      'sentenceStart': sentenceStart.toIso8601String(),
      'sentenceEnd': sentenceEnd.toIso8601String(),
      'status': status,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'user',
      block: data['block'] ?? '',
      cell: data['cell'] ?? '',
      inmateId: data['inmateId'] ?? '',
      crime: data['crime'] ?? '',
      sentenceStart: DateTime.parse(data['sentenceStart'] ?? DateTime.now().toIso8601String()),
      sentenceEnd: DateTime.parse(data['sentenceEnd'] ?? DateTime.now().toIso8601String()),
      status: data['status'] ?? 'aktif',
      registrationDate: DateTime.parse(data['registrationDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}