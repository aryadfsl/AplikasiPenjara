import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/schedule.dart';
import '../models/complaint.dart';
import '../models/request.dart';

class FirebaseService extends ChangeNotifier {
  final List<UserModel> _users = [];
  final List<Schedule> _schedules = [];
  final List<Complaint> _complaints = [];
  final List<RequestModel> _requests = [];

  FirebaseService() {
    _initializeSampleData();
  }

  Future<void> initializeSampleData() async {
    await _initializeSampleData();
  }

  Future<void> _initializeSampleData() async {
    if (_users.isNotEmpty) return; // Already initialized

    // Demo users
    _users.addAll([
      UserModel(
        id: 'user1',
        email: 'narapidana1@penjara.com',
        fullName: 'Narapidana Satu',
        role: 'user',
        block: 'A',
        cell: '01',
        inmateId: 'N001',
        crime: 'Pelanggaran ringan',
        sentenceStart: DateTime.now().subtract(const Duration(days: 100)),
        sentenceEnd: DateTime.now().add(const Duration(days: 200)),
        registrationDate: DateTime.now().subtract(const Duration(days: 200)),
      ),
      UserModel(
        id: 'user2',
        email: 'narapidana2@penjara.com',
        fullName: 'Narapidana Dua',
        role: 'user',
        block: 'B',
        cell: '05',
        inmateId: 'N002',
        crime: 'Pencurian',
        sentenceStart: DateTime.now().subtract(const Duration(days: 150)),
        sentenceEnd: DateTime.now().add(const Duration(days: 250)),
        registrationDate: DateTime.now().subtract(const Duration(days: 250)),
      ),
      UserModel(
        id: 'user3',
        email: 'narapidana3@penjara.com',
        fullName: 'Narapidana Tiga',
        role: 'user',
        block: 'C',
        cell: '12',
        inmateId: 'N003',
        crime: 'Pelanggaran lalu lintas',
        sentenceStart: DateTime.now().subtract(const Duration(days: 50)),
        sentenceEnd: DateTime.now().add(const Duration(days: 150)),
        registrationDate: DateTime.now().subtract(const Duration(days: 150)),
      ),
    ]);

    // Demo schedules
    _schedules.addAll([
      Schedule(
        id: 'sched1',
        title: 'Sarapan Pagi',
        description: 'Waktu makan sarapan untuk semua narapidana',
        date: DateTime.now(),
        startTime: '06:00',
        endTime: '07:00',
        location: 'Ruang Makan A',
        type: 'makan',
        participants: ['user1', 'user2', 'user3'],
        instructor: 'Petugas A',
        isMandatory: true,
      ),
      Schedule(
        id: 'sched2',
        title: 'Olahraga Pagi',
        description: 'Latihan fisik dan olahraga untuk kesehatan',
        date: DateTime.now(),
        startTime: '07:30',
        endTime: '09:00',
        location: 'Lapangan Olahraga',
        type: 'olahraga',
        participants: ['user1', 'user3'],
        instructor: 'Petugas Olahraga',
        isMandatory: false,
      ),
      Schedule(
        id: 'sched3',
        title: 'Kelas Keterampilan',
        description: 'Belajar keterampilan dasar',
        date: DateTime.now(),
        startTime: '09:30',
        endTime: '11:30',
        location: 'Ruang Kelas',
        type: 'pendidikan',
        participants: ['user1', 'user2'],
        instructor: 'Instruktur Keterampilan',
        isMandatory: false,
      ),
    ]);

    // Demo complaints
    _complaints.addAll([
      Complaint(
        id: 'comp1',
        userId: 'user1',
        userName: 'Narapidana Satu',
        title: 'Masalah Air Bersih',
        description: 'Aliran air di kamar mandi kurang lancar',
        category: 'air',
        priority: 'sedang',
        status: 'pending',
        photos: [],
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Complaint(
        id: 'comp2',
        userId: 'user2',
        userName: 'Narapidana Dua',
        title: 'Perbaikan Listrik Kamar',
        description: 'Lampu di kamar tidak menyala',
        category: 'listrik',
        priority: 'tinggi',
        status: 'diproses',
        photos: [],
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // Demo requests
    _requests.addAll([
      RequestModel(
        id: 'req1',
        userId: 'user2',
        userName: 'Narapidana Dua',
        type: 'kesehatan',
        title: 'Pemeriksaan Kesehatan',
        description: 'Ingin melakukan pemeriksaan kesehatan rutin',
        status: 'pending',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RequestModel(
        id: 'req2',
        userId: 'user3',
        userName: 'Narapidana Tiga',
        type: 'pindah_sel',
        title: 'Permintaan Pindah Sel',
        description: 'Ingin pindah ke sel yang lebih tenang',
        status: 'pending',
        date: DateTime.now(),
      ),
    ]);

    notifyListeners();
  }

  // User methods
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users;
  }

  Future<void> addUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.add(user);
    notifyListeners();
  }

  Future<UserModel?> getUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Schedule methods
  Future<List<Schedule>> getSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules;
  }

  Future<List<Schedule>> getUserSchedules(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules.where((s) => s.participants.contains(userId)).toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _schedules.add(schedule);
    notifyListeners();
  }

  // Complaint methods
  Future<List<Complaint>> getComplaints() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _complaints;
  }

  Future<List<Complaint>> getUserComplaints(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _complaints.where((c) => c.userId == userId).toList();
  }

  Future<void> addComplaint(Complaint complaint) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newComplaint = Complaint(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
      userId: complaint.userId,
      userName: complaint.userName,
      title: complaint.title,
      description: complaint.description,
      category: complaint.category,
      priority: complaint.priority,
      status: complaint.status,
      photos: complaint.photos,
      date: complaint.date,
      processedDate: complaint.processedDate,
      processedBy: complaint.processedBy,
      resolutionNote: complaint.resolutionNote,
      actionTaken: complaint.actionTaken,
    );
    _complaints.add(newComplaint);
    notifyListeners();
  }

  Future<void> updateComplaintStatus(
    String complaintId,
    String status,
    String adminName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        final oldComplaint = _complaints[index];
        _complaints[index] = Complaint(
          id: oldComplaint.id,
          userId: oldComplaint.userId,
          userName: oldComplaint.userName,
          title: oldComplaint.title,
          description: oldComplaint.description,
          category: oldComplaint.category,
          priority: oldComplaint.priority,
          status: status,
          photos: oldComplaint.photos,
          date: oldComplaint.date,
          processedDate: DateTime.now(),
          processedBy: adminName,
          resolutionNote: oldComplaint.resolutionNote,
          actionTaken: oldComplaint.actionTaken,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating complaint: $e');
    }
  }

  // Request methods
  Future<List<RequestModel>> getRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests;
  }

  Future<List<RequestModel>> getUserRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests.where((r) => r.userId == userId).toList();
  }

  Future<void> addRequest(RequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newRequest = RequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userId: request.userId,
      userName: request.userName,
      type: request.type,
      title: request.title,
      description: request.description,
      status: request.status,
      date: request.date,
      processedDate: request.processedDate,
      processedBy: request.processedBy,
      adminNote: request.adminNote,
    );
    _requests.add(newRequest);
    notifyListeners();
  }

  Future<void> updateRequestStatus(
    String requestId,
    String status,
    String adminName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final oldRequest = _requests[index];
        _requests[index] = RequestModel(
          id: oldRequest.id,
          userId: oldRequest.userId,
          userName: oldRequest.userName,
          type: oldRequest.type,
          title: oldRequest.title,
          description: oldRequest.description,
          status: status,
          date: oldRequest.date,
          processedDate: DateTime.now(),
          processedBy: adminName,
          adminNote: oldRequest.adminNote,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating request: $e');
    }
  }
}
