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
    try {
      return UserModel(
        id: id,
        email: data['email']?.toString() ?? '',
        fullName: data['fullName']?.toString() ?? '',
        role: data['role']?.toString() ?? 'user',
        block: data['block']?.toString() ?? '',
        cell: data['cell']?.toString() ?? '',
        inmateId: data['inmateId']?.toString() ?? '',
        crime: data['crime']?.toString() ?? '',
        sentenceStart: data['sentenceStart'] != null
            ? DateTime.parse(data['sentenceStart'].toString())
            : DateTime.now(),
        sentenceEnd: data['sentenceEnd'] != null
            ? DateTime.parse(data['sentenceEnd'].toString())
            : DateTime.now(),
        status: data['status']?.toString() ?? 'aktif',
        registrationDate: data['registrationDate'] != null
            ? DateTime.parse(data['registrationDate'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('ERROR in UserModel.fromMap: $e');
      print('Data: $data');
      rethrow;
    }
  }
}
