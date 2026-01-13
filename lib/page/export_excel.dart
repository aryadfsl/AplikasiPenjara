import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user.dart';

/// Export a list of UserModel to an Excel file and save it to device storage.
Future<String?> exportInmatesToExcel(List<UserModel> users) async {
  // Request storage permission if needed
  if (Platform.isAndroid || Platform.isIOS) {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      return null;
    }
  }

  final excel = Excel.createExcel();
  final Sheet sheet = excel['Narapidana'];
  // Header
  sheet.appendRow([
    TextCellValue('ID'),
    TextCellValue('Nama Lengkap'),
    TextCellValue('ID Narapidana'),
    TextCellValue('Blok'),
    TextCellValue('Sel'),
    TextCellValue('Kasus'),
    TextCellValue('Tanggal Mulai'),
    TextCellValue('Tanggal Akhir'),
    TextCellValue('Status'),
    TextCellValue('Tanggal Registrasi'),
    TextCellValue('Email'),
    TextCellValue('Role'),
  ]);
  // Data
  for (final user in users) {
    sheet.appendRow([
      TextCellValue(user.id),
      TextCellValue(user.fullName),
      TextCellValue(user.inmateId),
      TextCellValue(user.block),
      TextCellValue(user.cell),
      TextCellValue(user.crime),
      TextCellValue(user.sentenceStart.toIso8601String()),
      TextCellValue(user.sentenceEnd.toIso8601String()),
      TextCellValue(user.status),
      TextCellValue(user.registrationDate.toIso8601String()),
      TextCellValue(user.email),
      TextCellValue(user.role),
    ]);
  }

  final List<int>? fileBytes = excel.encode();
  if (fileBytes == null) {
    return null;
  }

  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    final filePath = '${directory!.path}/narapidana_export_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);
    return filePath;
  } catch (e) {
    return null;
  }
}
