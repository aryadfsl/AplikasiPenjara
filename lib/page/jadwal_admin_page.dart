import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import '../service/firebase_service.dart';

class AdminScheduleManagement extends StatefulWidget {
  const AdminScheduleManagement({super.key});

  @override
  State<AdminScheduleManagement> createState() => _AdminScheduleManagementState();
}

class _AdminScheduleManagementState extends State<AdminScheduleManagement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedType = 'kerja';
  bool _isMandatory = true;
  final List<String> _selectedParticipants = [];
  final List<String> _types = ['kerja', 'olahraga', 'pendidikan', 'ibadah', 'makan', 'istirahat'];
  
  List<Schedule> _schedules = [];
  List<UserModel> _inmates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      _schedules = await firebaseService.getSchedules();
      _inmates = await firebaseService.getUsers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  void _showAddScheduleDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _instructorController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _selectedDate = DateTime.now();
    _selectedType = 'kerja';
    _isMandatory = true;
    _selectedParticipants.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Jadwal Baru'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Kegiatan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal'
                                  : _formatDate(_selectedDate!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Waktu Mulai',
                              border: OutlineInputBorder(),
                              hintText: 'HH:MM',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Waktu mulai harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Waktu Selesai',
                              border: OutlineInputBorder(),
                              hintText: 'HH:MM',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Waktu selesai harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kegiatan',
                        border: OutlineInputBorder(),
                      ),
                      items: _types.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _instructorController,
                      decoration: const InputDecoration(
                        labelText: 'Instruktur/Petugas',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Instruktur harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _isMandatory,
                          onChanged: (value) {
                            setState(() {
                              _isMandatory = value!;
                            });
                          },
                        ),
                        const Text('Wajib diikuti'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pilih Peserta (opsional):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        itemCount: _inmates.length,
                        itemBuilder: (context, index) {
                          final inmate = _inmates[index];
                          return CheckboxListTile(
                            title: Text('${inmate.fullName} (${inmate.block}-${inmate.cell})'),
                            value: _selectedParticipants.contains(inmate.id),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedParticipants.add(inmate.id);
                                } else {
                                  _selectedParticipants.remove(inmate.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addSchedule();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addSchedule() async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      final newSchedule = Schedule(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate!,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        location: _locationController.text,
        type: _selectedType,
        instructor: _instructorController.text,
        isMandatory: _isMandatory,
        participants: _selectedParticipants,
      );

      await firebaseService.addSchedule(newSchedule);
      await _loadData();

      _showSnackBar(context, 'Jadwal berhasil ditambahkan', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Gagal menambahkan jadwal: $e', Colors.red);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'kerja':
        return 'Kerja';
      case 'olahraga':
        return 'Olahraga';
      case 'pendidikan':
        return 'Pendidikan';
      case 'ibadah':
        return 'Ibadah';
      case 'makan':
        return 'Makan';
      default:
        return 'Istirahat';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getScheduleColor(String type) {
    switch (type) {
      case 'kerja':
        return Colors.blue;
      case 'olahraga':
        return Colors.green;
      case 'pendidikan':
        return Colors.purple;
      case 'ibadah':
        return Colors.orange;
      case 'makan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final color = _getScheduleColor(schedule.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    schedule.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTypeLabel(schedule.type).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              schedule.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    _formatDate(schedule.date),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.grey[100],
                ),
                Chip(
                  label: Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                Chip(
                  label: Text(
                    schedule.location,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.green[100],
                ),
                Chip(
                  label: Text(
                    '${schedule.participants.length} peserta',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.orange[100],
                ),
                Chip(
                  label: Text(
                    schedule.isMandatory ? 'Wajib' : 'Opsional',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: schedule.isMandatory 
                      ? Colors.red[100] 
                      : Colors.green[100],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Instruktur: ${schedule.instructor}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.blueGrey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manajemen Jadwal',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: ${_schedules.length} jadwal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_schedules.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada jadwal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan jadwal baru',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _schedules.map(_buildScheduleCard).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}