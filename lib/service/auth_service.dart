import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  UserModel? currentUser;
  bool isLoading = false;

  Future<bool> checkLoginStatus() async {
    // Simulate a quick check (could be replaced with secure storage check)
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // indicate app can proceed; `initializeUser` will populate user when needed
  }

  Future<bool> login(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));

    if (email == 'admin@penjara.com' && password == 'admin123') {
      currentUser = UserModel(
        id: 'admin1',
        email: email,
        fullName: 'Administrator',
        role: 'admin',
        block: '',
        cell: '',
        inmateId: '',
        crime: '',
        sentenceStart: DateTime.now(),
        sentenceEnd: DateTime.now().add(const Duration(days: 365)),
        registrationDate: DateTime.now(),
      );
      isLoading = false;
      notifyListeners();
      return true;
    }

    if (email == 'narapidana1@penjara.com' && password == 'user123') {
      currentUser = UserModel(
        id: 'user1',
        email: email,
        fullName: 'Narapidana Satu',
        role: 'user',
        block: 'A',
        cell: '01',
        inmateId: 'N001',
        crime: 'Pelanggaran ringan',
        sentenceStart: DateTime.now().subtract(const Duration(days: 100)),
        sentenceEnd: DateTime.now().add(const Duration(days: 200)),
        registrationDate: DateTime.now().subtract(const Duration(days: 200)),
      );
      isLoading = false;
      notifyListeners();
      return true;
    }

    if (email == 'kesehatan@penjara.com' && password == 'health123') {
      currentUser = UserModel(
        id: 'health1',
        email: email,
        fullName: 'Petugas Kesehatan',
        role: 'health',
        block: '',
        cell: '',
        inmateId: '',
        crime: '',
        sentenceStart: DateTime.now(),
        sentenceEnd: DateTime.now().add(const Duration(days: 365)),
        registrationDate: DateTime.now(),
      );
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  void initializeUser(BuildContext context) {
    // If app resumed and there's no saved user, default to demo user
    if (currentUser == null) {
      currentUser = UserModel(
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
      );
      notifyListeners();
    }
  }

  void setAdminUser() {
    currentUser = UserModel(
      id: 'admin1',
      email: 'admin@penjara.com',
      fullName: 'Administrator',
      role: 'admin',
      block: '',
      cell: '',
      inmateId: '',
      crime: '',
      sentenceStart: DateTime.now(),
      sentenceEnd: DateTime.now().add(const Duration(days: 365)),
      registrationDate: DateTime.now(),
    );
    notifyListeners();
  }

  void setUserUser() {
    currentUser = UserModel(
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
    );
    notifyListeners();
  }

  void setHealthUser() {
    currentUser = UserModel(
      id: 'health1',
      email: 'kesehatan@penjara.com',
      fullName: 'Petugas Kesehatan',
      role: 'health',
      block: '',
      cell: '',
      inmateId: '',
      crime: '',
      sentenceStart: DateTime.now(),
      sentenceEnd: DateTime.now().add(const Duration(days: 365)),
      registrationDate: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> logout() async {
    currentUser = null;
    notifyListeners();
  }
}
