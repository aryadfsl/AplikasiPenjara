import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../service/firebase_service.dart';
import '../models/schedule.dart';
import 'tambah_jadwal_page.dart';
import 'schedule_detail_page.dart';

class UserScheduleScreen extends StatefulWidget {
  const UserScheduleScreen({super.key});

  @override
  State<UserScheduleScreen> createState() => _UserScheduleScreenState();
}

class _UserScheduleScreenState extends State<UserScheduleScreen> {
  List<Schedule> _userSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSchedules();
  }

  Future<void> _loadUserSchedules() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final user = authService.currentUser!;

      _userSchedules = await firebaseService.getUserSchedules(user.id);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading schedules: $e');
    }
  }

  Color _getScheduleColor(String type) {
    switch (type) {
      case 'kerja':
        return Colors.blueGrey[800]!;
      case 'olahraga':
        return Colors.blueGrey[800]!;
      case 'pendidikan':
        return Colors.blueGrey[800]!;
      case 'ibadah':
        return Colors.blueGrey[800]!;
      case 'makan':
        return Colors.blueGrey[800]!;
      default:
        return Colors.blueGrey[800]!;
    }
  }

  IconData _getScheduleIcon(String type) {
    switch (type) {
      case 'kerja':
        return Icons.work;
      case 'olahraga':
        return Icons.sports;
      case 'pendidikan':
        return Icons.school;
      case 'ibadah':
        return Icons.person_pin;
      case 'makan':
        return Icons.restaurant;
      case 'istirahat':
        return Icons.bedtime;
      default:
        return Icons.event;
    }
  }

  // date formatting helper not used here (kept for reference)


  Widget _buildScheduleCard(Schedule schedule) {
    final color = _getScheduleColor(schedule.type);
    final icon = _getScheduleIcon(schedule.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleDetailPage(schedule: schedule),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          schedule.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildScheduleDetail(
                    icon: Icons.access_time,
                    text: '${schedule.startTime} - ${schedule.endTime}',
                  ),
                  const SizedBox(width: 16),
                  _buildScheduleDetail(
                    icon: Icons.location_on,
                    text: schedule.location,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildScheduleDetail(
                    icon: Icons.person,
                    text: schedule.instructor,
                  ),
                  const Spacer(),
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
            ],
          ),
        ),
      ),
    );
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

  Widget _buildScheduleDetail({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showAddScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        onScheduleAdded: _loadUserSchedules,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser!;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserSchedules,
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
                            'Jadwal Harian',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sel ${user.cell}, Blok ${user.block}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total Jadwal',
                                  value: '${_userSchedules.length}',
                                  color: Colors.blue,
                                  icon: Icons.event,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Hari Ini',
                                  value: DateTime.now().day.toString(),
                                  color: Colors.green,
                                  icon: Icons.today,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_userSchedules.isEmpty)
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
                            'Tidak ada jadwal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan cek kembali nanti',
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
                      children: _userSchedules.map(_buildScheduleCard).toList(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}