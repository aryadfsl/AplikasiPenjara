import 'package:flutter/material.dart';
import '../models/user.dart';
import '../service/firebase_service.dart';

class EditNarapidanaScreen extends StatefulWidget {
  final UserModel inmate;
  const EditNarapidanaScreen({super.key, required this.inmate});

  @override
  State<EditNarapidanaScreen> createState() => _EditNarapidanaScreenState();
}

class _EditNarapidanaScreenState extends State<EditNarapidanaScreen> {
  late TextEditingController fullNameController;
  late TextEditingController blockController;
  late TextEditingController cellController;
  late TextEditingController crimeController;
  late DateTime sentenceStartDate;
  late DateTime sentenceEndDate;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.inmate.fullName);
    blockController = TextEditingController(text: widget.inmate.block);
    cellController = TextEditingController(text: widget.inmate.cell);
    crimeController = TextEditingController(text: widget.inmate.crime);
    sentenceStartDate = widget.inmate.sentenceStart;
    sentenceEndDate = widget.inmate.sentenceEnd;
    selectedStatus = widget.inmate.status;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    blockController.dispose();
    cellController.dispose();
    crimeController.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    final updatedInmate = widget.inmate.copyWith(
      fullName: fullNameController.text,
      block: blockController.text,
      cell: cellController.text,
      crime: crimeController.text,
      sentenceStart: sentenceStartDate,
      sentenceEnd: sentenceEndDate,
      status: selectedStatus,
    );
    await FirebaseService().updateUser(updatedInmate);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Narapidana')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextFormField(
              controller: blockController,
              decoration: const InputDecoration(labelText: 'Blok'),
            ),
            TextFormField(
              controller: cellController,
              decoration: const InputDecoration(labelText: 'Sel'),
            ),
            TextFormField(
              controller: crimeController,
              decoration: const InputDecoration(labelText: 'Kasus'),
            ),
            ListTile(
              title: const Text('Tanggal Mulai Hukuman'),
              subtitle: Text('${sentenceStartDate.day}/${sentenceStartDate.month}/${sentenceStartDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: sentenceStartDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => sentenceStartDate = date);
              },
            ),
            ListTile(
              title: const Text('Tanggal Akhir Hukuman'),
              subtitle: Text('${sentenceEndDate.day}/${sentenceEndDate.month}/${sentenceEndDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: sentenceEndDate,
                  firstDate: sentenceStartDate,
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => sentenceEndDate = date);
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: ['aktif', 'transfer', 'bebas'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
              onChanged: (value) => setState(() => selectedStatus = value ?? 'aktif'),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEdit,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
