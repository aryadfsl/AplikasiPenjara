import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../service/firebase_service.dart';
import '../models/schedule.dart';

class AddScheduleDialog extends StatefulWidget {
  final Function() onScheduleAdded;

  const AddScheduleDialog({
    Key? key,
    required this.onScheduleAdded,
  }) : super(key: key);

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final locationController = TextEditingController();
  final instructorController = TextEditingController();
  String selectedType = 'kerja';
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    locationController.dispose();
    instructorController.dispose();
    super.dispose();
  }

  Future<void> _addSchedule() async {
    if (titleController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field yang diperlukan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseService =
          Provider.of<FirebaseService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final newSchedule = Schedule(
        id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
        title: titleController.text,
        description: descController.text,
        date: DateTime.now(),
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        location: locationController.text,
        type: selectedType,
        participants: [authService.currentUser!.id],
        instructor: instructorController.text,
        isMandatory: true,
      );

      await firebaseService.addSchedule(newSchedule);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onScheduleAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Jadwal Baru'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Judul Jadwal *',
                hintText: 'Contoh: Sarapan Pagi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              enabled: !_isLoading,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Penjelasan singkat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Jam Mulai *',
                hintText: 'HH:MM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Jam Selesai *',
                hintText: 'HH:MM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Lokasi',
                hintText: 'Tempat kegiatan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instructorController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Instruktur',
                hintText: 'Nama pembimbing',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                labelText: 'Tipe Jadwal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ['kerja', 'olahraga', 'pendidikan', 'ibadah', 'makan', 'istirahat']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        selectedType = value ?? 'kerja';
                      });
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Tambah Jadwal'),
        ),
      ],
    );
  }
}
