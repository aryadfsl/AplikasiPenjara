import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user.dart';
import '../models/complaint.dart';
import '../models/request.dart';

class PdfExportService {
  // Export Data Narapidana
  static Future<void> exportNarapidanaPdf(List<UserModel> inmates) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN DATA NARAPIDANA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Tanggal Export: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Narapidana', '${inmates.length}'),
                _buildSummaryItem(
                  'Aktif',
                  '${inmates.where((i) => i.status == 'aktif').length}',
                ),
                _buildSummaryItem(
                  'Transfer',
                  '${inmates.where((i) => i.status == 'transfer').length}',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(2),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('No', isHeader: true),
                  _buildTableCell('Nama', isHeader: true),
                  _buildTableCell('ID', isHeader: true),
                  _buildTableCell('Blok-Sel', isHeader: true),
                  _buildTableCell('Jenis Kasus', isHeader: true),
                  _buildTableCell('Tanggal Selesai', isHeader: true),
                ],
              ),
              // Data rows
              ...inmates.asMap().entries.map((entry) {
                final index = entry.key;
                final inmate = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(inmate.fullName),
                    _buildTableCell(inmate.inmateId),
                    _buildTableCell('${inmate.block}-${inmate.cell}'),
                    _buildTableCell(inmate.crime),
                    _buildTableCell(_formatDate(inmate.sentenceEnd)),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );

    // Show PDF preview & print dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Data_Narapidana_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Export Data Keluhan
  static Future<void> exportKeluhanPdf(List<Complaint> complaints) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN KELUHAN NARAPIDANA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Tanggal Export: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Keluhan', '${complaints.length}'),
                _buildSummaryItem(
                  'Pending',
                  '${complaints.where((c) => c.status == 'pending').length}',
                ),
                _buildSummaryItem(
                  'Selesai',
                  '${complaints.where((c) => c.status == 'selesai').length}',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('No', isHeader: true),
                  _buildTableCell('Nama', isHeader: true),
                  _buildTableCell('Judul', isHeader: true),
                  _buildTableCell('Kategori', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                  _buildTableCell('Tanggal', isHeader: true),
                ],
              ),
              // Data rows
              ...complaints.asMap().entries.map((entry) {
                final index = entry.key;
                final complaint = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(complaint.userName),
                    _buildTableCell(complaint.title),
                    _buildTableCell(_getCategoryLabel(complaint.category)),
                    _buildTableCell(_getStatusLabel(complaint.status)),
                    _buildTableCell(_formatDate(complaint.date)),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Data_Keluhan_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Export Data Pengajuan Kesehatan
  static Future<void> exportKesehatanPdf(List<RequestModel> requests) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN PENGAJUAN KESEHATAN',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Tanggal Export: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Pengajuan', '${requests.length}'),
                _buildSummaryItem(
                  'Pending',
                  '${requests.where((r) => r.status == 'pending').length}',
                ),
                _buildSummaryItem(
                  'Disetujui',
                  '${requests.where((r) => r.status == 'approved').length}',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('No', isHeader: true),
                  _buildTableCell('Nama', isHeader: true),
                  _buildTableCell('Jenis Keluhan', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                  _buildTableCell('Tanggal', isHeader: true),
                ],
              ),
              // Data rows
              ...requests.asMap().entries.map((entry) {
                final index = entry.key;
                final request = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(request.userName),
                    _buildTableCell(request.title),
                    _buildTableCell(_getStatusLabel(request.status)),
                    _buildTableCell(_formatDate(request.date)),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Data_Kesehatan_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Helper methods
  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _getCategoryLabel(String category) {
    const labels = {
      'air': 'Air',
      'listrik': 'Listrik',
      'sanitasi': 'Sanitasi',
      'makanan': 'Makanan',
      'kamar': 'Kamar',
      'lainnya': 'Lainnya',
    };
    return labels[category] ?? category;
  }

  static String _getStatusLabel(String status) {
    const labels = {
      'pending': 'Pending',
      'diproses': 'Diproses',
      'selesai': 'Selesai',
      'ditolak': 'Ditolak',
      'approved': 'Disetujui',
      'rejected': 'Ditolak',
    };
    return labels[status] ?? status;
  }
}
